//
//  PuzzleGame.h
//  Letter Farm
//
//  Created by Daniel Mueller on 5/7/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseFarm.h"
#import "LetterFarmMultiplayer.h"

@interface PuzzleGame : NSObject<NSCoding, NSCopying, MatchGame>

//the only required values for a PuzzleGame
@property (nonatomic, copy) NSString* endWord;
@property (nonatomic, copy) NSString* startWord;

@property (nonatomic) NSArray* solutionWords;

@property (nonatomic) NSArray* guessedWords;

@property (nonatomic, assign) DictionaryType dictionaryType;

@property (nonatomic) NSString* playerID;
@property (nonatomic) NSDate* completionDate;
@property (nonatomic) NSDate* creationDate;

//the total moves, including undone moves, and invalid words
@property (nonatomic) NSInteger guessCount;

@property (nonatomic, readonly) NSTimeInterval interval;

-(void)incrementGuessCount;

+(id)puzzleGameWithWords:(NSArray*)words;

@end
