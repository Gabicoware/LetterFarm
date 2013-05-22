//
//  FBMatchEngine.h
//  LetterFarm
//
//  Created by Daniel Mueller on 12/12/12.
//
//

#import <Foundation/Foundation.h>
#import "MatchInfo.h"
#import "MatchEngine.h"

@class Facebook;

extern NSString* FBLocalPlayerDidAuthenticateNotification;
extern NSString* FBFriendsDidLoadNotification;

@interface FBMatchEngine : NSObject<MatchEngine>

@property (nonatomic, readonly) BOOL isFBAvailable;
@property (nonatomic, readonly) BOOL isAuthenticated;
@property (nonatomic, readonly) BOOL hasAuthenticated;

@property (nonatomic, readonly) Facebook* facebook;

@property (nonatomic) NSMutableDictionary* players;

+(id)sharedFBMatchEngine;

//!if the local user is already authenticated completionhandler will be called immediately

-(void)authenticate;

-(void)loadMatches;

-(BOOL)handleOpenURL:(NSURL*)URL;

-(void)loadFriends;

-(MatchInfo*)matchInfoWithOpponent:(id)opponent;

@property (nonatomic) NSArray* friends;

@end
