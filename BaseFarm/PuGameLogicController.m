//
//  PuGameLogicController.m
//  Letter Farm
//
//  Created by Daniel Mueller on 5/27/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "PuGameLogicController.h"
#import "WordProvider.h"
@implementation PuGameLogicController


@synthesize puzzleGame=_puzzleGame;


-(id)initWithState:(PuzzleGame*)puzzleGame{
    if((self = [super init])){
        self.puzzleGame = puzzleGame;
    }
    return self;
}

-(BOOL)canUndo{
    return 1 < self.puzzleGame.guessedWords.count;
}

-(PuzzleLogicState)undo{
    
    NSArray* subArray = [self.puzzleGame.guessedWords subarrayWithRange:NSMakeRange(0, self.puzzleGame.guessedWords.count-1)];
    
    self.puzzleGame.guessedWords = subArray;
    return PuzzleLogicStateSolving;
}


-(BOOL)canMoveToWord:(NSString*)word{
    
    BOOL isValid = [[WordProvider currentWordProvider] isValidWord:word];
    NSString* lastGuessedWord = [self.puzzleGame.guessedWords lastObject];
    BOOL isNotTheSameWord = ![word isEqualToString:lastGuessedWord] ;
    BOOL hasNotSolvedTheGame = ![self.puzzleGame.endWord isEqualToString:lastGuessedWord];
    
    return isValid && isNotTheSameWord && hasNotSolvedTheGame;
    
}

-(PuzzleLogicState)moveToWord:(NSString*)word{
    
    PuzzleLogicState logicState = PuzzleLogicStateNone;
    
    self.puzzleGame.guessedWords = [self.puzzleGame.guessedWords arrayByAddingObject:word];
    
    if ([word isEqualToString:self.puzzleGame.endWord]) {
        logicState = PuzzleLogicStateComplete;
    }else{
        logicState = PuzzleLogicStateSolving;
    }
    
    return logicState;
}

-(void)restart{
    self.puzzleGame.guessedWords = [self.puzzleGame.guessedWords subarrayWithRange:NSMakeRange(0, 1)];
}
@end
