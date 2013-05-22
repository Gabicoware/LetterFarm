//
//  MatchListMediator.m
//  LetterFarm
//
//  Created by Daniel Mueller on 7/22/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "MatchListMediator.h"
#ifndef DISABLE_GK
#import "GKMatchEngine.h"
#endif
#import "ComputerMatchEngine.h"
#ifndef DISABLE_EMAIL
#import "EmailMatchEngine.h"
#endif
#import "PassNPlayMatchEngine.h"
#import "MatchInfo.h"
#import "Reachability+LF.h"
#import "NSObject+Notifications.h"

@interface MatchListMediator ()

@end

@implementation MatchListMediator

@synthesize component=_component;

+(id)sharedMatchListMediator{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;

}

-(id)init{
    if ((self = [super init])) {
        
        NSDictionary* notifications = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"handleMatchesDidLoadNotification:",MatchesDidLoadNotification,
                                       @"handleReachabilityChangedNotification:",kReachabilityChangedNotification,
                                       nil];
        
        [self observeNotifications:notifications];
        
#ifndef DISABLE_GK
        if([[GKMatchEngine sharedGKMatchEngine] hasAuthenticated]){
            [[GKMatchEngine sharedGKMatchEngine] authenticate];
        }
#endif
        
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setComponent:(id<MatchListComponent>)component{
    _component = component;
    [_component setMediator:self];
    [self updateAggregatedMatches];
}

-(void)reloadMatches{
#ifndef DISABLE_EMAIL
    [[EmailMatchEngine sharedEmailMatchEngine] loadMatches];
#endif
    [[ComputerMatchEngine sharedComputerMatchEngine] loadMatches];
    [[PassNPlayMatchEngine sharedPassNPlayMatchEngine] loadMatches];
#ifndef DISABLE_GK
    [[GKMatchEngine sharedGKMatchEngine] loadMatches];
#endif
}

-(void)handleMatchesDidLoadNotification:(NSNotification*)notification{
    [self updateAggregatedMatches];
}

-(void)updateAggregatedMatches{
    
    NSArray* engines = @[
#ifndef DISABLE_GK
    [GKMatchEngine sharedGKMatchEngine],
#endif
#ifndef DISABLE_EMAIL
    [EmailMatchEngine sharedEmailMatchEngine],
#endif
    [PassNPlayMatchEngine sharedPassNPlayMatchEngine],
    [ComputerMatchEngine sharedComputerMatchEngine],
    ];
    NSMutableArray * matches = [NSMutableArray array];
    
    for (id<MatchEngine> engine in engines) {
        
        if ([engine isAvailable]) {
            NSArray* engineMatches = [[engine allMatches] allValues];
            if (engineMatches != nil && 0 < [engineMatches count]) {
                [matches addObjectsFromArray:engineMatches];
            }
        }
        
    }
    
    NSArray* sortedMatches = [matches sortedArrayUsingComparator:^NSComparisonResult(MatchInfo* matchinfo1, MatchInfo* matchinfo2) {
        
        NSComparisonResult result = NSOrderedSame;
        
        NSTimeInterval interval = 0;
        //this is a non critical comparison, so we can try it.
        @try {
            interval = [[matchinfo1 updatedDate] timeIntervalSinceDate:[matchinfo2 updatedDate]];
        }
        @catch (NSException *exception) {}
        @finally {}
        
        //this is not a likely scenario
        if (interval == 0) {
            BOOL has1 = [matchinfo1 isKindOfClass:[MatchInfo class]] && [matchinfo1 updatedDate] != nil;
            BOOL has2 = [matchinfo2 isKindOfClass:[MatchInfo class]] && [matchinfo2 updatedDate] != nil;
            
            if (has1 && !has2) {
                result = NSOrderedAscending;
            }else if(!has1 && has2){
                result = NSOrderedDescending;
            }
            
        }else if(0 < interval){
            result = NSOrderedAscending;
        }else if(interval < 0){
            result = NSOrderedDescending;
        }
        return result;
    }];
    
    [[self component] updateMatches:sortedMatches];
    
}

-(void)handleReachabilityChangedNotification:(NSNotification*)notification{
#ifndef DISABLE_GK
    if ([[Reachability sharedReachability] currentReachabilityStatus] != NotReachable && [[GKMatchEngine sharedGKMatchEngine] allMatches] == nil) {
        [[GKMatchEngine sharedGKMatchEngine] loadMatches];
    }
#endif
    [[self component] setIsNetworkReachable:YES];
}

-(id<MatchEngine>)matchEngineForOpponent:(OpponentType)opponent{
    id<MatchEngine> matchEngine = nil;
    switch (opponent) {
#ifndef DISABLE_GK
        case OpponentTypeGK:
            matchEngine = [GKMatchEngine sharedGKMatchEngine];
            break;
#endif
#ifndef DISABLE_LOCAL
        case OpponentTypeComputer:
            matchEngine = [ComputerMatchEngine sharedComputerMatchEngine];
            break;
        case OpponentTypePassNPlay:
            matchEngine = [PassNPlayMatchEngine sharedPassNPlayMatchEngine];
            break;
#endif
#ifndef DISABLE_EMAIL
        case OpponentTypeEmail:
            matchEngine = [EmailMatchEngine sharedEmailMatchEngine];
            break;
#endif
        default:
            break;
    }
    return matchEngine;
}

-(void)quitMatch:(MatchInfo*)match{
    
    [[self matchEngineForOpponent:match.opponentType] quitMatch:match];
    
}

-(void)deleteMatch:(MatchInfo*)match{
    
    [[self matchEngineForOpponent:match.opponentType] deleteMatch:match];
}


-(void)loadDataForMatch:(MatchInfo*)match withCompletionHandler:(void (^)(BOOL finished))completionHandler{
    switch (match.opponentType) {
#ifndef DISABLE_GK
        case OpponentTypeGK:
            [[GKMatchEngine sharedGKMatchEngine] loadDataForMatch:match withCompletionHandler:completionHandler];
            break;
#endif
        default:
            break;
    }
}

@end
