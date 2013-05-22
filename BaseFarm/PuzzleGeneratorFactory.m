//
//  PuzzleGeneratorFactory.m
//  Letter Farm
//
//  Created by Daniel Mueller on 6/14/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "PuzzleGeneratorFactory.h"
#import "WordProvider.h"

@implementation PuzzleGeneratorFactory

+(PuzzleGenerator*)newGameGeneratorForType:(DictionaryType)dictionaryType withDifficulty:(Difficulty)difficulty{
    
    return [PuzzleGeneratorFactory newGameGeneratorForWord:nil type:dictionaryType withDifficulty:difficulty];
    
}

+(PuzzleGenerator*)newGameGeneratorForWord:(NSString*)word withDifficulty:(Difficulty)difficulty{
    
    DictionaryType dictionaryType = DictionaryTypePuzzle3;
    
    if (3 <= [word length] && [word length] <= 5 ) {
        dictionaryType = (int)[word length];
    }
    
    if (dictionaryType != 0) {
        return [PuzzleGeneratorFactory newGameGeneratorForWord:word type:dictionaryType withDifficulty:difficulty];
    }else{
        return nil;
    }
    
}

+(PuzzleGenerator*)newGameGeneratorForWord:(NSString*)word type:(DictionaryType)dictionaryType withDifficulty:(Difficulty)difficulty{
    
    NSSet* puzzleWords = [[WordProvider currentWordProvider] wordsForDictionaryType:dictionaryType];
    
    PuzzleGenerator* generator = nil;
    
    if (puzzleWords != nil) {
        
        generator = [[PuzzleGenerator alloc] initWithWords:puzzleWords];
        //generator will decide a word
        generator.startWord = word;
        generator.difficulty = difficulty;
        generator.dictionaryType = dictionaryType;
        
    }
    
    return generator;

}

+(HintGenerator*)newHintGeneratorForWord:(NSString*)word finalWord:(NSString*)finalWord{
    DictionaryType dictionaryType = DictionaryTypePuzzle3;
    
    if (3 <= [word length] && [word length] <= 5 ) {
        dictionaryType = (int)[word length];
    }
    
    if (dictionaryType != 0) {
        return [PuzzleGeneratorFactory newHintGeneratorForWord:word type:dictionaryType finalWord:finalWord];
    }else{
        return nil;
    }

}

+(HintGenerator*)newHintGeneratorForWord:(NSString*)word type:(DictionaryType)dictionaryType finalWord:(NSString*)finalWord{
    
    NSSet* puzzleWords = [[WordProvider currentWordProvider] wordsForDictionaryType:dictionaryType];
    
    HintGenerator* generator = nil;
    
    if (puzzleWords != nil) {
        
        generator = [[HintGenerator alloc] initWithWords:puzzleWords];
        //generator will decide a word
        generator.startWord = word;
        generator.finalWord = finalWord;
        
    }
    
    return generator;
    
}


@end
