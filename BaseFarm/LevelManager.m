//
//  LevelManager.m
//  Letter Farm
//
//  Created by Daniel Mueller on 6/14/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "LevelManager.h"

#define LevelHistoryFileName @"level_history"
#define CustomPacksFileName @"custom_packs"


#define OldPuzzleGamesFileName @"puzzles"

//get the title of a pack
//get the path to a pack
//order the packs by index, which does not change

#define PACK_NAME @"packName"

#define PACK_TITLE @"title"
#define PACK_THEME @"theme"
#define PACK_IS_CUSTOM @"isCustom"

#ifdef COLOR_WORD

#define PACK_EXT @"cflp"

#endif

#ifdef LETTER_WORD

#define PACK_EXT @"lflp"

#endif

#define BundledPackCount 3

#define PackDictionary(title,packName,isCustom,theme) ([NSDictionary dictionaryWithObjectsAndKeys:\
title,PACK_TITLE,\
packName,PACK_NAME,\
[NSNumber numberWithBool:isCustom],PACK_IS_CUSTOM,\
theme,PACK_THEME,\
nil])

@implementation LevelManager{
    NSMutableDictionary* _levelPacks;
    
    NSMutableDictionary* _completedLevels;
    
    NSMutableArray* _packs;
}

+(id)sharedLevelManager
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}


-(id)init{
    if((self = [super init])){
        
        _completedLevels = [NSMutableDictionary dictionary];
        
        NSString* customPacksFilePath = [self customPacksFilePath];
        NSObject<NSCoding>* result = [NSKeyedUnarchiver unarchiveObjectWithFile:customPacksFilePath];
        
        if([result isKindOfClass:[NSArray class]]){
            _packs = [NSMutableArray arrayWithArray:(id)result];
        }else{
            _packs = [NSMutableArray array];
            
            [_packs addObject:PackDictionary(@"Tutorials",@"tutorials",NO,WorldThemeSummer)];
            [_packs addObject:PackDictionary(@"Summer",@"pack_0",NO,WorldThemeSummer)];
            [_packs addObject:PackDictionary(@"Autumn",@"pack_1",NO,WorldThemeAutumn)];
            
            
            /**
             * v1 compatibility
             * 
             */
            
            
            NSObject<NSCoding>* oldGamesResult = [NSKeyedUnarchiver unarchiveObjectWithFile:[self oldPuzzleGamesFilePath]];
            
            NSArray* oldGames = OBJECT_IF_OF_CLASS(oldGamesResult, NSArray);
            
            if (oldGames != nil) {
                
                NSMutableArray* levels = [NSMutableArray arrayWithCapacity:[oldGames count]];
                
                for (PuzzleGame* game in oldGames) {
                    NSString* gameString = [game.solutionWords componentsJoinedByString:@","];
                    [levels addObject:gameString];
                }
                
                for (int index = 0; index < levels.count; index += 30) {
                    
                    int length = MIN(30, levels.count - index);
                    
                    NSArray* subGames = [oldGames subarrayWithRange:NSMakeRange(index, length)];
                    NSArray* subLevels = [levels subarrayWithRange:NSMakeRange(index, length)];
                    
                    NSString* title = [NSString stringWithFormat:@"Old Games %d", (index/30 +1)];
                    
                    NSString* packName = [self saveLevelPack:subLevels title:title theme:WorldThemeSummer];
                    
                    NSMutableDictionary* mutableDict = [[self levelsDictWithName:packName] mutableCopy];
                    
                    for (int gameIndex = 0; gameIndex < subGames.count; gameIndex++) {
                        PuzzleGame* game = OBJECT_AT_INDEX_IF_OF_CLASS(subGames, gameIndex, PuzzleGame);
                        
                        //if the game has a solution, then add it.
                        if([[game.guessedWords lastObject] isEqualToString:game.endWord]){
                            [mutableDict setObject:game forKey:[NSNumber numberWithInt:gameIndex]];
                        }
                        
                    }
                    
                    NSDictionary* dict = [NSDictionary dictionaryWithDictionary:mutableDict];
                    
                    NSString* levelHistoryFilePath = [self levelHistoryFilePathForPack:packName];
                    
                    [NSKeyedArchiver archiveRootObject:dict toFile:levelHistoryFilePath];
                    
                    [_completedLevels setObject:dict forKey:packName];
                    
                    
                }
                
            }
        }
        
    }
    return self;
}

-(NSString*)packNameAtIndex:(int)index{
    if(index < [self packCount]){
        NSDictionary* dict = [_packs objectAtIndex:index];
        return [dict objectForKey:PACK_NAME];
    }
    return nil;
}

-(NSString*)packTitleWithName:(NSString*)name{
    
    NSString* theme = nil;
    
    for (NSDictionary* pack in _packs) {
        if ([[pack objectForKey:PACK_NAME] isEqual:name]) {
            theme = [pack objectForKey:PACK_TITLE];
        }
    }
    
    return theme;
    
}

-(BOOL)isTutorialPackName:(NSString*)packName{
    return [@"tutorials"isEqualToString:packName];
}

-(BOOL)isIncludedPackName:(NSString*)packName{
    return [@[@"tutorials",@"pack_0",@"pack_1"] containsObject:packName];
}

-(NSString*)packThemeWithName:(NSString*)name{
    
    NSString* theme = nil;
    
    for (NSDictionary* pack in _packs) {
        if ([[pack objectForKey:PACK_NAME] isEqual:name]) {
            theme = [pack objectForKey:PACK_THEME];
        }
    }
    
    return theme;
}

-(NSInteger)completedGameCountWithName:(NSString*)name{
    
    return [[[self levelsDictWithName:name] allKeys] count];
    
}

-(NSInteger)totalGameCountWithName:(NSString*)name{
    return [[self levelsWithPackName:name] count];
}

-(int)packCount{
    return [_packs count];
}

#define CustomPackCountKey @"LevelManager_CustomPackCountKey"

-(NSString*)saveLevelPack:(NSArray*)levels title:(NSString*)title theme:(NSString*)theme{
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    int totalCustomPackCount = [defaults integerForKey:CustomPackCountKey];
    
    NSString* packName = [NSString stringWithFormat:@"custom_%d",totalCustomPackCount];
    
    CFUUIDRef theUUID = CFUUIDCreate(kCFAllocatorDefault);
    if (theUUID) {
        packName = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, theUUID));
        CFRelease(theUUID);
    }
    
    NSString* fileName = [NSString stringWithFormat:@"%@.%@",packName,PACK_EXT];
    
    NSString* levelPackPath = [self documentsFilePathWithName:fileName];
    
    [_packs addObject:PackDictionary(title, packName, YES, theme)];
    
    [NSKeyedArchiver archiveRootObject:_packs toFile:[self customPacksFilePath]];
    
    NSError* error = nil;
    
    [[levels componentsJoinedByString:@"\n"] writeToFile:levelPackPath atomically:NO encoding:NSASCIIStringEncoding error:&error];
    
    [defaults setInteger:(totalCustomPackCount+1) forKey:CustomPackCountKey];
    [defaults synchronize];
    
    return packName;
}


-(NSString*)keyWithPack:(NSString*)pack level:(int)level{
    return [NSString stringWithFormat:@"%@_%d",pack,level];
}

-(void)completeLevel:(int)index pack:(NSString*)packName game:(PuzzleGame*)game{
    
    NSMutableDictionary* mutableDict = [[self levelsDictWithName:packName] mutableCopy];
    
    [mutableDict setObject:game forKey:[NSNumber numberWithInt:index]];
    
    NSDictionary* dict = [NSDictionary dictionaryWithDictionary:mutableDict];
    
    NSString* levelHistoryFilePath = [self levelHistoryFilePathForPack:packName];
    
    [NSKeyedArchiver archiveRootObject:dict toFile:levelHistoryFilePath];
    
    [_completedLevels setObject:dict forKey:packName];
    
}

-(BOOL)hasCompletedLevel:(int)index pack:(NSString*)pack{
    
    NSDictionary* dict = [self levelsDictWithName:pack];
    
    return [dict objectForKey:[NSNumber numberWithInt:index]] != nil;
    
}

-(void)updateTitle:(NSString*)title theme:(NSString*)theme packName:(NSString*)packName{
    
    NSDictionary* originalDict = nil;
    NSDictionary* updatedDict = nil;
    
    for (NSDictionary* pack in _packs) {
        if ([[pack objectForKey:PACK_NAME] isEqual:packName]) {
            
            NSMutableDictionary* mutablePack = [pack mutableCopy];
            
            originalDict = pack;
            [mutablePack setObject:title forKey:PACK_TITLE];
            if (theme != nil) {
                [mutablePack setObject:theme forKey:PACK_THEME];
            }
            updatedDict = [NSDictionary dictionaryWithDictionary:mutablePack];
            
        }
    }
    
    if (updatedDict != nil && originalDict != nil) {
        
        NSInteger index = [_packs indexOfObject:originalDict];
        [_packs replaceObjectAtIndex:index withObject:updatedDict];
        
        [NSKeyedArchiver archiveRootObject:_packs toFile:[self customPacksFilePath]];
    }
}

-(void)deletePackName:(NSString*)packName{
    NSDictionary* deletedDict = nil;
    
    for (NSDictionary* pack in _packs) {
        if ([[pack objectForKey:PACK_NAME] isEqual:packName]) {
            deletedDict = pack;
        }
    }
    
    [_packs removeObject:deletedDict];
    
    [NSKeyedArchiver archiveRootObject:_packs toFile:[self customPacksFilePath]];
}


-(NSDictionary*)levelsDictWithName:(NSString*)packName{
    NSDictionary* dict = [_completedLevels objectForKey:packName];
    
    if (dict == nil) {
        
        NSString* levelHistoryFilePath = [self levelHistoryFilePathForPack:packName];
        NSObject<NSCoding>* result = [NSKeyedUnarchiver unarchiveObjectWithFile:levelHistoryFilePath];
        
        if([result isKindOfClass:[NSDictionary class]]){
            dict = (NSDictionary*)result;
        }else{
            dict = [NSDictionary dictionary];
        }
        
        [_completedLevels setObject:dict forKey:packName];
        
    }
    
    return dict;

}

/*
-(void)savePuzzle:(PuzzleGame*)puzzleGame{
    if (puzzleGame != nil) {
        if (![self.mutablePuzzleGames containsObject:puzzleGame]) {
            [self.mutablePuzzleGames addObject:puzzleGame];
        }
        
        NSArray* games = [NSArray arrayWithArray:self.puzzleGames];
        
        [NSKeyedArchiver archiveRootObject:games toFile:[self puzzleGamesFilePath]];
    }
    
}
*/
-(NSString*)levelHistoryFilePathForPack:(NSString*)pack{
    return [self documentsFilePathWithName:[LevelHistoryFileName stringByAppendingString:pack]];
}

-(NSString*)customPacksFilePath{
    return [self documentsFilePathWithName:CustomPacksFileName];
}

-(NSString*)oldPuzzleGamesFilePath{
    return [self documentsFilePathWithName:OldPuzzleGamesFileName];
}

-(NSString*)documentsFilePathWithName:(NSString*)fileName{
    NSArray* URLs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    
    NSURL* documentsURL = [URLs lastObject];
    
    return [[documentsURL relativePath] stringByAppendingFormat:@"/%@",fileName];
}


-(NSArray*)levelsWithPackName:(NSString*)packName{
    
    NSArray* result = [_levelPacks objectForKey:packName];
    
    if (result == nil) {
        NSError* error = nil;
        
        NSString* path = [self pathWithPackWithName:packName];
        
        NSString* levelFileString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        
        if (error == nil) {
            NSArray* levelStrings = [[levelFileString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@"\n"];
            
            NSMutableArray* muResult = [NSMutableArray array];
            
            for (NSString* gameString in levelStrings) {
                NSArray* gameWords = [[gameString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n ,\t"]]  componentsSeparatedByString:@","];
                [muResult addObject:gameWords];
            }
            
            result = [NSArray arrayWithArray: muResult];
            
            [_levelPacks setObject:result forKey:packName];
            
        }
    }
    
    return result;

}

-(NSString*)pathWithPackWithName:(NSString*)packName{
    //return either the bundled pack, or the custom pack
    NSString* path = [[NSBundle mainBundle] pathForResource:packName ofType:PACK_EXT];
    
    if (path == nil) {
        path = [self documentsFilePathWithName:[packName stringByAppendingFormat:@".%@",PACK_EXT]];
    }
    
    return path;
}

-(PuzzleGame*)puzzleGameForPack:(NSString*)packName index:(int)index{
    
    NSArray* gameWords = OBJECT_AT_INDEX_IF_OF_CLASS([self levelsWithPackName:packName], index, NSArray);
    
    PuzzleGame* puzzleGame = [PuzzleGame puzzleGameWithWords:gameWords];
    
    return puzzleGame;

}

-(int)levelCountForPack:(NSString*)packName{
    return [[self levelsWithPackName:packName] count];
}


@end
