//
//  PresentationController.m
//  Letter Farm
//
//  Created by Daniel Mueller on 6/12/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "PresentationController.h"

@interface PresentationController ()

@property (nonatomic) IBOutlet UIView* containerView;

@property (nonatomic) UIView* modalView;

@property (nonatomic) UIView* currentView;

@end

@implementation PresentationController

@synthesize containerView=_containerView, currentView=_currentView, modalView=_modalView;



-(void)dismissCurrentView{
    
    CGRect selfBounds = self.containerView.bounds;
    
    UIView* dismissedView = self.currentView;
    
    UIView* modalView = self.modalView;
    
    CGPoint destCenter = CGPointMake(CGRectGetMidX(selfBounds), selfBounds.size.height + CGRectGetMidY(dismissedView.bounds));
    
    [UIView animateWithDuration:0.2 animations:^{
        modalView.alpha = 0.0;
        dismissedView.center = destCenter;
    } completion:^( BOOL finished ){
        [modalView removeFromSuperview];
        [dismissedView removeFromSuperview];
    }];
    
    self.modalView = nil;
    self.currentView = nil;
}


-(void)presentView:(UIView*)presentedView withMode:(UIViewContentMode)contentMode{
    
    if (self.currentView != nil) {
        CGRect selfBounds = self.containerView.bounds;
        
        UIView* dismissedView = self.currentView;
        
        CGPoint destCenter = CGPointMake(CGRectGetMidX(selfBounds), selfBounds.size.height + CGRectGetMidY(dismissedView.bounds));
        
        [UIView animateWithDuration:0.2 animations:^{
            dismissedView.center = destCenter;
        } completion:^( BOOL finished ){
            [dismissedView removeFromSuperview];
        }];
        
        self.currentView = nil;
    }
    
    if (self.modalView == nil) {
        UIView* modalView = [[UIView alloc] initWithFrame:[[self containerView] bounds]];
        [modalView setBackgroundColor:[UIColor colorWithWhite:0.40 alpha:0.25]];
        
        [modalView setAlpha:0.0];
        
        self.modalView = modalView;
        
    }
        
    CGRect selfBounds = self.containerView.bounds;
    
    presentedView.center = CGPointMake(CGRectGetMidX(selfBounds), selfBounds.size.height + CGRectGetMidY(presentedView.bounds));
    
    [[self containerView] addSubview:self.modalView];
    
    CGPoint destCenter = CGPointZero;
    
    
    switch (contentMode) {
        case UIViewContentModeBottom:
            destCenter = CGPointMake(CGRectGetMidX(selfBounds), selfBounds.size.height - CGRectGetMidY(presentedView.bounds));
            break;
        case UIViewContentModeCenter:
        default:
            destCenter = CGPointMake(CGRectGetMidX(selfBounds), CGRectGetMidY(selfBounds));
            break;
    }
    
    
    
    
    
    [[self containerView] addSubview:presentedView];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.modalView.alpha = 1.0;
        presentedView.center = destCenter;
    }];
    
    self.currentView = presentedView;
}

@end
