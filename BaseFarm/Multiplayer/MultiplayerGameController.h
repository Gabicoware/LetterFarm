//
//  MultiplayerGameController.h
//  LetterFarm
//
//  Created by Daniel Mueller on 11/29/12.
//
//

#import "GameController.h"
#import "LetterFarmMultiplayer.h"

@interface MultiplayerGameController : GameController

-(void)showMatchInfo:(MatchInfo*)matchInfo;

#ifndef DISABLE_GK

-(void)showGKOpponentControllerWithPlayers:(NSArray*)players;

#endif

@end