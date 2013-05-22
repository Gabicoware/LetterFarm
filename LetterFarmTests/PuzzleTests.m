//
//  PuzzleTests.m
//  Letter Farm
//
//  Created by Daniel Mueller on 5/8/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "PuzzleTests.h"
#import "LetterWordUtilities.h"
#import "BaseFarm.h"
#import "PuzzleGenerator.h"

@implementation PuzzleTests

-(void)testDifferences{
    [self runDifferences:0 w1:@"chap" w2:@"chap"];
    [self runDifferences:1 w1:@"clap" w2:@"chap"];
    [self runDifferences:2 w1:@"clam" w2:@"chap"];
    [self runDifferences:3 w1:@"slam" w2:@"chap"];
    [self runDifferences:4 w1:@"slim" w2:@"chap"];
}

-(void)runDifferences:(NSInteger)d w1:(NSString*)w1 w2:(NSString*)w2{
    NSInteger ds = [LetterWordUtilities differenceBetweenWord1:w1 word2:w2];
    
    STAssertEquals(ds, d,@"expected %d differences between %@ and %@ but found %d",d,w1,w2,ds );
}

-(void)testVariedPuzzleGame{
    [self runPuzzleWord:@"ware" moves:1];
    [self runPuzzleWord:@"ware" moves:2];
    [self runPuzzleWord:@"ware" moves:3];
    [self runPuzzleWord:@"ware" moves:4];
    [self runPuzzleWord:@"ware" moves:5];
    [self runPuzzleWord:@"ware" moves:6];
    [self runPuzzleWord:@"ware" moves:7];
    
    [self runPuzzleWord:@"forth" moves:1];
    [self runPuzzleWord:@"forth" moves:2];
    [self runPuzzleWord:@"forth" moves:3];
    [self runPuzzleWord:@"forth" moves:4];
    [self runPuzzleWord:@"forth" moves:5];
    [self runPuzzleWord:@"forth" moves:6];
    [self runPuzzleWord:@"forth" moves:7];
    
    [self runPuzzleWord:@"for" moves:1];
    [self runPuzzleWord:@"for" moves:2];
    [self runPuzzleWord:@"for" moves:3];
    [self runPuzzleWord:@"for" moves:4];
    [self runPuzzleWord:@"for" moves:5];
    [self runPuzzleWord:@"for" moves:6];
    [self runPuzzleWord:@"for" moves:7];
    
}

-(void)testEveryStartPuzzleGame{
    
    NSSet* word3Set = [LetterWordUtilities wordsForDictionaryType:DictionaryTypePuzzle3];
    
    [self runPuzzleWord:@"chi" moves:1];
    
    [self runPuzzlesForWordsInSet:word3Set];
    
    NSSet* word4Set = [LetterWordUtilities wordsForDictionaryType:DictionaryTypePuzzle4];
    
    [self runPuzzlesForWordsInSet:word4Set];
    
    NSSet* word5Set = [LetterWordUtilities wordsForDictionaryType:DictionaryTypePuzzle5];
    
    [self runPuzzlesForWordsInSet:word5Set];
    
}

-(void)runPuzzlesForWordsInSet:(NSSet*)set{
    
    NSArray* wordsArray = [set allObjects];
    
    int count= [wordsArray count];
    
    for(int index = 0; index < count; index++){
        
        NSString* word = [wordsArray objectAtIndex:index];
        
        [self runPuzzleWord:word moves:1];
    }
    
}

-(void)runPuzzleWord:(NSString*)word  moves:(int)moves{
    
    DictionaryType type = DictionaryTypeNone;
    
    if (3 <= [word length] && [word length] <= 5 ) {
        type = [word length];
    }
    
    NSSet* words = [LetterWordUtilities wordsForDictionaryType:type];
    
    PuzzleGenerator* generator = [[PuzzleGenerator alloc] init];
    
    generator.dictionaryType = type;
    generator.words = words;
    generator.startWord = word;
    generator.difficulty = moves;
    
    [generator generate];
    
    PuzzleGame* state = OBJECT_IF_OF_CLASS(generator.result, PuzzleGame);
    
    STAssertNotNil(state,@"the state must not be nil for word '%@' in moves %d", word, moves);
    if (state != nil) {
        //the additional errors don't help us
        STAssertNotNil(state.endWord,@"the words must not be nil for word '%@' in moves %d", word, moves);
        
        int count = state.solutionWords.count;
        int expectedCount = moves + 1;
        
        STAssertEquals(count, expectedCount,@"the solution should have a length of moves + 1");
        
        NSString* firstWord = [state.solutionWords objectAtIndex:0];
        
        for (int index = 1; index < state.solutionWords.count; index++) {
            NSString* nextWord = [state.solutionWords objectAtIndex:index];
            
            int differences = [LetterWordUtilities differenceBetweenWord1:firstWord word2:nextWord];
            
            STAssertEquals(differences, 1, @"%@ and %@ should only be one letter different", firstWord, nextWord);
            
            firstWord = nextWord;
            
        }
    }
    
    
    
}

@end
