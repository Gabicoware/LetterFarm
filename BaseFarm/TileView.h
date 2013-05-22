//
//  Tile.h
//  Letter Farm
//
//  Created by Daniel Mueller on 4/2/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "TileControl.h"

typedef enum _TileState{
    TileStateNormal,
    TileStateActive,
    TileStateEditable,
    TileStateWillReplace,
    TileStateHidden,
    TileStateHiddenAndRemoved,
}TileState;

@interface TileView : TileControl

//changes the default center, but does not change the presentation of the view
-(void)updateDefaultCenter:(CGPoint)defaultCenter;

@property (nonatomic, assign) CGPoint defaultCenter;

-(void)stopAllAnimations;

-(void)setDefaultCenter:(CGPoint)defaultCenter animated:(BOOL)animated;

@property (nonatomic, assign) TileState tileState;

-(void)animateToCenter:(CGPoint)center withState:(TileState)tileState;

-(void)animateToCenter:(CGPoint)center;

-(void)setCenter:(CGPoint)toCenter state:(TileState)tileState animated:(BOOL)animated;

-(void)resetAnimated;

@property (nonatomic) BOOL isWalking;

@end
