//
//  LetterWordUtilities.m
//  Letter Farm
//
//  Created by Daniel Mueller on 4/22/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "LetterWordUtilities.h"
#import "BaseFarm.h"
#import "NSString+LF.h"
#import "PuzzleGenerator.h"

NSMutableDictionary* dictionaries;

@interface LetterWordUtilities()

+(NSArray*)arrayWithResource:(NSString*)resource type:(NSString*)type separator:(NSString*)separator;

+(void)initializeInts:(unsigned int*)ints count:(int)count withValues:(NSArray*)values;

@end


@implementation LetterWordUtilities

+(void)initialize{
    dictionaries = [[NSMutableDictionary alloc] initWithCapacity:4];
}

+(NSSet*)wordsForDictionaryType:(DictionaryType)type moveCount:(int)moveCount{
    NSArray* words = [LetterWordUtilities retrieveWordsForDictionaryType:type];
    
    if (0 < moveCount) {
        NSMutableArray* mWords = [NSMutableArray array];
        
        NSArray* moves = [LetterWordUtilities retrieveMovesForDictionaryType:type];
        
        NSUInteger count = [words count];
        
        for (NSUInteger index = 0; index < count; index++) {
            NSString* moveString = [moves objectAtIndex:index];
            if ( moveCount <= [moveString intValue] ) {
                [mWords addObject:[words objectAtIndex:index]];
            }
        }
        
        words = mWords;
    }
    
    return [NSSet setWithArray:words];
}

+(NSSet*)wordsForDictionaryType:(DictionaryType)type{
    return [LetterWordUtilities wordsForDictionaryType:type moveCount:0];
}

+(NSString*)randomWordForType:(DictionaryType)type difficulty:(Difficulty)difficulty{
    
    if (DictionaryTypeAll3 <= type && type <= DictionaryTypeAll5 ) {
        type = type - DictionaryTypeAll3 + DictionaryTypePuzzle3;
    }
    
    NSSet* startWords = [LetterWordUtilities wordsForDictionaryType:type moveCount:(int)difficulty];
    
    return [self randomWordWithWords:startWords];
}


+(NSString*)randomWordWithWords:(NSSet*)words{
    static BOOL seeded = NO;
    if(!seeded)
    {
        seeded = YES;
        srandom((uint)time(NULL));
    }
    
    unsigned long randomIndex = random()%[words count];
    __block int currentIndex = 0;
    __block id selectedObj = nil;
    [words enumerateObjectsWithOptions:0 usingBlock:^(id obj, BOOL *stop) {
        if (randomIndex == currentIndex) {
            selectedObj = obj; *stop = YES;
        }else{
            currentIndex++;
        }
    }];
    
    return selectedObj;
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
                    lengths = [LetterWordUtilities arrayWithResource:resourceName type:@"lfm" separator:@"\n"];
                    
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
                    words = [LetterWordUtilities arrayWithResource:resourceName type:@"lfd" separator:@"\n"];
                    
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
        
        NSString* path = [[NSBundle bundleForClass:[LetterWordUtilities class]] pathForResource:resource ofType:type];
        
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
    
    NSSet* words = [self wordsForDictionaryType:DictionaryTypeAll];
    
    return [words containsObject:word];
    
}

+(NSInteger)differenceBetweenWord1:(NSString*)word1 word2:(NSString*)word2{
    
    NSInteger length = MIN([word1 length], [word2 length]);
    
    NSInteger count = [word1 length] == [word2 length] ? 0 : 1;
    
    for(NSInteger index = 0; index < length; index++){
        if(![[word1 letterAtIndex:index] isEqualToString:[word2 letterAtIndex:index]]){
            count++;
        }
    }
    
    return count;
}

+(NSMutableSet*)permutationsOfWord:(NSString*)word withLetters:(NSString*)letters{
    
    NSMutableSet* permutations = [NSMutableSet set];
    for (int lettersIndex = 0; lettersIndex < [letters length]; lettersIndex++) {
        NSString* letter = [letters substringWithRange:NSMakeRange(lettersIndex, 1)];
        for (int index = 0; index < [word length]; index++) {
            NSString* replacePerm = [word stringByReplacingCharactersInRange:NSMakeRange(index, 1)
                                                                  withString:letter];
            [permutations addObject:replacePerm];
        }
    }
    
    return permutations;
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
        NSInteger diffCount = moves < [word length] ? moves : [word length];
        isLegal = [self differenceBetweenWord1:word word2:candidateWord] == diffCount;
    }
    
    return isLegal;
    
}

+(NeededMove)neededMoveWithWord:(NSString*)word next:(NSString*)nextWord{
    
    NeededMove result = NeededMoveEmpty;
    
    for ( int index = 0; index < word.length; index++ ) {
        
        NSString* activeLetter = [word letterAtIndex:index];
        NSString* nextLetter = [nextWord letterAtIndex:index];
        
        if(![activeLetter isEqualToString:nextLetter]){
            result.index = index;
            result.letter = ([nextLetter UTF8String])[0];
        }
        
    }
    
    return result;

}

@end
