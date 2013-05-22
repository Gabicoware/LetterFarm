//
//  PuPauseViewController.h
//  LetterFarm
//
//  Created by Daniel Mueller on 8/11/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "LFTableViewController.h"
#import "BaseFarm.h"

@interface PuPauseViewController : LFTableViewController<PauseViewController>

@property (nonatomic) BOOL disableHints;

@property (nonatomic) BOOL canPass;

@end
