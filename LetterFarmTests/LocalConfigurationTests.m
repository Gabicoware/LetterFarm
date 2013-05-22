//
//  LocalConfigurationTests.m
//  LetterFarm
//
//  Created by Daniel Mueller on 9/6/12.
//
//

#import "LocalConfigurationTests.h"

#import "LocalConfiguration.h"

@implementation LocalConfigurationTests

-(void)testBuildVersion{
    
    int ver = [[LocalConfiguration sharedLocalConfiguration] buildVersion];
    
    NSString* ltver = [NSString stringWithFormat:@"%d",ver-1];
    
    int comp_0 = [[LocalConfiguration sharedLocalConfiguration] compareToBuildVersion:ltver];
    
    STAssertEquals(comp_0, -1, @"The comparision should be less than");
    
    NSString* eqver = [NSString stringWithFormat:@"%d",ver];
    
    int comp_1 = [[LocalConfiguration sharedLocalConfiguration] compareToBuildVersion:eqver];
    
    STAssertEquals(comp_1, 0, @"The comparision should be equal");
    
    NSString* gtver = [NSString stringWithFormat:@"%d",ver+1];
    
    int comp__1 = [[LocalConfiguration sharedLocalConfiguration] compareToBuildVersion:gtver];
    
    STAssertEquals(comp__1, 1, @"The comparision should be greater than");
    
}


-(void)testAppUUID{
    
    NSString* uuid = [[LocalConfiguration sharedLocalConfiguration] appUUID];
    
    STAssertNotNil(uuid, @"the uuid must not be nil");
    
    NSString* uuid2 = [[LocalConfiguration sharedLocalConfiguration] appUUID];
    
    STAssertTrue([uuid isEqualToString:uuid2], @"the uuid must be equal to the second read of the property");
}


@end
