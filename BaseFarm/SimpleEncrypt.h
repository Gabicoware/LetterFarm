//
//  SimpleEncrypt.h
//  LetterFarm
//
//  Created by Daniel Mueller on 10/11/12.
//
//

#import <Foundation/Foundation.h>

@interface SimpleEncrypt : NSObject

+(NSString*)encrypt:(NSString*)source;
+(NSString*)decrypt:(NSString*)source;

@end
