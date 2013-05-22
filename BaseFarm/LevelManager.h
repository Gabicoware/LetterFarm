//
//  LevelManager.h
//  Letter Farm
//
//  Created by Daniel Mueller on 6/14/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PuzzleGame.h"

//todo rename this to LevelsManager

@interface LevelManager : NSObject

-(NSArray*)levelsWithPackName:(NSString*)packName;

-(PuzzleGame*)puzzleGameForPack:(NSString*)packName index:(int)index;

-(int)levelCountForPack:(NSString*)packName;

-(void)completeLevel:(int)index pack:(NSString*)pack game:(PuzzleGame*)game;

-(BOOL)hasCompletedLevel:(int)index pack:(NSString*)pack;

-(NSString*)packNameAtIndex:(int)index;

-(NSString*)packTitleWithName:(NSString*)name;

-(NSString*)packThemeWithName:(NSString*)name;

-(void)updateTitle:(NSString*)title theme:(NSString*)theme packName:(NSString*)packName;

-(void)deletePackName:(NSString*)packName;

-(NSInteger)totalGameCountWithName:(NSString*)name;

-(NSInteger)completedGameCountWithName:(NSString*)name;

-(BOOL)isIncludedPackName:(NSString*)packName;

-(BOOL)isTutorialPackName:(NSString*)packName;

-(int)packCount;

-(NSString*)saveLevelPack:(NSArray*)levels title:(NSString*)title theme:(NSString*)theme;

+(id)sharedLevelManager;


@end
