//
//  MainViewController.m
//  LetterFarm
//
//  Created by Daniel Mueller on 8/5/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "MainViewController.h"
#import "LFPopoverBackgroundView.h"
#import <QuartzCore/QuartzCore.h>
#import "TileView.h"

@interface MainViewController ()

@property (nonatomic) IBOutlet UIView* logoView;

@property (nonatomic) UIPopoverController* menuPopoverController;

@end

@implementation MainViewController{
    BOOL _isGameViewActive;
}

-(BOOL)isGameViewActive{
    return _isGameViewActive;
}

@synthesize navigationController=_navigationController;
@synthesize menuPopoverController=_menuPopoverController;
@synthesize shouldShowGameView=_shouldShowGameView;

-(void)setIsLogoViewHidden:(BOOL)isLogoViewHidden{
    
    CGFloat targetAlpha = isLogoViewHidden ? 0.0 : 1.0;
    
    if (_isLogoViewHidden && !isLogoViewHidden) {
        self.logoView.hidden = NO;
        self.logoView.alpha = 0.0;
    }
    _isLogoViewHidden = isLogoViewHidden;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.logoView.alpha = targetAlpha;
    } completion:^(BOOL finished) {
        self.logoView.hidden = isLogoViewHidden;
    }];
}

-(void)updateLogoView{
    for (UIView* subview in self.logoView.subviews) {
        TileView* tileView = OBJECT_IF_OF_CLASS(subview, TileView);
        [tileView setTileImageProvider:nil];
    }
}

-(void)showMenu{
    
    if (self.menuPopoverController == nil) {
        UIPopoverController* controller = [[UIPopoverController alloc] initWithContentViewController:self.navigationController];
        
        self.menuPopoverController = controller;
        self.menuPopoverController.delegate = self;
        self.menuPopoverController.popoverBackgroundViewClass = [LFPopoverBackgroundView class];
        
        UIColor* color = [UIColor colorWithRed:57.0/255.0 green:154.0/255.0 blue:193.0/255.0 alpha:1.0];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UIPopoverController class], nil]
         setTintColor:color];
    }
    
#ifndef FREEZE_START_SCREEN
    if (!self.menuPopoverController.isPopoverVisible) {
        
        CGRect popoverRect = CGRectMake(0, 10, 1, 1);
        
        [[self menuPopoverController] presentPopoverFromRect:popoverRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    }
#endif
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}

-(void)showGameViewController{
    
    [self.menuPopoverController dismissPopoverAnimated:YES];
    
    if ([[self gameViewController] isViewLoaded]) {
        _isGameViewActive = YES;
        [[[self gameViewController] view] setUserInteractionEnabled:YES];
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [[[self gameViewController] view] setAlpha:1.0];
                             [self.view.layer setRasterizationScale:0.25];
                         }
                         completion:^(BOOL finished) {
                             [self.view.layer setShouldRasterize:NO];
                         }
         ];
    }
}

-(void)hideGameViewController{
    _isGameViewActive = NO;
    if ([[self gameViewController] isViewLoaded]) {
        [[[self gameViewController] view] setUserInteractionEnabled:NO];
        
        [[self gameViewController] viewWillDisappear:YES];
        
        [self.view.layer setRasterizationScale:1.0];
        [self.view.layer setShouldRasterize:YES];
        
        self.gameViewController.view.userInteractionEnabled = NO;
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.view.layer setRasterizationScale:0.25];
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 [[self gameViewController] viewDidDisappear:YES];
                                 [self showMenu];
                             }
                         }
         ];
    }else{
        [self showMenu];
    }

}

-(void)presentGameViewController:(UIViewController<GameViewController>*)gameViewController{
    [self.menuPopoverController dismissPopoverAnimated:YES];
    
    _isGameViewActive = YES;
    
    for (UIViewController* controller in self.childViewControllers) {
        if ([controller conformsToProtocol:@protocol(GameViewController)]) {
            if (![controller isEqual:gameViewController]) {
                [controller removeFromParentViewController];
            }
        }
    }
    
    if ([self.childViewControllers containsObject:gameViewController]) {
        
        [[gameViewController view] setUserInteractionEnabled:YES];
        [gameViewController viewWillAppear:YES];
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.view.layer setRasterizationScale:1.0];
                         } completion:^(BOOL finished) {
                             [self.view.layer setShouldRasterize:NO];
                             [gameViewController viewDidAppear:YES];
                         }];

    }else{
        [self addChildViewController:gameViewController];
    }
}

- (void)dismissGameViewController{
    _isGameViewActive = NO;
    
    self.shouldShowGameView = NO;
    if ([[self gameViewController] isViewLoaded]) {
        [[[self gameViewController] view] removeFromSuperview];
        for (UIViewController* controller in self.childViewControllers) {
            [controller removeFromParentViewController];
        }
        [UIView animateWithDuration:0.3 animations:^{
            [self.view.layer setRasterizationScale:1.0];
        } completion:^(BOOL finished) {
            [self.view.layer setShouldRasterize:NO];
        }];
    }
}

-(void)addChildViewController:(UIViewController *)childController{
    NSArray* controllers = [self.childViewControllers copy];
    for (UIViewController* controller in controllers) {
        if ([controller isViewLoaded]) {
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [[controller view] setAlpha:0.0];
            } completion:^(BOOL finished) {
                if (finished) {
                    [[controller view] removeFromSuperview];
                    [controller removeFromParentViewController];
                }
            }];
            
        }else{
            [controller removeFromParentViewController];
        }
    }
    
    
    [super addChildViewController:childController];
    
    [[childController view] setFrame:[[self view] bounds]];
    [[self view] addSubview:[childController view]];
    
    [[childController view] setAlpha:0.0];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         [[childController view] setAlpha:1.0];
                         [self.view.layer setRasterizationScale:1.0];
                     } completion:^(BOOL finished) {
                         [self.view.layer setShouldRasterize:NO];
                     }];
    
}

-(UIViewController<GameViewController>*)gameViewController{
    id result = nil;
    for (UIViewController* controller in self.childViewControllers) {
        id gameViewController = OBJECT_IF_OF_PROTOCOL(controller, GameViewController);
        if (result != nil) {
            [NSException raise:@"There should only be one Game View Controller" format:@"%@",self.childViewControllers];
        }
        result = gameViewController;
    }
    return result;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
}

-(BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{
    BOOL should = [self shouldShowGameView];
    if (should) {
        [self showGameViewController];
    }
    return should;
}

@end
