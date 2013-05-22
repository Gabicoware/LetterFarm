//
//  SimpleEncrypt.m
//  LetterFarm
//
//  Created by Daniel Mueller on 10/11/12.
//
//

#import "SimpleEncrypt.h"
#import "NSString+LF.h"

//0-9
//&=
//a-z

//total = 38

//encoding values = A-Z a-l

#define SOURCE @"0123456789abcdefghijklmnopqrstuvwxyz&=,"
#define ENCRYPT @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklm"

@implementation SimpleEncrypt

+(NSString*)encrypt:(NSString*)target{
    NSArray* sourceLetters = [SOURCE letters];
    NSArray* encryptLetters = [ENCRYPT letters];
    
    NSMutableString* mResult = [NSMutableString stringWithCapacity:[target length]];
    
    for (NSString* targetLetter in [target letters]) {
        NSInteger index = [sourceLetters indexOfObject:targetLetter];
        NSString* encryptLetter = [encryptLetters objectAtIndex:index];
        [mResult appendString:encryptLetter];
    }
    
    return [NSString stringWithString:mResult];
}

+(NSString*)decrypt:(NSString*)target{
    NSArray* encryptLetters = [ENCRYPT letters];
    NSArray* sourceLetters = [SOURCE letters];
    
    NSMutableString* mResult = [NSMutableString stringWithCapacity:[target length]];
    
    for (NSString* targetLetter in [target letters]) {
        NSInteger index = [encryptLetters indexOfObject:targetLetter];
        NSString* encryptLetter = [sourceLetters objectAtIndex:index];
        [mResult appendString:encryptLetter];
    }
    
    return [NSString stringWithString:mResult];
}

@end
