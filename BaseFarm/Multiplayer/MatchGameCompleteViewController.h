//
//  MatchGameCompleteViewController.h
//  LetterFarm
//
//  Created by Daniel Mueller on 8/1/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseFarm.h"
#import "MatchInfo.h"

@interface MatchGameCompleteViewController : UIViewController

@property (nonatomic) NSInteger roundNumber;

@property (nonatomic) id<MatchGame> firstGame;
@property (nonatomic) id<MatchGame> secondGame;
@property (nonatomic) MatchInfo* matchInfo;
@property (nonatomic) NSString* yourName;

@end
