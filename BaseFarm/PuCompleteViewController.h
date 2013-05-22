//
//  PuCompleteViewController.h
//  Letter Farm
//
//  Created by Daniel Mueller on 6/29/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "LFViewController.h"

#import "PuzzleGame.h"

@interface PuCompleteViewController : LFViewController

@property (nonatomic) PuzzleGame* puzzleGame;

//slight difference in UI when history is being shown
@property (nonatomic) BOOL isShowingHistory;

@end
