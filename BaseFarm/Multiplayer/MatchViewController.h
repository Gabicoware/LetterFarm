//
//  MatchViewController.h
//  LetterFarm
//
//  Created by Daniel Mueller on 8/1/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MatchInfo.h"


extern NSString* MatchViewNextRoundNotification;

@interface MatchViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) MatchInfo* matchInfo;

-(void)refreshDisplay;

@end

@class PuzzleGame;

@interface MatchViewController (Internal)

@property (nonatomic, readonly) NSString* nextRoundText;
@property (nonatomic, readonly) NSString* opponentLabelText;
@property (nonatomic, readonly) NSString* roundLabelText;

-(PuzzleGame*)firstGameAtIndex:(NSInteger)index;
-(PuzzleGame*)secondGameAtIndex:(NSInteger)index;
-(NSString*)detailTextForIndex:(NSInteger)index;
-(BOOL)isActiveAtIndex:(int)index;

@end