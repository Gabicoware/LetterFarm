//
//  LFMatch.h
//  LetterFarm
//
//  Created by Daniel Mueller on 7/20/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LetterFarmMultiplayer.h"

typedef enum{
    MatchStatusNone,
    MatchStatusYourTurn,
    MatchStatusTheirTurn,
    MatchStatusYouWon,
    MatchStatusTheyWon,
    MatchStatusTied,
    MatchStatusYouQuit,
    MatchStatusTheyQuit,
    MatchStatusInvalid
} MatchStatus;

#define MatchStatusIsComplete(status)(status != MatchStatusNone && status != MatchStatusYourTurn && status != MatchStatusTheirTurn )

@interface MatchInfo : NSObject

//This is typically that data from which this object is derived, and is held here for convenience
@property (nonatomic) id sourceData;

@property (nonatomic) OpponentType opponentType;

@property (nonatomic) MatchStatus status;

@property (nonatomic, readonly) int roundCount;

@property (nonatomic) int startingDifficulty;
//the typical structure of a matchID is {opponentType}{matchID}
@property (nonatomic) NSString* matchID;
@property (nonatomic) NSString* opponentID;
@property (nonatomic) NSString* opponentName;

@property (nonatomic) NSString* tileViewLetter; //E, E, ?

@property (nonatomic) NSDate* createdDate;
@property (nonatomic) NSDate* updatedDate;

@property (nonatomic) NSArray* games;

@property (nonatomic, readonly) BOOL hasData;

@property (nonatomic) id<MatchGame> currentGame;

@end
