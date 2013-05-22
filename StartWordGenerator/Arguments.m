//
//  Arguments.m
//  LetterFarm
//
//  Created by Daniel Mueller on 10/15/12.
//
//

#import "Arguments.h"

@implementation Arguments

+(NSString*)argumentValueWithName:(NSString*)argumentName{
    
    NSString* result = nil;
    
    for (NSString* argument in [[NSProcessInfo processInfo] arguments]) {
        if ([argument rangeOfString:argumentName].location == 0) {
            
            NSRange equalRange = [argument rangeOfString:@"="];
            
            if (equalRange.location != NSNotFound) {
                result = [argument substringFromIndex:(equalRange.location + equalRange.length)];
            }
        }
    }
    
    return result;
    
}

+(BOOL)hasArgumentWithName:(NSString*)argumentName{
    BOOL result = NO;
    
    for (NSString* argument in [[NSProcessInfo processInfo] arguments]) {
        if ([argument rangeOfString:argumentName].location == 0) {
            result = YES;
        }
    }
    
    return result;
}

@end
