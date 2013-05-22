//
//  Analytics.m
//  LetterFarm
//
//  Created by Daniel Mueller on 8/12/12.
//
//

#import "Analytics.h"
#import "LocalConfiguration.h"

#import "GAI.h"

#ifdef ENABLE_TESTFLIGHT

#import "TestFlight.h"
#define TestFlightTeamToken @"TEST FLIGHT TOKEN HERE"

#endif

#ifdef RELEASE
#define GAID @"RELEASE GAID"
#else
#define GAID @"TESTING GAID"
#endif

@interface Analytics()

@property (nonatomic, readonly) id<GAITracker> tracker;

@end

@implementation Analytics

+(id)sharedAnalytics{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

-(BOOL)shouldTrackWithTestflight{
    return YES;
}

-(id<GAITracker>)tracker{
    if ([[LocalConfiguration sharedLocalConfiguration] isUsageTrackingDisabled]) {
        return nil;
    }else{
        return [[GAI sharedInstance] trackerWithTrackingId:GAID];
    }
}

-(void)startup{
#ifdef ENABLE_TESTFLIGHT
    if ([self shouldTrackWithTestflight]) {
        @try {
            [TestFlight takeOff:TestFlightTeamToken];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception);
        }
        @finally {}
    }
#endif
    [self.tracker setAppId:@"545019650"];
    
    GAI.sharedInstance.trackUncaughtExceptions = YES;
}

-(void)trackCategory:(NSString*)category action:(NSString*)action label:(NSString*)label value:(int)value{
    [self.tracker trackEventWithCategory:category
                              withAction:action
                               withLabel:label
                               withValue:[NSNumber numberWithInt:value]];
}

@end

@implementation NSObject(Tracking)

-(NSString*)categoryName{
    return NSStringFromClass([self class]);
}

-(void)trackScreen:(NSString*)name{
    [[[GAI sharedInstance] defaultTracker] trackView:name];
}

-(void)trackEvent:(NSString*)name{
    [[Analytics sharedAnalytics] trackCategory:[self categoryName] action:name label:name value:0];
}

@end

