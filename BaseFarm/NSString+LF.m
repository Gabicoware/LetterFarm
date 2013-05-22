//
//  NSString+LF.m
//  Letter Farm
//
//  Created by Daniel Mueller on 4/25/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//


#import "NSString+LF.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString(LF)

-(NSArray*)letters{
    
    NSMutableArray* mutableLetters = [[NSMutableArray alloc] initWithCapacity:[self length]];
    
    for (int index = 0; index < [self length]; index++) {
        NSString* character = [self substringWithRange:NSMakeRange(index, 1)];
        
        [mutableLetters addObject:character];
    }
    NSArray* result = [NSArray arrayWithArray:mutableLetters];
    
    return result;
}

-(NSString*)letterAtIndex:(NSInteger)index{
    NSString* letter= nil;
    
    if (0 <= index && index < self.length) {
        letter = [self substringWithRange:NSMakeRange(index, 1)];
    }
    
    return letter;
}

-(unsigned long)numericValue{
    
    NSArray* letters = [[self lowercaseString] letters];
    
    unsigned long result = 0;
    
    for(int index = 0; index < [letters count]; index++){
        
        NSString* letter = [letters objectAtIndex:index];
        
        unichar indexChar = [letter characterAtIndex:0];
        
        int exp = (int)[letters count] - index - 1;
        
        unsigned long indexValue = (((int)indexChar) - 96)*pow( 26.0, exp);
        
        result += indexValue;
        
    }
    
    return result;
}

@end

@implementation NSString (MD5HexDigest)

- (NSString*)md5HexDigest {
    const char* str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (uint)strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}
@end
