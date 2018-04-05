//
//  MMAutoCompleteFetchOperationDelegate.h
//  search
//
//  Created by Marc on 4/30/14.
//
//

#import <Foundation/Foundation.h>

@protocol MMAutoCompleteFetchOperationDelegate <NSObject>
- (void)autoCompleteTermsDidFetch:(NSDictionary *)fetchInfo;
@end
