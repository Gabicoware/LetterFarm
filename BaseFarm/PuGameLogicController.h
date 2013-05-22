//
//  PuGameLogicController.h
//  Letter Farm
//
//  Created by Daniel Mueller on 5/27/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PuzzleGame.h"

typedef enum _PuzzleLogicState{
    PuzzleLogicStateNone,
    PuzzleLogicStateSolving,
    PuzzleLogicStateComplete,
    
}PuzzleLogicState;

@interface PuGameLogicController : NSObject

-(id)initWithState:(PuzzleGame*)puzzleGame;

-(BOOL)canUndo;

-(PuzzleLogicState)undo;

-(BOOL)canMoveToWord:(NSString*)word;

-(PuzzleLogicState)moveToWord:(NSString*)word;

@property (nonatomic) PuzzleGame* puzzleGame;

-(void)restart;

@end
