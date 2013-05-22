//
//  PresentationController.h
//  Letter Farm
//
//  Created by Daniel Mueller on 6/12/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PresentationController : NSObject

-(void)presentView:(UIView*)view withMode:(UIViewContentMode)contentMode;

-(void)dismissCurrentView;

@end
