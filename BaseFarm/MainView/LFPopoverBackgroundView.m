//
//  KSPopoverBackgorundView.m
//
//  Created by Chris Scianski on 12.02.2012.

#import "LFPopoverBackgroundView.h"

// Predefined arrow image width and height
#define ARROW_WIDTH 0.0
#define ARROW_HEIGHT 0.0

// Predefined content insets
#define TOP_CONTENT_INSET 8
#define LEFT_CONTENT_INSET 8
#define BOTTOM_CONTENT_INSET 8
#define RIGHT_CONTENT_INSET 8

#pragma mark - Private interface

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight);
void static fillGradient(CGContextRef ctx, CGRect rect, const CGFloat components[8]);

@interface LFPopoverBackgroundView ()

@property (nonatomic) UIImageView* contentBackgroundView;
@end

#pragma mark - Implementation

@implementation LFPopoverBackgroundView

@synthesize arrowOffset = _arrowOffset, arrowDirection = _arrowDirection, popoverBackgroundImageView = _popoverBackgroundImageView;

#pragma mark - Overriden class methods

// The width of the arrow triangle at its base.
+ (CGFloat)arrowBase 
{
    return ARROW_WIDTH;
}

// The height of the arrow (measured in points) from its base to its tip.
+ (CGFloat)arrowHeight
{
    return ARROW_HEIGHT;
}

// The insets for the content portion of the popover.
+ (UIEdgeInsets)contentViewInsets
{
    return UIEdgeInsetsMake(TOP_CONTENT_INSET, LEFT_CONTENT_INSET, BOTTOM_CONTENT_INSET, RIGHT_CONTENT_INSET);
}

#pragma mark - Custom setters for updating layout


-(void) setArrowOffset:(CGFloat)arrowOffset
{
    _arrowOffset = arrowOffset;
    [self setNeedsLayout];
}

-(void) setArrowDirection:(UIPopoverArrowDirection)arrowDirection
{
    _arrowDirection = arrowDirection;
    [self setNeedsLayout];
}

#pragma mark - Initialization

-(id)initWithFrame:(CGRect)frame 
{    
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor blackColor];
        self.opaque = YES;
    }
    
    return self;
}

#pragma mark - Layout subviews

-(void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    //addRoundedRectToPath(context, self.bounds, 10, 10);
    CGContextClip(context);
    
    UIImage *contentBackgroundImage = [UIImage imageNamed:@"menu_background.png"];
    [contentBackgroundImage drawInRect:self.frame];
    
    CGRect topGradientRect = CGRectMake(0, 0, self.bounds.size.width, 44);
    
    CGFloat components[8] = { 1.0, 1.0, 1.0, 0.4,  // Start color
        1.0, 1.0, 1.0, 0.0 }; // End color
    
    fillGradient(context, topGradientRect, components);
    
    CGContextRestoreGState(context);
    

}

@end

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

//CGFloat components[8] = { 0.0/255.0, 164.0/255.0, 202.0/255.0, 1.0,  // Start color
//132.0/255.0, 232.0/255.0, 244.0/255.0, 1.0 }; // End color


void static fillGradient(CGContextRef ctx, CGRect rect, const CGFloat components[8]){

    CGColorSpaceRef rgbColorspace = CGColorSpaceCreateDeviceRGB();

    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGGradientRef gradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);

    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect) );
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect) );

    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, kCGGradientDrawsAfterEndLocation);

    CGGradientRelease(gradient);
    CGColorSpaceRelease(rgbColorspace);

}
