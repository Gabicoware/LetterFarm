//
//  WordProvider.m
//  LetterFarm
//
//  Created by Daniel Mueller on 4/2/13.
//
//

#import "WordProvider.h"

#ifdef COLOR_WORD
#import "ColorWordUtilities.h"
#define ALPHABET @"yorpbg"
#define ALPHABET_LENGTH 6
#endif
#ifdef LETTER_WORD
#import "LetterWordUtilities.h"
#define ALPHABET @"abcdefghijklmnopqrstuvwxyz"
#define ALPHABET_LENGTH 26
#endif

@interface ColorWordProvider : WordProvider

@end

@interface LetterWordProvider : WordProvider

@end

@implementation WordProvider

@synthesize type=_type;

-(id)initWithType:(WordProviderType)type{
    if((self = [super init])){
        _type = type;
    }
    return self;
}

+(WordProvider*)currentWordProvider{
    WordProviderType type = DefaultWordProviderType;
    
    return [WordProvider wordProviderOfType:type];
}

+(WordProvider*)wordProviderOfType:(WordProviderType)type{
#ifdef COLOR_WORD
    if (type == WordProviderTypeColor) {
        static dispatch_once_t pred = 0;
        __strong static id _sharedColorObject = nil;
        dispatch_once(&pred, ^{
            _sharedColorObject = [[ColorWordProvider alloc] initWithType:type];
        });
        return _sharedColorObject;
    }else
#endif
#ifdef LETTER_WORD
    if (type == WordProviderTypeLetter) {
        static dispatch_once_t pred = 0;
        __strong static id _sharedLetterObject = nil;
        dispatch_once(&pred, ^{
            _sharedLetterObject = [[LetterWordProvider alloc] initWithType:type];
        });
        return _sharedLetterObject;
    }else
#endif
    {}
    return nil;
}

-(void)setAlternativeBasePath:(NSString*)basePath{
}

-(NSArray*)solutionWithWords:(NSArray*)words{
    return nil;
}

-(NSMutableSet*)permutationsOfWord:(NSString *)word{
    return nil;
}

-(BOOL)isValidWord:(NSString*)word{
    return NO;
}

-(BOOL)isCandidateLegal:(NSString*)candidateWord forWord:(NSString*)word onLevels:(NSSet*)levels inMoves:(int)moves{
    return NO;
}

-(NSString*)randomWordForType:(DictionaryType)type difficulty:(Difficulty)difficulty{
    return nil;
}

-(NeededMove)neededMoveWithWord:(NSString*)word next:(NSString*)nextWord{
    NeededMove neededMove = NeededMoveEmpty;
    return neededMove;
}

-(NSSet*)wordsForDictionaryType:(DictionaryType)type{
    return nil;
}

@end

#ifdef COLOR_WORD

@implementation ColorWordProvider

-(void)setAlternativeBasePath:(NSString*)basePath{
    [ColorWordUtilities setAlternativeBasePath:basePath];
}

-(NSArray*)solutionWithWords:(NSArray*)words{
    return words;
}

-(NSMutableSet*)permutationsOfWord:(NSString *)word{
    return [ColorWordUtilities permutationsOfWord:word withAlphabet:ALPHABET];
}

-(BOOL)isValidWord:(NSString*)word{
    return [ColorWordUtilities isValidWord:word];
}

-(BOOL)isCandidateLegal:(NSString*)candidateWord forWord:(NSString*)word onLevels:(NSSet*)levels inMoves:(int)moves{
    return [ColorWordUtilities isCandidateLegal:candidateWord forWord:word onLevels:levels inMoves:moves];
}

-(NeededMove)neededMoveWithWord:(NSString*)word next:(NSString*)nextWord{
    return [ColorWordUtilities neededMoveWithWord:word next:nextWord];
}

-(NSString*)randomWordForType:(DictionaryType)type difficulty:(Difficulty)difficulty{
    return [ColorWordUtilities randomWordForType:type difficulty:difficulty];
}

-(NSSet*)wordsForDictionaryType:(DictionaryType)type{
    return [ColorWordUtilities wordsForDictionaryType:type];
}

@end

#endif

#ifdef LETTER_WORD

@implementation LetterWordProvider

-(void)setAlternativeBasePath:(NSString*)basePath{
    [LetterWordUtilities setAlternativeBasePath:basePath];
}

-(NSArray*)solutionWithWords:(NSArray*)words{
    return [[words reverseObjectEnumerator] allObjects];
}

-(NSMutableSet*)permutationsOfWord:(NSString *)word{
    return [LetterWordUtilities permutationsOfWord:word withLetters:ALPHABET];
}

-(BOOL)isValidWord:(NSString*)word{
    return [LetterWordUtilities isValidWord:word];
}

-(BOOL)isCandidateLegal:(NSString*)candidateWord forWord:(NSString*)word onLevels:(NSSet*)levels inMoves:(int)moves{
    return [LetterWordUtilities isCandidateLegal:candidateWord forWord:word onLevels:levels inMoves:moves];
}

-(NSSet*)wordsForDictionaryType:(DictionaryType)type{
    return [LetterWordUtilities wordsForDictionaryType:type];
}

-(NeededMove)neededMoveWithWord:(NSString*)word next:(NSString*)nextWord{
    return [LetterWordUtilities neededMoveWithWord:word next:nextWord];
}

-(NSString*)randomWordForType:(DictionaryType)type difficulty:(Difficulty)difficulty{
    return [LetterWordUtilities randomWordForType:type difficulty:difficulty];
}

@end

#endif