//
//  GameController.h
//  Letter Farm
//
//  Created by Daniel Mueller on 7/2/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseFarm.h"

@class MainViewController;


@interface GameController : NSObject<UINavigationControllerDelegate>

@property (nonatomic) UINavigationController* navigationController;
@property (nonatomic) MainViewController* mainViewController;

-(void)start;

@property (nonatomic, readonly) NSString* playerID;

@property (nonatomic, readonly) UIViewController<GameViewController>* gameViewController;

-(void)presentGameViewController:(UIViewController<GameViewController>*)gameViewController;

-(void)presentPauseViewController:(UIViewController<PauseViewController>*)pauseViewController;

-(void)dismissPauseViewController;

-(UIViewController<PauseViewController>*)newPauseViewController;

-(void)didExitGame;

@end

@interface GameController (Analytics)
-(NSString*)categoryName;
-(void)trackEvent:(NSString*)name;
@end
