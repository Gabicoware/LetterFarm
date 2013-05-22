//
//  Arguments.h
//  LetterFarm
//
//  Created by Daniel Mueller on 10/15/12.
//
//

#import <Foundation/Foundation.h>

@interface Arguments : NSObject

+(NSString*)argumentValueWithName:(NSString*)argumentName;

+(BOOL)hasArgumentWithName:(NSString*)argumentName;

@end
