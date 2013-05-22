//
//  TileContainerView.h
//  LetterFarm
//
//  Created by Daniel Mueller on 8/8/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TileContainerView : UIView

//! returns The TileView instances contained in the view, including the children of subviews
@property (readonly, nonatomic) NSArray* tileViews;

@end
