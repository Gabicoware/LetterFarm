//
//  MatchInfo+Puzzle.m
//  LetterFarm
//
//  Created by Daniel Mueller on 7/31/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "MatchInfo+Puzzle.h"
#import "PuzzleGame.h"

@implementation MatchInfo (Puzzle)

-(BOOL)canFinishPuzzleMatch{
    BOOL canFinish = NO;
    
    if (self.games.count%2 == 0 && 0 < self.games.count) {
        NSInteger lastGameIndex = self.games.count - 1;
        
        PuzzleGame* gameN = [self.games objectAtIndex:lastGameIndex];
        PuzzleGame* gameN_1 = [self.games objectAtIndex:lastGameIndex - 1];
        
        canFinish = [gameN outcomeAgainstGame:gameN_1] != MatchGameTied;
        //I don't think this has a purpose
        /*
        if (!canFinish && 4 <= self.games.count) {
            PuzzleGame* gameN_2 = [self.games objectAtIndex:lastGameIndex - 2];
            PuzzleGame* gameN_3 = [self.games objectAtIndex:lastGameIndex - 3];
            
            canFinish = gameN.guessedWords == 0 && gameN_1.guessedWords == 0 && gameN_2.guessedWords == 0 && gameN_3.guessedWords == 0;
            
        }
        */
    }
    
    return canFinish;
}

-(void)finishPuzzleMatch{
    
    MatchStatus status = MatchStatusNone;
    
    if (self.games.count%2 == 0 && 0 < self.games.count) {
        NSInteger lastGameIndex = self.games.count - 1;
        
        PuzzleGame* gameN = [self.games objectAtIndex:lastGameIndex];
        PuzzleGame* gameN_1 = [self.games objectAtIndex:lastGameIndex - 1];
        
        MatchGameOutcome outcome = [gameN outcomeAgainstGame:gameN_1];
        
        switch (outcome) {
            case MatchGameNone:
            case MatchGameTied:
                NSAssert(NO, @"A finishing game should not be none or tied");
                break;
            case MatchGameWon:
                //if gameN is us
                if (![gameN.playerID isEqualToString:[self opponentID]]) {
                    status = MatchStatusYouWon;
                }else{
                    status = MatchStatusTheyWon;
                }
                
                break;
            case MatchGameLost:
                //if gameN is us
                if (![gameN.playerID isEqualToString:[self opponentID]]) {
                    status = MatchStatusTheyWon;
                }else{
                    status = MatchStatusYouWon;
                }
                
                break;
            case MatchGameDraw:
                status = MatchStatusTied;
                break;
                
        }
        
        
        
    }
    
    self.status = status;
}

+(int)currentDifficultyWithMin:(int)min games:(NSArray*)games{
    int result = MAX(min, 3);
    PuzzleGame* puzzleGame = OBJECT_IF_OF_CLASS([games lastObject], PuzzleGame);
    
    if (puzzleGame != nil) {
        result = puzzleGame.solutionWords.count - 1;
    }
    return result;
}


@end
