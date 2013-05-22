//
//  LFAlertView.h
//  Letter Farm
//
//  Created by Daniel Mueller on 4/26/11.
//  Copyright 2011 Squrl. All rights reserved.
//

#import <UIKit/UIKit.h>

//! A custom alert view
/*!
 This class presents an alert style message
 
 The view will be presented with the correct orientation, but will not change if the orientation changes.
 The view does not include a modal gray view to block the background.
 The view removes itself after the timeout.
 */
@interface LFAlertView : UIView {
    CGAffineTransform _initialTransform;
    
    NSTimeInterval _timeout;
    
    UIInterfaceOrientation _interfaceOrientation;
    
    BOOL _isModal;
}

//! the time after which to remove the view
/*!
 This property has a minimum value of 2 seconds
 */
@property (nonatomic, assign) NSTimeInterval timeout;

//! the time after which to remove the view
/*!
 This property has a minimum value of 2 seconds
 */
@property (nonatomic, assign) BOOL isModal;

//! show the view, similar to -[UIAlertView show]
-(void)show;

-(void)remove;

@end
