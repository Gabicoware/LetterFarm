//
//  LetterFarmMultiplayer.h
//  LetterFarm
//
//  Created by Daniel Mueller on 11/28/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

typedef enum {
    OpponentTypeNone,
#ifndef DISABLE_LOCAL
    OpponentTypeComputer, //simulates turns for an opponent
    OpponentTypePassNPlay,
#endif
#ifndef DISABLE_GK
    OpponentTypeGK,
#endif
#ifndef DISABLE_FB
    OpponentTypeFB,
#endif
#ifndef DISABLE_EMAIL
    OpponentTypeEmail,
#endif
}OpponentType;

typedef enum{
    MatchGameNone=0,
    MatchGameWon=1,
    MatchGameTied=2,
    MatchGameLost=3,
    MatchGameDraw=4,//both players forfeited
} MatchGameOutcome;

extern NSString* SelectMatchNewGame;
extern NSString* SelectMatchMutliplayer;
extern NSString* SelectMatchCompleteMutliplayer;
extern NSString* ShowMatchesMutliplayer;
extern NSString* ResendEmail;

@class MatchInfo;

@protocol MatchGame <NSObject>

//the playerID of the platform
@property (nonatomic) NSString* playerID;

@property (nonatomic) NSDate* creationDate;

@property (nonatomic) NSDate* completionDate;

@property (nonatomic, readonly) NSArray* gameWords;

-(MatchGameOutcome)outcomeAgainstGame:(id<MatchGame>)game;

@end

@protocol MatchEngine;

extern NSString* OpponentSelectedNotification;

@class UIViewController;

@protocol OpponentController

-(void)selectOpponentWithViewController:(UIViewController*)controller;

@property (nonatomic) MatchInfo* matchInfo;

@property (nonatomic) int startingDifficulty;

@property (weak, nonatomic, readonly) id<MatchEngine> matchEngine;

@end

