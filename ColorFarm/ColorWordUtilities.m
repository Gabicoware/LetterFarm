//
//  ColorWordUtilities.m
//  LetterFarm
//
//  Created by Daniel Mueller on 4/3/13.
//
//

#import "ColorWordUtilities.h"
#import "BaseFarm.h"
#import "NSString+LF.h"
#import "PuzzleGenerator.h"

NSMutableDictionary* dictionaries;

@interface ColorWordUtilities()

+(NSArray*)arrayWithResource:(NSString*)resource type:(NSString*)type separator:(NSString*)separator;

+(void)initializeInts:(unsigned int*)ints count:(int)count withValues:(NSArray*)values;

@end


@implementation ColorWordUtilities

+(void)initialize{
    dictionaries = [[NSMutableDictionary alloc] initWithCapacity:4];
}

+(NSSet*)wordsForDictionaryType:(DictionaryType)type difficulty:(Difficulty)difficulty{
    
    NSArray* words = [NSArray array];
    
    if (difficulty < DifficultyHard) {
        
        if (type == DictionaryTypeAll3) {
            type = DictionaryTypePuzzle3;
        }else if (type == DictionaryTypeAll4) {
            type = DictionaryTypePuzzle4;
        }else if (type == DictionaryTypeAll5) {
            type = DictionaryTypePuzzle5;
        }
        
        //as of right now, we don't have the libraries set up. We can explore later
        words = [ColorWordUtilities retrieveWordsForDictionaryType:type];
    }else{
        //just get ALL the words

        if (type == DictionaryTypePuzzle3) {
            type = DictionaryTypeAll3;
        }else if (type == DictionaryTypePuzzle4) {
            type = DictionaryTypeAll4;
        }else if (type == DictionaryTypePuzzle5) {
            type = DictionaryTypeAll5;
        }
        
        words = [ColorWordUtilities retrieveWordsForDictionaryType:type];
    }
    
    return [NSSet setWithArray:words];
}

+(NSString*)randomWordForType:(DictionaryType)type difficulty:(Difficulty)difficulty{
    //ensure that we are seeded
    static BOOL seeded = NO;
    if(!seeded)
    {
        seeded = YES;
        srandom((uint)time(NULL));
    }
    
    int length = 3;
    
    switch (type) {
        case DictionaryTypeAll4:
        case DictionaryTypePuzzle4:
            length = 4;
            break;
        case DictionaryTypeAll5:
        case DictionaryTypePuzzle5:
            length = 5;
            break;
        default:
            length = 3;
            break;
    }
    
    NSMutableString* result = [NSMutableString stringWithCapacity:length];
    if (difficulty <= DifficultyHard) {
        
        //create a monochromatic string
        Color randomColor = (random()%6)+ColorRed;
        NSString* colorString = StringWithColor(randomColor);
        for (int index = 0; index < length; index++) {
            [result appendString:colorString];
        }
        
    }else{
        
        //create a multicolored string
        for (int index = 0; index < length; index++) {
            Color randomColor = (random()%6)+ColorRed;
            NSString* colorString = StringWithColor(randomColor);
            [result appendString:colorString];
        }

    }
    
    return [NSString stringWithString:result];
}


+(NSSet*)wordsForDictionaryType:(DictionaryType)type{
    //include all the words, so set the difficulty to hardest
    return [ColorWordUtilities wordsForDictionaryType:type difficulty:DifficultyBrutal];
}


+(NSArray*)retrieveMovesForDictionaryType:(DictionaryType)type{
    NSArray* lengths = nil;
    
    @autoreleasepool {
        
        NSString* key = nil;
        switch (type) {
            case DictionaryTypePuzzle3:
                key = @"DictionaryTypeMoves3";
                break;
            case DictionaryTypePuzzle4:
                key = @"DictionaryTypeMoves4";
                break;
            case DictionaryTypePuzzle5:
                key = @"DictionaryTypeMoves5";
                break;
            default:
                break;
        }
        
        if(key != nil){
            lengths = [dictionaries objectForKey:key];
            
            if (lengths == nil) {
                
                NSString* resourceName = nil;
                switch (type) {
                    case DictionaryTypePuzzle3:
                        resourceName = @"moves.3";
                        break;
                    case DictionaryTypePuzzle4:
                        resourceName = @"moves.4";
                        break;
                    case DictionaryTypePuzzle5:
                        resourceName = @"moves.5";
                        break;
                    default:
                        break;
                }
                
                if (resourceName != nil) {
                    lengths = [ColorWordUtilities arrayWithResource:resourceName type:@"lfm" separator:@"\n"];
                    
                    [dictionaries setObject:lengths forKey:key];
                }
                
            }
        }
        
        
    }
    
    return lengths;
    
}
+(NSArray*)retrieveWordsForDictionaryType:(DictionaryType)type{
    NSArray* words = nil;
    
    @autoreleasepool {
        
        NSString* key = nil;
        switch (type) {
            case DictionaryTypeAll:
                key = @"DictionaryTypeAll";
                break;
            case DictionaryTypePuzzle3:
                key = @"DictionaryTypePuzzle3";
                break;
            case DictionaryTypePuzzle4:
                key = @"DictionaryTypePuzzle4";
                break;
            case DictionaryTypePuzzle5:
                key = @"DictionaryTypePuzzle5";
                break;
            case DictionaryTypeAll3:
            case DictionaryTypeAll4:
            case DictionaryTypeAll5:
                key = @"DictionaryTypeAll";
                break;
            default:
                break;
        }
        
        if(key != nil){
            words = [dictionaries objectForKey:key];
            
            if (words == nil) {
                
                NSString* resourceName = nil;
                switch (type) {
                    case DictionaryTypeAll:
                        resourceName = @"all";
                        break;
                    case DictionaryTypePuzzle3:
                        resourceName = @"puzzle.3";
                        break;
                    case DictionaryTypePuzzle4:
                        resourceName = @"puzzle.4";
                        break;
                    case DictionaryTypePuzzle5:
                        resourceName = @"puzzle.5";
                        break;
                    case DictionaryTypeAll3:
                    case DictionaryTypeAll4:
                    case DictionaryTypeAll5:
                        resourceName = @"all";
                        break;
                    default:
                        break;
                }
                
                if (resourceName != nil) {
                    words = [ColorWordUtilities arrayWithResource:resourceName type:@"cfd" separator:@"\n"];
                    
                    [dictionaries setObject:words forKey:key];
                }
                
            }
        }
        
        
    }
    
    if ( DictionaryTypeAll3 <= type && type <= DictionaryTypeAll5 ) {
        
        int neededLength = type - DictionaryTypeAll3 + 3;
        
        NSPredicate* filterPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return [OBJECT_IF_OF_CLASS(evaluatedObject, NSString) length] == neededLength;
        }];
        
        
        words = [words filteredArrayUsingPredicate:filterPredicate];
        
    }
    
    return words;
    
}

+(void)initializeInts:(unsigned int*)ints count:(int)count withValues:(NSArray*)values{
    
    for (int index = 0; index < count; index++) {
        NSString* countString = [values objectAtIndex:index];
        ints[index] = [countString intValue];
    }
}

NSString* AlternativeBasePath;

+(void)setAlternativeBasePath:(NSString*)basePath{
    
    NSLog(@"%@",basePath);
    
    AlternativeBasePath = basePath;
}

+(NSArray*)arrayWithResource:(NSString*)resource type:(NSString*)type separator:(NSString*)separator{
    
    NSArray* result = nil;
    
    @autoreleasepool {
        
        NSString* path = [[NSBundle bundleForClass:[ColorWordUtilities class]] pathForResource:resource ofType:type];
        
        if (path == nil) {
            //get the path some other way
            
            path = [NSString stringWithFormat:@"%@/%@.%@",AlternativeBasePath,resource,type];
            
        }
        
        NSError* error = nil;
        
        NSString* contentString = [NSString stringWithContentsOfFile:path
                                                            encoding:NSASCIIStringEncoding
                                                               error:&error];
        
        NSString* formattedContentString = [[contentString lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        result = [formattedContentString componentsSeparatedByString:separator];
        
    }
    
    return result;
}

+(BOOL)isValidWord:(NSString*)word{
    
    //its a valid word, if there are no illegal characters
    NSCharacterSet* excludeSet = [[NSCharacterSet characterSetWithCharactersInString:@"oygbprw"] invertedSet];
    
    return [word rangeOfCharacterFromSet:excludeSet].location == NSNotFound;
    
}

+(NSMutableSet*)permutationsOfWord:(NSString*)word withAlphabet:(NSString*)alphabet{
    
    NSMutableSet* permutations = [NSMutableSet set];
    
    for (int lettersIndex = 0; lettersIndex < [alphabet length]; lettersIndex++) {
        NSString* letter = [alphabet substringWithRange:NSMakeRange(lettersIndex, 1)];
        for (int index = 0; index < [word length]; index++) {
            
            NSString* replacePerm = [ColorWordUtilities permutateWord:word color:letter index:index];
            [permutations addObject:replacePerm];
        }
    }
    
    return permutations;
}


+(NSString*)permutateWord:(NSString*)word color:(NSString*)color index:(int)index{
    //is a mutable string, but we don't mention that!
    NSMutableString* mWord = [NSMutableString stringWithString:word];
    
    unichar mixColor;
    [color getCharacters:&mixColor range:NSMakeRange(0, 1)];

    
    if (0 <= index && index < [word length]) {
        
        [ColorWordUtilities mixColorOfWord:mWord atIndex:index withColor:mixColor];
        
        if (0 < index) {
            
            [ColorWordUtilities mixColorOfWord:mWord atIndex:(index - 1) withColor:mixColor];
            
        }
        if ( index < [word length] - 1) {
            
            [ColorWordUtilities mixColorOfWord:mWord atIndex:(index + 1) withColor:mixColor];
            
        }
    }

    return mWord;
}

+(void)mixColorOfWord:(NSMutableString*)word atIndex:(int)index withColor:(unichar)color{
    unichar initialColor;
    [word getCharacters:&initialColor range:NSMakeRange(index, 1)];
    
    NSString* mixedColor = MixColorChars(initialColor, color);
    
    [word replaceCharactersInRange:NSMakeRange(index, 1) withString:mixedColor];
}

+(BOOL)isCandidateLegal:(NSString*)candidateWord forWord:(NSString*)word onLevels:(NSSet*)levels inMoves:(int)moves{
    BOOL isLegal = NO;
    
    NSInteger minLevel = 9999;
    
    for (NSNumber* level in levels) {
        if ([level integerValue] + 1 < minLevel) {
            minLevel = [level integerValue] + 1;
        }
    }
    
    if (minLevel == moves) {
        isLegal = YES;
    }
    
    return isLegal;
}

+(NeededMove)neededMoveWithWord:(NSString*)word next:(NSString*)nextWord{
    
    NeededMove result = NeededMoveEmpty;
    
    NSString* alphabet = @"opgrby";
    
    for (int lettersIndex = 0; lettersIndex < [alphabet length]; lettersIndex++) {
        NSString* letter = [alphabet substringWithRange:NSMakeRange(lettersIndex, 1)];
        for (int index = 0; index < [word length]; index++) {
            
            NSString* replacePerm = [ColorWordUtilities permutateWord:word color:letter index:index];
            
            if ([replacePerm isEqualToString:nextWord]) {
                result.index = index;
                result.letter = ([letter UTF8String])[0];
            }
        }
    }
    
    return result;
}

@end

Color ColorWithString(NSString* color){
    unichar cChar;
    
    [color getCharacters:&cChar range:NSMakeRange(0, 1)];
    
    return ColorWithChar(cChar);
}

Color ColorWithChar(unichar cChar){
    
    
    Color result = ColorWhite;
    
    switch (cChar) {
        case 'W':
        case 'w':
            result = ColorWhite;
            break;
        case 'O':
        case 'o':
            result = ColorOrange;
            break;
        case 'Y':
        case 'y':
            result = ColorYellow;
            break;
        case 'G':
        case 'g':
            result = ColorGreen;
            break;
        case 'B':
        case 'b':
            result = ColorBlue;
            break;
        case 'R':
        case 'r':
            result = ColorRed;
            break;
        case 'P':
        case 'p':
            result = ColorPurple;
            break;
            
    }
    return result;
}

NSString* StringWithColor(Color color){
    
    NSString* result = nil;
    
    switch (color) {
        case ColorWhite:
            result = @"w";
            break;
        case ColorRed:
            result = @"r";
            break;
        case ColorPurple:
            result = @"p";
            break;
        case ColorBlue:
            result = @"b";
            break;
        case ColorGreen:
            result = @"g";
            break;
        case ColorYellow:
            result = @"y";
            break;
        case ColorOrange:
            result = @"o";
            break;
            
    }
    
    return result;
}

NSString* MixColorChars(unichar initialColor, unichar mixedColor){
    
    Color iC = ColorWithChar(initialColor);
    Color mC = ColorWithChar(mixedColor);
    
    int i = (int)iC;
    int m = (int)mC;
    
    Color result = ColorWhite;
    
    if (iC == ColorWhite) {
        result = mC;
    }else if(mC == ColorWhite){
        result = iC;
    }else if(mC == iC){
        result = iC;
    }else if(ABS(m - i) == 1 || ABS(m - i) == 5){
        result = mC;
    }else if(ABS(m - i) == 2 ){
        result = (m + i)/2;
    }else if( ABS(m - i) == 4){
        if(ColorRed < MIN(m,i)){
            result = MIN(m,i) - 1;
        }else if(ColorOrange > MAX(m, i)){
            result = MAX(m, i) + 1;
        }else{
            //unknown situation here, will test every combination
        }
    }else if(ABS(m - i) == 3){
        result = ColorWhite;
    }
    
    return StringWithColor(result);
}

NSString* MixColors(NSString* initialColor, NSString* mixedColor){
    
    Color iC = ColorWithString(initialColor);
    Color mC = ColorWithString(mixedColor);
    
    int i = (int)iC;
    int m = (int)mC;
    
    Color result = ColorWhite;
    
    if (iC == ColorWhite) {
        result = mC;
    }else if(mC == ColorWhite){
        result = iC;
    }else if(mC == iC){
        result = iC;
    }else if(ABS(m - i) == 1 || ABS(m - i) == 5){
        result = mC;
    }else if(ABS(m - i) == 2 ){
        result = (m + i)/2;
    }else if( ABS(m - i) == 4){
        if(ColorRed < MIN(m,i)){
            result = MIN(m,i) - 1;
        }else if(ColorOrange > MAX(m, i)){
            result = MAX(m, i) + 1;
        }else{
            //unknown situation here, will test every combination
        }
    }else if(ABS(m - i) == 3){
        result = ColorWhite;
    }
    
    return StringWithColor(result);
}
