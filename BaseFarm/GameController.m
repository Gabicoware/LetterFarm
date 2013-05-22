//
//  GameController.m
//  Letter Farm
//
//  Created by Daniel Mueller on 7/2/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "GameController.h"
#import "MainViewController.h"
#import "Analytics.h"
#import "NSObject+Notifications.h"


@implementation GameController

@synthesize navigationController=_navigationController;
@synthesize mainViewController=_mainViewController;

-(id)init{
    if((self = [super init])){
        
        NSDictionary* noteDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"handlePauseNotification:",PauseNotification,
                                  @"handleResumeNotification:",ResumeNotification,
                                  @"handleExitNotification:",ExitNotification,
                                  nil];
        
        [self observeNotifications:noteDict];
        
    }
    return self;
}



-(NSString*)playerID{
    return @"localplayer";
}


-(void)start{
    
}

-(void)presentGameViewController:(UIViewController<GameViewController>*)gameViewController{
        
    self.mainViewController.shouldShowGameView = YES;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[self mainViewController] presentGameViewController:gameViewController];
    }else{
        if ([self.navigationController.viewControllers containsObject:gameViewController]) {
            [[self navigationController] popToViewController:gameViewController animated:YES];
        }else{
            [[self navigationController] pushViewController:gameViewController animated:YES];
        }
        
    }
}

-(UIViewController<GameViewController>*)gameViewController{
    id result = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        result = [[self mainViewController] gameViewController];
    }else{
        
        for (UIViewController* controller in self.navigationController.viewControllers) {
            id gameViewController = OBJECT_IF_OF_PROTOCOL(controller, GameViewController);
            
            if (gameViewController != nil) {
#ifdef DEBUG
                if ( result != nil ) {
                    [NSException raise:@"There should only be one Game View Controller" format:@"%@",self.navigationController.viewControllers];
                }
#endif
                result = gameViewController;
            }
        }
        
        
    }
    return result;
}

-(void)presentPauseViewController:(UIViewController<PauseViewController>*)pauseViewController{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        [[pauseViewController navigationItem] setHidesBackButton:YES];
        
        [[self navigationController] pushViewController:pauseViewController animated:NO];
        
        [[self mainViewController] hideGameViewController];
        
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            self.gameViewController.view.alpha = 0.0;
        }];
        
        [[self gameViewController] presentViewController:pauseViewController animated:YES completion:^{
            
        }];
    }
}

-(void)dismissPauseViewController{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        [[self mainViewController] showGameViewController];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            id pvc = OBJECT_IF_OF_PROTOCOL([[self navigationController] topViewController], PauseViewController);
            
            if (pvc != nil) {
                [[self navigationController] popViewControllerAnimated:YES];
            }
            
        });
        
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            self.gameViewController.view.alpha = 1.0;
        }];
        
        [[self gameViewController] dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
}

-(UIViewController<PauseViewController>*)pauseViewController{
    id result = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        for (UIViewController* controller in self.navigationController.viewControllers) {
            id gameViewController = OBJECT_IF_OF_PROTOCOL(controller, PauseViewController);
            if (result != nil) {
                [NSException raise:@"There should only be one Pause View Controller" format:@"%@",self.navigationController.viewControllers];
            }
            result = gameViewController;
        }
    }else{
        
        result = [[self gameViewController] presentedViewController];
        
    }
    return result;
}

-(void)handlePauseNotification:(NSNotification*)notification{
    
    [self trackScreen:@"Pause Screen"];
    
    UIViewController<PauseViewController>* pauseViewController = [self newPauseViewController];
    [pauseViewController setGameViewController:[self gameViewController]];
    [self presentPauseViewController:pauseViewController];
}

-(void)handleResumeNotification:(NSNotification*)notification{
    [self trackEvent:@"Resume"];
    
    //dismiss pause view
    [self dismissPauseViewController];
}


-(void)handleExitNotification:(NSNotification*)notification{
    
    [self didExitGame];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[self gameViewController] dismissViewControllerAnimated:YES completion:^{
            
        }];
    }

    [self trackEvent:@"Quit"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MenuNotification object:self];
    
}

-(void)didExitGame{
    
}

-(UIViewController<PauseViewController>*)newPauseViewController{
    return nil;
}

-(NSString*)categoryName{
    return @"Game";
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if([viewController conformsToProtocol:@protocol(GameViewController)]){
        [navigationController setNavigationBarHidden:YES animated:YES];
    }else{
        [navigationController setNavigationBarHidden:NO animated:YES];
    }
    
    //dismiss the game view controller if we are going to the root
    BOOL containsViewController = [navigationController.viewControllers containsObject:viewController];
    if (containsViewController) {
        BOOL isRootViewController = [navigationController.viewControllers indexOfObject:viewController] == 0;
        if (isRootViewController) {
            [[self mainViewController] dismissGameViewController];
        }
    }
    
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
}


@end

