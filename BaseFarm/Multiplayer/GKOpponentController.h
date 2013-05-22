//
//  GKOpponentController.h
//  LetterFarm
//
//  Created by Daniel Mueller on 7/13/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "LetterFarmMultiplayer.h"

@interface GKOpponentController : NSObject <GKTurnBasedMatchmakerViewControllerDelegate, OpponentController>

-(void)selectOpponentWithViewController:(UIViewController*)controller players:(NSArray*)players;

@end
