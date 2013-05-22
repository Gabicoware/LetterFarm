//
//  StringTests.m
//  Letter Farm
//
//  Created by Daniel Mueller on 6/19/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "StringTests.h"
#import "NSString+LF.h"

@implementation StringTests

-(void)testNumericValue{
    unsigned long a_val = [@"a" numericValue];
    unsigned long A_val = [@"A" numericValue];
    
    STAssertEquals(a_val, A_val,@"a and A should have the same numeric value");
    STAssertEquals(a_val, (unsigned long)1,@"a should have a numeric value of 0");
    
    unsigned long b_val = [@"b" numericValue];
    unsigned long B_val = [@"B" numericValue];
    
    STAssertEquals(b_val, B_val,@"b and B should have the same numeric value");
    STAssertEquals(b_val, (unsigned long)2,@"b should have a numeric value of 2");
    
    unsigned long aa_val = [@"aa" numericValue];
    STAssertEquals(aa_val, (unsigned long)27,@"aa should have a numeric value of 27");
    
    unsigned long aaaa_val = [@"aaaa" numericValue];
    STAssertEquals(aaaa_val, (unsigned long)18279,@"aaaa should have a numeric value of 475254");
    
    
}

@end
