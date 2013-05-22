//
//  TileContainerView.m
//  LetterFarm
//
//  Created by Daniel Mueller on 8/8/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "TileContainerView.h"
#import "TileView.h"

@implementation TileContainerView

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    BOOL isInside = NO;
    
    for (UIView* view in self.subviews) {
        UIControl* control = OBJECT_IF_OF_CLASS(view, UIControl);
        if (control) {
            CGPoint controlPoint = [self convertPoint:point toView:control];
            if ([control pointInside:controlPoint withEvent:event]) {
                isInside = YES;
            }
        }
    }
    
    return isInside;
}

-(NSArray*)tileViews{
    return [self tileViewsWithSuperview:self];
}

-(NSArray*)tileViewsWithSuperview:(UIView*)superview{
    NSMutableArray* mArray = [NSMutableArray array];
    
    for (UIView* view in superview.subviews) {
        TileView* tile = OBJECT_IF_OF_CLASS(view, TileView);
        if (tile != nil) {
            [mArray addObject:tile];
        }else{
            [mArray addObjectsFromArray:[self tileViewsWithSuperview:view]];
        }
    }
    
    return [NSArray arrayWithArray:mArray];
}

@end
