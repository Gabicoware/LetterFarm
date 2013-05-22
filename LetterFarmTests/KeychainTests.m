//
//  KeychainTests.m
//  LetterFarm
//
//  Created by Daniel Mueller on 9/11/12.
//
//

#import "KeychainTests.h"
#import "KeychainItemWrapper.h"
#import <Security/Security.h>
#import "LocalConfiguration.h"

#define KeychainWrapperTestsService @"KeychainWrapperTestsService"

#define KeychainStringValueData @"KeychainStringValueData"
#define KeychainDictionaryKey @"KeychainDictionaryKey"
#define KeychainDictionaryObject @"KeychainDictionaryObject"

#define Account @"LetterFarm"
#define Service @"InAppPurchases"

@implementation KeychainTests

-(NSData*)setAndRetrieveData:(NSData*)paramData{
    
    NSString* uuid = [[LocalConfiguration sharedLocalConfiguration] appUUID];
    
    {
        KeychainItemWrapper* wrapper = [[KeychainItemWrapper alloc] initWithService:KeychainWrapperTestsService account:uuid accessGroup:nil];
        
        [wrapper setObject:paramData forKey:(__bridge id)kSecValueData];
    }
    
    NSData* resultData = nil;
    
    {
        KeychainItemWrapper* wrapper = [[KeychainItemWrapper alloc] initWithService:KeychainWrapperTestsService account:uuid accessGroup:nil];
        
        resultData = [wrapper objectForKey:(__bridge id)kSecValueData];
        
        STAssertNotNil(resultData, @"The value data should not be nil");
        
        STAssertTrue([resultData length] == [paramData length], @"the length of result should equal the length of the param");
        
        
    }
    return resultData;
}

-(void)testStringKeychain{

    
    NSData* stringData = [KeychainStringValueData dataUsingEncoding:NSUTF8StringEncoding];
    NSData* resultStringData = [self setAndRetrieveData:stringData];
    
    NSString* resultString = [[NSString alloc] initWithData:resultStringData encoding:NSUTF8StringEncoding];
    
    STAssertTrue([resultString isEqualToString:KeychainStringValueData], @"the string should have the same value as when it was set");
    
}

-(void)testDictionaryKeychain{
    NSDictionary* dictionary = [NSDictionary dictionaryWithObject:KeychainDictionaryObject forKey:KeychainDictionaryKey];
    
    NSData* dictionaryData = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    NSData* resultDictionaryData = [self setAndRetrieveData:dictionaryData];
    NSDictionary* resultDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:resultDictionaryData];
    
    STAssertNotNil(resultDictionary, @"The dictionary must not be nil");
    
    BOOL isEqual = [[resultDictionary objectForKey:KeychainDictionaryKey] isEqualToString:KeychainDictionaryObject];
    STAssertTrue(isEqual, @"The values must be equal");
    
}


-(void)testZDataKeychain{
    
    int paramInt = 123456;
    
    NSData* paramData = [NSData dataWithBytes:&paramInt length:sizeof(int)];
    
    NSData* resultData = [self setAndRetrieveData:paramData];
    
    int resultInt = 0;
    
    [resultData getBytes:&resultInt length:sizeof(int)];
    
    STAssertEquals(resultInt, paramInt, @"param %d should equal result %d");
    
}


@end
