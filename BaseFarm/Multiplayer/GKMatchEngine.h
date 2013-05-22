//
//  GKMatchEngine.h
//  LetterFarm
//
//  Created by Daniel Mueller on 7/14/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "MatchInfo.h"
#import "MatchEngine.h"

extern NSString* GKLocalPlayerDidAuthenticateNotification;
extern NSString* GKHandleInviteNotification;
extern NSString* GKHandleInvitePlayersToInviteKey;

@interface GKMatchEngine : NSObject<MatchEngine, GKTurnBasedEventHandlerDelegate>

@property (nonatomic, readonly) BOOL isAuthenticated;
@property (nonatomic, readonly) BOOL hasAuthenticated;

@property (nonatomic) NSMutableDictionary* players;

+(id)sharedGKMatchEngine;

//!if the local user is already authenticated completionhandler will be called immediately

-(void)authenticate;

-(void)loadMatches;

-(void)loadDataForMatch:(MatchInfo*)match withCompletionHandler:(void (^)(BOOL finished))completionHandler;

@end
