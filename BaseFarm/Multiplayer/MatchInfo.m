//
//  MatchInfo.m
//  LetterFarm
//
//  Created by Daniel Mueller on 7/20/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "MatchInfo.h"

@implementation MatchInfo

-(BOOL)hasData{
    return self.games != nil;
}

-(int)roundCount{
    int gameCount = self.games.count;
    if (gameCount == 0) {
        gameCount = 1;
    }
    int roundCount = (gameCount + gameCount%2)/2;
    return roundCount;
}

@end
