//
//  MMAutoCompleteSortOperation.m
//  search
//
//  Created by Marc on 4/30/14.
//
//

#import "MMAutoCompleteSortOperation.h"
#import "MMAutoCompletionObject.h"
#import "NSString+Levenshtein.h"
#import <StringScore/NSString+Score.h>

static NSString *kSortInputStringKey = @"sortInputString";
static NSString *kSortEditDistancesKey = @"editDistances";
static NSString *kSortObjectKey = @"sortObject";
const float kAutoCompleteMinimumMatchThreshold = 0.5;

@implementation MMAutoCompleteSortOperation

- (void)main
{
    @autoreleasepool {
        
        if (self.isCancelled){
            return;
        }
        
        NSArray *results = [self sortedCompletionsForString:self.incompleteString
                                        withPossibleStrings:self.possibleCompletions];
        
        if (self.isCancelled){
            return;
        }
        
        if(!self.isCancelled){
            [(NSObject *)self.delegate
             performSelectorOnMainThread:@selector(autoCompleteTermsDidSort:)
             withObject:results
             waitUntilDone:NO];
        }
    }
}

- (id)initWithDelegate:(id<MMAutoCompleteSortOperationDelegate>)aDelegate incompleteString:(NSString *)string possibleCompletions:(NSArray *)possibleStrings operationType:(MMSortOperationType)operationType
{
    self = [super init];
    if (self) {
        [self setDelegate:aDelegate];
        [self setOperationType:operationType];
        [self setIncompleteString:string];
        [self setPossibleCompletions:possibleStrings];
    }
    return self;
}

- (NSArray *)sortedCompletionsForString:(NSString *)inputString withPossibleStrings:(NSArray *)possibleTerms
{
    if([inputString isEqualToString:@""]){
        return possibleTerms;
    }
    
    if(self.isCancelled){
        return [NSArray array];
    }
    
    if (self.operationType == MMSortUsingLevensteinDistance)
        return [self sortUsingLevenshteinDistanceForString:inputString withPossibleStrings:possibleTerms];
    else
        return [self sortUsingStringScoreForString:inputString withPossibleStrings:possibleTerms];
    
}

- (NSArray *)sortUsingLevenshteinDistanceForString:(NSString *)inputString withPossibleStrings:(NSArray *)possibleTerms
{
    NSMutableArray *editDistances = [NSMutableArray arrayWithCapacity:possibleTerms.count];
    
    for(NSObject *originalObject in possibleTerms) {
        
        NSString *currentString;
        if([originalObject isKindOfClass:[NSString class]]){
            currentString = (NSString *)originalObject;
        } else if ([originalObject conformsToProtocol:@protocol(MMAutoCompletionObject)]){
            currentString = [(id <MMAutoCompletionObject>)originalObject autoCompletionValue];
        } else {
            NSAssert(0, @"Autocompletion terms must either be strings or objects conforming to the MLPAutoCompleteObject protocol.");
        }
        
        if(self.isCancelled){
            return [NSArray array];
        }
        
        NSUInteger maximumRange = (inputString.length < currentString.length) ? inputString.length : currentString.length;
        float editDistanceOfCurrentString = [inputString asciiLevenshteinDistanceWithString:[currentString substringWithRange:NSMakeRange(0, maximumRange)]];
        
        NSDictionary * stringsWithEditDistances = @{kSortInputStringKey : currentString ,
                                                    kSortObjectKey : originalObject,
                                                    kSortEditDistancesKey : [NSNumber numberWithFloat:editDistanceOfCurrentString]};
        NSLog(@"%@ %@", @(editDistanceOfCurrentString), currentString);
        [editDistances addObject:stringsWithEditDistances];
    }
    
    if(self.isCancelled){
        return [NSArray array];
    }
    
    [editDistances sortUsingComparator:^(NSDictionary *string1Dictionary,
                                         NSDictionary *string2Dictionary){
        
        return [string1Dictionary[kSortEditDistancesKey]
                compare:string2Dictionary[kSortEditDistancesKey]];
        
    }];
    
    
    
    NSMutableArray *prioritySuggestions = [NSMutableArray array];
    NSMutableArray *otherSuggestions = [NSMutableArray array];
    for(NSDictionary *stringsWithEditDistances in editDistances){
        
        if(self.isCancelled){
            return [NSArray array];
        }
        
        NSObject *autoCompleteObject = stringsWithEditDistances[kSortObjectKey];
        NSString *suggestedString = stringsWithEditDistances[kSortInputStringKey];
        
        NSArray *suggestedStringComponents = [suggestedString componentsSeparatedByString:@" "];
        BOOL suggestedStringDeservesPriority = NO;
        for(NSString *component in suggestedStringComponents){
            NSRange occurrenceOfInputString = [[component lowercaseString]
                                               rangeOfString:[inputString lowercaseString]];
            
            if (occurrenceOfInputString.length != 0 && occurrenceOfInputString.location == 0) {
                suggestedStringDeservesPriority = YES;
                [prioritySuggestions addObject:autoCompleteObject];
                break;
            }
            
            if([inputString length] <= 1){
                //if the input string is very short, don't check anymore components of the input string.
                break;
            }
        }
        
        if(!suggestedStringDeservesPriority){
            [otherSuggestions addObject:autoCompleteObject];
        }
        
    }
    
    NSMutableArray *results = [NSMutableArray array];
    [results addObjectsFromArray:prioritySuggestions];
    [results addObjectsFromArray:otherSuggestions];
    
    
    return [NSArray arrayWithArray:results];
}

- (NSArray *)sortUsingStringScoreForString:(NSString *)inputString withPossibleStrings:(NSArray *)possibleTerms
{
    NSMutableArray *scores = [NSMutableArray arrayWithCapacity:possibleTerms.count];
    
    for (NSObject *originalObject in possibleTerms) {
        NSString *currentString;
        if([originalObject isKindOfClass:[NSString class]]){
            currentString = (NSString *)originalObject;
        } else if ([originalObject conformsToProtocol:@protocol(MMAutoCompletionObject)]){
            currentString = [(id <MMAutoCompletionObject>)originalObject autoCompletionValue];
        } else {
            NSAssert(0, @"Autocompletion terms must either be strings or objects conforming to the MLPAutoCompleteObject protocol.");
        }
        
        if(self.isCancelled){
            return [NSArray array];
        }
        
        float score = 0;
        NSArray *components = [currentString componentsSeparatedByString:@" "];
        for (NSString *str in components) {
            score += [[inputString lowercaseString] scoreAgainst:[currentString lowercaseString] fuzziness:@(0.6) options:NSStringScoreOptionFavorSmallerWords];
        }
        
        NSDictionary * stringsWithScore = @{kSortInputStringKey : currentString ,
                                                    kSortObjectKey : originalObject,
                                                    kSortEditDistancesKey : [NSNumber numberWithFloat:score]};
        
        NSLog(@"%@ --> score: %f", currentString, score);
        if (score > kAutoCompleteMinimumMatchThreshold)
            [scores addObject:stringsWithScore];
    }
    
    [scores sortUsingComparator:^(NSDictionary *string1Dictionary,
                                         NSDictionary *string2Dictionary){
        
        return [string2Dictionary[kSortEditDistancesKey]
                compare:string1Dictionary[kSortEditDistancesKey]];
        
    }];
    
    NSMutableArray *results = [NSMutableArray array];
    for (NSDictionary *dict in scores) {
        [results addObject:dict[kSortObjectKey]];
    }
    
    return results;
}

- (void)dealloc
{
    [self setDelegate:nil];
    [self setIncompleteString:nil];
    [self setPossibleCompletions:nil];
}
@end
