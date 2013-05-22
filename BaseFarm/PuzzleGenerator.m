//
//  PuzzleGenerator.m
//  Letter Farm
//
//  Created by Daniel Mueller on 6/7/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

// This category enhances NSMutableArray by providing
// methods to randomly shuffle the elements.


#import "PuzzleGenerator.h"
#import "WordProvider.h"
#import "NSArray+LF.h"

@interface PuzzleGenerator ()

-(NSMutableArray*)generatePuzzleWithWord:(NSString*)word inMoves:(int)moves;

@end

@implementation PuzzleGenerator

@synthesize difficulty=_difficulty, startWord=_startWord, dictionaryType=_dictionaryType;




-(id)generateResult{
    
    NSMutableArray* puzzle = nil;
    
    int moves = MovesWithDifficulty(self.difficulty);
    
    if (self.startWord == nil) {
        
        //try to create a puzzle 3 times, but quit after that
        for (int attempt = 0; (attempt < 5 && puzzle == nil); attempt++) {
            self.startWord = [[WordProvider currentWordProvider] randomWordForType:self.dictionaryType difficulty:self.difficulty];
            puzzle = [self generatePuzzleWithWord:self.startWord inMoves:moves];
        }
        
    }else{
        
        //if we've been given a word, generate the puzzle whether it creates one or not
        puzzle = [self generatePuzzleWithWord:self.startWord inMoves:moves];
        
    }
    
    
    
    PuzzleGame* result = nil;
    
    if (puzzle != nil && 1 < [puzzle count]) {
        
        NSArray* solution = [[WordProvider currentWordProvider] solutionWithWords:puzzle];
        
        result = [PuzzleGame new];
        
        result.creationDate = [NSDate date];
        result.endWord = [solution lastObject];
        result.startWord = [solution objectAtIndex:0];
        result.solutionWords = solution;
        result.guessedWords = [NSArray arrayWithObject:result.startWord];
        result.dictionaryType = self.dictionaryType;
        
        
    }
    return result;
}

-(NSMutableArray*)generatePuzzleWithWord:(NSString*)word inMoves:(int)moves{
    
    
    self.levelsDictionary = [NSMutableDictionary dictionary];
    self.sourcesDictionary = [NSMutableDictionary dictionary];
    
    NSSet* currentLevelWords = [NSSet setWithObject:word];
    
    for (int move = 0; move < moves; move++) {
        
        currentLevelWords = [self wordsForMove:move currentWords:currentLevelWords];
    }
    
    NSMutableArray* candidateFinalWords = [NSMutableArray array];
    
    for (NSString* candidateWord in currentLevelWords) {
        
        BOOL shouldAdd = [self isCandidateLegal:candidateWord forWord:word inMoves:moves];
        
        if (shouldAdd) {
            [candidateFinalWords addObject:candidateWord];
        }
        
    }

    [candidateFinalWords shuffle];
    
    NSString* result = [candidateFinalWords lastObject];
    
    NSMutableArray* resultArray = [self resultWordsWithStart:word finish:result moves:moves];
        
    return resultArray;
    
}

@end
