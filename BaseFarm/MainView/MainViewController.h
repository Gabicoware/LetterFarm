//
//  MainViewController.h
//  LetterFarm
//
//  Created by Daniel Mueller on 8/5/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseFarm.h"

@interface MainViewController : UIViewController<UIPopoverControllerDelegate>

@property (nonatomic) UINavigationController* navigationController;

@property (nonatomic) BOOL isLogoViewHidden;

@property (nonatomic) BOOL isGameViewActive;

-(void)updateLogoView;

-(void)showMenu;


-(void)showGameViewController;

-(void)hideGameViewController;

-(void)presentGameViewController:(UIViewController<GameViewController>*)gameViewController;

- (void)dismissGameViewController;

@property (nonatomic, readonly) UIViewController<GameViewController>* gameViewController;

@property (nonatomic, assign) BOOL shouldShowGameView;

@end
