//
//  MMTerminalDelegate.h
//  TerminalApp
//
//  Created by Marc on 5/16/14.
//  Copyright (c) 2014 Marc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MMTerminalDelegate <NSObject>
- (NSString *)commandOutput:(NSString *)command;
@end
