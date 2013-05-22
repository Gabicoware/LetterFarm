//
//  PuzzleGeneratorFactory.h
//  Letter Farm
//
//  Created by Daniel Mueller on 6/14/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PuzzleGenerator.h"
#import "HintGenerator.h"

@interface PuzzleGeneratorFactory : NSObject

+(PuzzleGenerator*)newGameGeneratorForWord:(NSString*)word withDifficulty:(Difficulty)difficulty;

+(PuzzleGenerator*)newGameGeneratorForType:(DictionaryType)dictionaryType withDifficulty:(Difficulty)difficulty;

+(HintGenerator*)newHintGeneratorForWord:(NSString*)word finalWord:(NSString*)finalWord;

@end
