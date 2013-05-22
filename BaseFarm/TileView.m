//
//  Tile.m
//  Letter Farm
//
//  Created by Daniel Mueller on 4/2/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "TileView.h"
#import "LocalConfiguration.h"
#import <QuartzCore/QuartzCore.h>

//this is included here because it is the default
#import "ImageProviderManager.h"


#define DURATION 0.2

@interface TileView()

@property (nonatomic, assign) CGPoint dragOffset;
@property (nonatomic) BOOL isDragging;

@end

@implementation TileView

@synthesize isSmallFormat=_isSmallFormat;

@synthesize defaultCenter=_defaultCenter, dragOffset=_dragOffset, tileState=_tileState;

-(void)awakeFromNib{
    [super awakeFromNib];
    _defaultCenter = self.center;
}

-(void)updateDefaultCenter:(CGPoint)defaultCenter{
    _defaultCenter = defaultCenter;
}

-(void)setDefaultCenter:(CGPoint)defaultCenter{
    [self setDefaultCenter:defaultCenter animated:NO];
}

-(void)setDefaultCenter:(CGPoint)defaultCenter animated:(BOOL)animated{
    _defaultCenter=defaultCenter;
    if (animated) {
        [self animateToCenter:defaultCenter];
    }else{
        [self setCenter:defaultCenter];
    }
}

-(void)setTileState:(TileState)tileState{
    CGPoint centerPoint = [[[self layer] presentationLayer] position];
    
    _tileState = tileState;
    
    [self animateToCenter:centerPoint withState:tileState];
    
}

-(void)stopAllAnimations{
    
    //don't do this if there aren't any animations
    if (0 < [[[self layer] animationKeys] count]) {
        CGAffineTransform transform = [[[self layer] presentationLayer] affineTransform];
        CGPoint centerPoint = [[[self layer] presentationLayer] position];
        CGFloat alpha = [[[self layer] presentationLayer] opacity];
        
        [[self layer] removeAllAnimations];
        
        [self setAlpha:alpha];
        [self setCenter:centerPoint];
        [self setTransform:transform];
    }
    
}

-(void)animateToCenter:(CGPoint)toCenter withState:(TileState)tileState{
    
    [self setCenter:toCenter state:tileState animated:YES];
    
}

-(void)setCenter:(CGPoint)toCenter state:(TileState)tileState animated:(BOOL)animated{
    
    [self stopAllAnimations];
    
    CGAffineTransform toTransform = CGAffineTransformIdentity;
    CGFloat toAlpha = 1.0;
    
    BOOL isUserInteractionEnabled = YES;
    
    switch (tileState) {
        case TileStateNormal:
            toAlpha = 1.0;
            break;
        case TileStateEditable:
            toAlpha = 1.0;
            break;
        case TileStateActive:
            toAlpha = 0.8;
            toTransform = CGAffineTransformMakeScale(1.2,1.2);
            break;
        case TileStateWillReplace:
            toAlpha = 0.4;
            toTransform = CGAffineTransformMakeScale(0.8,0.8);
            break;
        case TileStateHidden:
            toAlpha = 0.0;
            isUserInteractionEnabled = NO;
            break;
        case TileStateHiddenAndRemoved:
            toAlpha = 0.0;
            isUserInteractionEnabled = NO;
            break;
            
    }
    
    [self setUserInteractionEnabled:isUserInteractionEnabled];
    
    void (^animation)(void) = ^{
        self.center = toCenter;
        self.alpha = toAlpha;
        self.transform = toTransform;
    };

    void (^completion)(BOOL finished) = ^(BOOL finished){
        if (finished && TileStateHiddenAndRemoved == tileState) {
            [self removeFromSuperview];
        }
    };
    if (animated) {
        [UIView animateWithDuration:DURATION
                         animations:animation
                         completion:completion];
    }else{
        animation();
        completion(YES);
    }
    
}

-(void)setIsWalking:(BOOL)isWalking{
    _isWalking = isWalking;
    [self setNeedsDisplay];
}

-(void)setIsDragging:(BOOL)isDragging{
    _isDragging = isDragging;
    [self setNeedsDisplay];
}

-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    [self setNeedsDisplay];
}

-(void)setupTileImageProvider{
    
    [super setupTileImageProvider];
    
    self.tileImageProvider.isSelected = self.isSelected;
    self.tileImageProvider.isDragging = self.isDragging;
    self.tileImageProvider.isWalking = self.isWalking;
    
}

//ignore the superclass implementation of the tracking methods

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    //send value changed event
    
    self.isDragging = YES;
    [self setNeedsDisplay];
    
    [self setDefaultCenter:[self center]];
    
    CGPoint location = [touch locationInView:self];
    
    BOOL shouldBegin = CGRectContainsPoint( [self bounds], location ) ;
    
    if(shouldBegin){
        
        CGPoint touchCenter = [touch locationInView:[self superview]];
        
        //CGPoint dragOffset = CGPointMake([self center].x - touchCenter.x, [self center].y - touchCenter.y);
        
        [self setDragOffset:CGPointZero];
        
        CGPoint newCenter = CGPointMake(touchCenter.x + [self dragOffset].x, touchCenter.y + [self dragOffset].y-20.0);
        
        [self setCenter:newCenter];
        
        //[self sendActionsForControlEvents:UIControlEventTouchDown];
        
        [[self superview] bringSubviewToFront:self];
        
    }
    
    return shouldBegin;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    //send value changed event
    
    self.isDragging = YES;
    
    CGPoint touchCenter = [touch locationInView:[self superview]];
    
    CGPoint newCenter = CGPointMake(touchCenter.x + [self dragOffset].x, touchCenter.y + [self dragOffset].y-20.0);
    
    [self setCenter:newCenter];
    
    [self sendActionsForControlEvents:UIControlEventTouchDragInside];
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    //send end event
    self.isDragging = NO;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event{
    
    self.isDragging = NO;
    [self resetAnimated];
    //send cancellation event
}

-(void)animateToCenter:(CGPoint)center{
    
    [self animateToCenter:center withState:_tileState];
    
}

-(void)resetAnimated{
    [self animateToCenter:[self defaultCenter] withState:TileStateNormal];
}

@end
