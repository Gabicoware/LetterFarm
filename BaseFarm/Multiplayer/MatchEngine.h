//
//  MatchEngine.h
//  LetterFarm
//
//  Created by Daniel Mueller on 7/23/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* MatchEngineSelectMatchNotification;
extern NSString* MatchesDidLoadNotification;
extern NSString* MatchDidUpdateNotification;
extern NSString* MatchDidUpdateMatchKey;

@class MatchInfo;

@protocol MatchEngine <NSObject>

@property (nonatomic, readonly) NSString* playerID;

@property (nonatomic) NSMutableDictionary* allMatches;

@property (nonatomic, readonly) BOOL isAvailable;

@property (nonatomic, readonly) BOOL doesNeedReachability;

-(void)loadMatches;

//returns yes when UI is required
-(BOOL)endTurnInMatch:(MatchInfo*)match;

//completes the match, the match status should be appropriately set when calling this
//returns yes when UI is required
-(BOOL)completeMatch:(MatchInfo*)match;

-(void)quitMatch:(MatchInfo*)match;

-(void)deleteMatch:(MatchInfo*)match;

//save the current state of the match
-(void)saveMatch:(MatchInfo*)match;

-(BOOL)canPlayWithMatchInfo:(MatchInfo*)matchInfo;

-(void)loadMatchInfoWithSourceData:(id)sourceData completionHandler:( void (^) (MatchInfo* matchInfo))completionHandler;

@optional
//for when the UI from endTurn or completeMatch occurs
//This will only be used when UI is required for completion of a game
-(void)setCompletionBlock:(void(^)(void))completion;

@end
