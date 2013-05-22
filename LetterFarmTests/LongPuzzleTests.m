//
//  LongPuzzleTests.m
//  LetterFarm
//
//  Created by Daniel Mueller on 10/15/12.
//
//

#import "LongPuzzleTests.h"
#import "LetterWordUtilities.h"
#import "BaseFarm.h"
#import "PuzzleGenerator.h"
#import "NSArray+LF.h"

@implementation LongPuzzleTests

-(void)testPuzzleGame{
    
    NSSet* wordSet = [LetterWordUtilities wordsForDictionaryType:DictionaryTypePuzzle3];
    
    [self runPuzzlesForWordsInSet:wordSet];
    
}

-(void)runPuzzlesForWordsInSet:(NSSet*)set{
    
    
    NSMutableArray* wordsArray = [[set allObjects] mutableCopy];
    
    [wordsArray shuffle];
    
    int count= MIN([wordsArray count], 1000);
    
    for(int index = 0; index < count; index++){
        
        NSString* word = [wordsArray objectAtIndex:index];
        
        [self canCreatePuzzleWithWord:word moves:1];
    }
    
}

-(BOOL)canCreatePuzzleWithWord:(NSString*)word  moves:(int)moves{
    
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
    
    return state.endWord != nil && state.startWord != nil;
    
}

@end
