//
//  WordProvider.h
//  LetterFarm
//
//  Created by Daniel Mueller on 4/2/13.
//
//


#import <Foundation/Foundation.h>
#import "BaseFarm.h"

//this is currently a bit of a mess, but it works, so I'm not going to argue with it too much.

#if defined( LETTER_WORD )
    #define DefaultWordProviderType WordProviderTypeLetter
#elif defined( COLOR_WORD )
    #define DefaultWordProviderType WordProviderTypeColor
#else
    #define DefaultWordProviderType WordProviderTypeNone
#endif

typedef enum{
    WordProviderTypeNone,
#ifdef LETTER_WORD
    WordProviderTypeLetter,
#endif
#ifdef COLOR_WORD
    WordProviderTypeColor,
#endif
} WordProviderType;

@interface WordProvider : NSObject

-(void)setAlternativeBasePath:(NSString*)basePath;

-(NSMutableSet*)permutationsOfWord:(NSString*)word;

-(BOOL)isValidWord:(NSString*)word;

@property (nonatomic, readonly) WordProviderType type;

-(NSSet*)wordsForDictionaryType:(DictionaryType)type;

-(BOOL)isCandidateLegal:(NSString*)candidateWord forWord:(NSString*)word onLevels:(NSSet*)levels inMoves:(int)moves;

-(NSArray*)solutionWithWords:(NSArray*)words;

-(NeededMove)neededMoveWithWord:(NSString*)word next:(NSString*)nextWord;

-(NSString*)randomWordForType:(DictionaryType)type difficulty:(Difficulty)difficulty;

+(WordProvider*)wordProviderOfType:(WordProviderType)type;

+(WordProvider*)currentWordProvider;


@end
