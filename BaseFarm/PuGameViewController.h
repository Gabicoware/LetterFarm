//
//  PuGameViewController.h
//  Letter Farm
//
//  Created by Daniel Mueller on 5/24/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "LFViewController.h"

#import "BaseFarm.h"

@class PuzzleGame;

@interface PuGameViewController : LFViewController<GameViewController>

-(void)startGame:(PuzzleGame*)puzzleGame;

@property (nonatomic, assign) BOOL isCreating;

@property (weak, nonatomic, readonly) PuzzleGame* puzzleGame;

-(void)setGameCompleteMessage:(NSString*)message;

-(void)restartGame;

-(void)setGuessedWords:(NSArray*)guessedWords;

@property (nonatomic, assign) BOOL isTutorial;

@end
