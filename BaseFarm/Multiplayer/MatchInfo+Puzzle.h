//
//  MatchInfo+Puzzle.h
//  LetterFarm
//
//  Created by Daniel Mueller on 7/31/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "MatchInfo.h"

@interface MatchInfo (Puzzle)

-(BOOL)canFinishPuzzleMatch;

-(void)finishPuzzleMatch;

+(int)currentDifficultyWithMin:(int)min games:(NSArray*)games;

@end
