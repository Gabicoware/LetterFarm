//
//  LetterWordUtilities.h
//  Letter Farm
//
//  Created by Daniel Mueller on 4/22/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BaseFarm.h"

@interface LetterWordUtilities : NSObject

//For utilities applications, when there isn't a bundle
+(void)setAlternativeBasePath:(NSString*)basePath;

+(BOOL)isValidWord:(NSString*)word;

+(NSInteger)differenceBetweenWord1:(NSString*)word1 word2:(NSString*)word2;

+(NSSet*)wordsForDictionaryType:(DictionaryType)type;

+(NSSet*)wordsForDictionaryType:(DictionaryType)type moveCount:(int)moveCount;

+(NSString*)randomWordForType:(DictionaryType)type difficulty:(Difficulty)difficulty;

+(NSMutableSet*)permutationsOfWord:(NSString*)word withLetters:(NSString*)letters;

+(BOOL)isCandidateLegal:(NSString*)candidateWord forWord:(NSString*)word onLevels:(NSSet*)levels inMoves:(int)moves;

+(NeededMove)neededMoveWithWord:(NSString*)word next:(NSString*)nextWord;

@end
