//
//  PuGameWordHistoryController.h
//  Letter Farm
//
//  Created by Daniel Mueller on 6/4/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PuzzleGame;

@interface PuGameWordHistoryController : NSObject<UITableViewDataSource, UITableViewDelegate>

-(void)resetWithGame:(PuzzleGame*)puzzleGame;

-(void)pushWord:(NSString*)word;

-(void)popWord;

@end
