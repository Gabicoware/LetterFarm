//
//  LFAlertView.h
//  Letter Farm
//
//  Created by Daniel Mueller on 4/26/11.
//  Copyright 2011 Squrl. All rights reserved.
//

#import "LFAlertView.h"

#import <QuartzCore/QuartzCore.h>
#import "NSObject+Notifications.h"

#define MINIMUM_TIMEOUT 2
#define STATUS_BAR_ORIENTATION @"statusBarOrientation"


@interface LFAlertView ()

//! show the view in the provided view
-(void)showInView:(UIView*)view;


- (void)viewCompleteWithTimer:(NSTimer*)timer;

- (void)pulse;

- (CGFloat)rotationWithOrientation:(UIInterfaceOrientation)orientation;

- (void)updateOrientation;

- (void)deviceOrientationDidChange:(NSNotification*)notification;

-(void)animateInitialGrow;

-(void)animateShrink;

-(void)animateFinalGrow;

@property (nonatomic) CGRect keyboardFrame;

@end

@implementation LFAlertView

@synthesize isModal=_isModal;
@synthesize timeout=_timeout;

- (CGFloat)rotationWithOrientation:(UIInterfaceOrientation)orientation{
    
    CGFloat rotation = 0.0f;
    
    switch(orientation){
        case UIInterfaceOrientationPortrait:
            rotation = 0.0f;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            rotation = 180.0f;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            rotation = 270.0f;
            break;
        case UIInterfaceOrientationLandscapeRight:
            rotation = 90.0f;
            break;
            
    }
    
    return rotation* M_PI / 180.0f;

}

-(void)showInView:(UIView *)view{
    
    CGSize viewSize = [view bounds].size;
    
    CGPoint alertViewPoint = CGPointMake(viewSize.width/2, viewSize.height/2);
    
    [self setCenter:alertViewPoint];
    
    [self updateOrientation];
        
    [view addSubview:self];
    
    if (_timeout > 0) {
        
        if(_timeout < MINIMUM_TIMEOUT){
            _timeout = MINIMUM_TIMEOUT;
        }
        
        [NSTimer scheduledTimerWithTimeInterval:_timeout
                                         target:self
                                       selector:@selector(viewCompleteWithTimer:)
                                       userInfo:nil
                                        repeats:NO];
        
    }
    
    [self pulse];
        
    NSDictionary* notes = [NSDictionary dictionaryWithObjectsAndKeys:
                           @"handleKeyboardNotification:",UIKeyboardWillShowNotification,
                           @"handleKeyboardNotification:",UIKeyboardWillHideNotification,
                           @"handleKeyboardNotification:",UIKeyboardWillChangeFrameNotification,
                           @"deviceOrientationDidChange:",UIDeviceOrientationDidChangeNotification,
                           nil];
    
    [self observeNotifications:notes];
    
}

- (void)deviceOrientationDidChange:(NSNotification*)notification{
    [self updateOrientation];
}


- (void)updateOrientation{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (_interfaceOrientation != orientation) {
        CGFloat rotation = [self rotationWithOrientation:orientation];
        
        CGAffineTransform landscapeTransform = CGAffineTransformMakeRotation(rotation);
        
        [UIView animateWithDuration:0.25 animations:^{
            [self setTransform:landscapeTransform];
        }];
        
        
        _interfaceOrientation = orientation;
    }
    
    
}

-(void)handleKeyboardNotification:(NSNotification*)notification{
    
    NSValue* endFrameValue = OBJECT_IF_OF_CLASS([notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey], NSValue);
    CGRect endFrame = CGRectZero;
    [endFrameValue getValue:&endFrame];
    
    self.keyboardFrame = endFrame;
    
    CGSize superviewSize = [self.superview bounds].size;
    
    CGPoint newCenter = CGPointMake(superviewSize.width/2, superviewSize.height/2);
    
    CGFloat duration = 0.25;
    
    if ([[notification name] isEqualToString:UIKeyboardWillShowNotification] || [[notification name] isEqualToString:UIKeyboardWillChangeFrameNotification]) {
        
        CGFloat topHeight = endFrame.origin.y - 20.0;
        CGFloat bottomHeight = superviewSize.height - endFrame.origin.y - endFrame.size.height - 20.0;
        
        if (topHeight > bottomHeight && topHeight > self.bounds.size.height) {
            newCenter.y = topHeight/2.0 + 20.0;
        }else if(bottomHeight > topHeight && bottomHeight > self.bounds.size.height){
            newCenter.y = bottomHeight/2.0 + endFrame.origin.y + endFrame.size.height;
        }
        
        CGFloat leftWidth = endFrame.origin.x - 20.0;
        CGFloat rightWidth = superviewSize.width - endFrame.origin.x - endFrame.size.width - 20.0;
        
        if (leftWidth > rightWidth && leftWidth > self.bounds.size.width) {
            newCenter.x = leftWidth/2.0 + 20.0;
        }else if(rightWidth > leftWidth && rightWidth > self.bounds.size.width){
            newCenter.x = rightWidth/2.0 + endFrame.origin.x + endFrame.size.width;
        }
    }
    
    [UIView animateWithDuration:duration animations:^{
        self.center = newCenter;
    }];
    
}

-(void)show{
    
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    
    if ([self isModal]) {
        UIView* modalView = [[UIView alloc] initWithFrame:[window bounds]];
        
        [modalView setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.6]];
        
        [window addSubview:modalView];
        
        [self showInView:modalView];
        
    }else{
        
        [self showInView:window];
        
    }
    
}

-(void)setIsModal:(BOOL)isModal{
    if ([self superview] == nil) {
        _isModal = isModal;
    }
}

- (void)viewCompleteWithTimer:(NSTimer*)timer {
    [self remove];
}

-(void)remove{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
         
    if ([self isModal]) {
        [[self superview] removeFromSuperview];
    }else{
        [self removeFromSuperview];
    }
    
}

float pulsesteps[3] = { 0.2, 1/15., 1/7.5 };
- (void) pulse {
    
    _initialTransform = [self transform];
    
    self.transform = CGAffineTransformScale(_initialTransform, 0.6, 0.6);
    
    [self animateInitialGrow];
}

-(void)animateInitialGrow{
    [UIView animateWithDuration:pulsesteps[0] animations:^{
        self.transform = CGAffineTransformScale(_initialTransform, 1.1, 1.1);
    } completion:^(BOOL finished){
        if(finished){
            [self animateShrink];
        }
    }];
}

-(void)animateShrink{
    [UIView animateWithDuration:pulsesteps[1] animations:^{
        self.transform = CGAffineTransformScale(_initialTransform, 0.9, 0.9);
    } completion:^(BOOL finished){
        if(finished){
            [self animateFinalGrow];
        }
    }];
}

-(void)animateFinalGrow{
    [UIView animateWithDuration:pulsesteps[1] animations:^{
        self.transform = CGAffineTransformScale(_initialTransform, 1.0, 1.0);
    }];
}

@end
