//
//  ColorWordUtilities.h
//  LetterFarm
//
//  Created by Daniel Mueller on 4/3/13.
//
//

#import <Foundation/Foundation.h>
#import "BaseFarm.h"

typedef enum {
    ColorWhite,
    ColorRed,
    ColorPurple,
    ColorBlue,
    ColorGreen,
    ColorYellow,
    ColorOrange
}Color;

Color ColorWithString(NSString* color);

Color ColorWithChar(unichar cChar);

NSString* StringWithColor(Color color);

NSString* MixColors(NSString* initialColor, NSString* mixedColor);

NSString* MixColorChars(unichar initialColor, unichar mixedColor);

@interface ColorWordUtilities : NSObject

//For utilities applications, when there isn't a bundle
+(void)setAlternativeBasePath:(NSString*)basePath;

+(BOOL)isValidWord:(NSString*)word;

+(BOOL)isCandidateLegal:(NSString*)candidateWord forWord:(NSString*)word onLevels:(NSSet*)levels inMoves:(int)moves;

+(NSSet*)wordsForDictionaryType:(DictionaryType)type;

//+(NSSet*)wordsForDictionaryType:(DictionaryType)type difficulty:(Difficulty)difficulty;

+(NSString*)randomWordForType:(DictionaryType)type difficulty:(Difficulty)difficulty;

+(NSMutableSet*)permutationsOfWord:(NSString*)word withAlphabet:(NSString*)alphabet;

+(NSString*)permutateWord:(NSString*)word color:(NSString*)color index:(int)index;

+(NeededMove)neededMoveWithWord:(NSString*)word next:(NSString*)nextWord;

@end
