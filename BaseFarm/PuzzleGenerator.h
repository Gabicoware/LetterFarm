//
//  PuzzleGenerator.h
//  Letter Farm
//
//  Created by Daniel Mueller on 6/7/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "BaseGenerator.h"
#import "BaseFarm.h"
#import "PuzzleGame.h"

@interface PuzzleGenerator : BaseGenerator

@property (nonatomic, copy) NSString* startWord;

@property (nonatomic, assign) DictionaryType dictionaryType;
@property (nonatomic, assign) Difficulty difficulty;
//@property (nonatomic, assign) int moves;

@end
