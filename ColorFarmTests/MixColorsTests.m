//
//  MixColorsTests.m
//  LetterFarm
//
//  Created by Daniel Mueller on 4/10/13.
//
//

#import "MixColorsTests.h"
#import "ColorWordUtilities.h"
#import "STAssertsEqualStrings.h"

@implementation MixColorsTests

-(void)testMixColors{
    
    [self checkMixColor:@"o" m:@"r" t:@"r"];
    [self checkMixColor:@"o" m:@"o" t:@"o"];
    [self checkMixColor:@"o" m:@"y" t:@"y"];
    [self checkMixColor:@"o" m:@"g" t:@"y"];
    [self checkMixColor:@"o" m:@"b" t:@"w"];
    [self checkMixColor:@"o" m:@"p" t:@"r"];
    
    [self checkMixColor:@"y" m:@"r" t:@"o"];
    [self checkMixColor:@"y" m:@"o" t:@"o"];
    [self checkMixColor:@"y" m:@"y" t:@"y"];
    [self checkMixColor:@"y" m:@"g" t:@"g"];
    [self checkMixColor:@"y" m:@"b" t:@"g"];
    [self checkMixColor:@"y" m:@"p" t:@"w"];
    
    [self checkMixColor:@"g" m:@"r" t:@"w"];
    [self checkMixColor:@"g" m:@"o" t:@"y"];
    [self checkMixColor:@"g" m:@"y" t:@"y"];
    [self checkMixColor:@"g" m:@"g" t:@"g"];
    [self checkMixColor:@"g" m:@"b" t:@"b"];
    [self checkMixColor:@"g" m:@"p" t:@"b"];
    
    [self checkMixColor:@"b" m:@"r" t:@"p"];
    [self checkMixColor:@"b" m:@"o" t:@"w"];
    [self checkMixColor:@"b" m:@"y" t:@"g"];
    [self checkMixColor:@"b" m:@"g" t:@"g"];
    [self checkMixColor:@"b" m:@"b" t:@"b"];
    [self checkMixColor:@"b" m:@"p" t:@"p"];
    
    [self checkMixColor:@"p" m:@"r" t:@"r"];
    [self checkMixColor:@"p" m:@"o" t:@"r"];
    [self checkMixColor:@"p" m:@"y" t:@"w"];
    [self checkMixColor:@"p" m:@"g" t:@"b"];
    [self checkMixColor:@"p" m:@"b" t:@"b"];
    [self checkMixColor:@"p" m:@"p" t:@"p"];
    
    [self checkMixColor:@"r" m:@"r" t:@"r"];
    [self checkMixColor:@"r" m:@"o" t:@"o"];
    [self checkMixColor:@"r" m:@"y" t:@"o"];
    [self checkMixColor:@"r" m:@"g" t:@"w"];
    [self checkMixColor:@"r" m:@"b" t:@"p"];
    [self checkMixColor:@"r" m:@"p" t:@"p"];
    
    [self checkMixColor:@"w" m:@"r" t:@"r"];
    [self checkMixColor:@"w" m:@"o" t:@"o"];
    [self checkMixColor:@"w" m:@"y" t:@"y"];
    [self checkMixColor:@"w" m:@"g" t:@"g"];
    [self checkMixColor:@"w" m:@"b" t:@"b"];
    [self checkMixColor:@"w" m:@"p" t:@"p"];
}

-(void)checkMixColor:(NSString*)i m:(NSString*)m t:(NSString*)t{
    
    NSString* mixedColor = MixColors(i, m);
    
    STAssertEqualStrings(mixedColor, t, @"i(%@) + m(%@) should be t(%@)",i,m,t);
    
}

@end
