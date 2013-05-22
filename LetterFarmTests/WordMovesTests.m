//
//  WordMovesTests.m
//  LetterFarm
//
//  Created by Daniel Mueller on 10/16/12.
//
//

#import "WordMovesTests.h"
#import "WordMovesGenerator.h"
#import "LetterWordUtilities.h"

@implementation WordMovesTests

-(void)testActa{
    
    NSSet* word4Set = [LetterWordUtilities wordsForDictionaryType:DictionaryTypePuzzle4];
    
    WordMovesGenerator* generator = [[WordMovesGenerator alloc] initWithWords:word4Set];
    
    generator.maxMoves = 10;
    generator.startWord = @"acta";
    
    [generator generate];
    
    STAssertTrue(5 < generator.maxMoves, @"Must find at least 5 moves");
}

@end
