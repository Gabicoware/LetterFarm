//
//  TuArrowView.m
//  LetterFarm
//
//  Created by Daniel Mueller on 2/28/13.
//
//

#import "TuArrowView.h"

#import <QuartzCore/QuartzCore.h>

#define CIRCLE_STROKE_WIDTH 2.0
#define FILL_COLOR [UIColor colorWithRed:250.0/255.0 green:56.0/255.0 blue:31.0/255.0 alpha:1.0 ].CGColor

#define STROKE_COLOR [UIColor blackColor].CGColor


void CGPathAddDashedHollowCircleInRect(CGMutablePathRef path, CGRect rect);

void CGPathAddArrowBetweenRects(CGMutablePathRef path, CGRect dest, CGRect origin);

@implementation TuArrowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
                
    }
    return self;
}


-(void)drawArrowFrom:(UIView*)fromView toView:(UIView*)toView{
    self.fromView = fromView;
    self.toView = toView;
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetAllowsAntialiasing(ctx, YES);
    CGContextSetShouldAntialias(ctx, YES);
    
    CGContextSetFillColorWithColor(ctx, FILL_COLOR);
    CGContextSetStrokeColorWithColor(ctx, STROKE_COLOR);
    CGContextSetLineWidth(ctx, 2.0);
    
    CGRect circleRect = CGRectInset([self convertRect:self.fromView.bounds fromView:self.fromView], -5.0, -5.0);
    
    CGMutablePathRef path = CGPathCreateMutable();
        
    CGPathAddDashedHollowCircleInRect(path,circleRect);
    
    CGPathCloseSubpath(path);
    
    
    CGContextAddPath(ctx, path);
    CGContextStrokePath(ctx);
    
    CGContextAddPath(ctx, path);
    CGContextFillPath(ctx);
    
    CGPathRelease(path);
    
    //
    path = CGPathCreateMutable();
    
    CGRect origin = [self convertRect:self.toView.bounds fromView:self.toView];
    CGRect dest = [self convertRect:self.fromView.bounds fromView:self.fromView];
    
    CGPathAddArrowBetweenRects(path,origin,dest);
    
    CGPathCloseSubpath(path);
    
    CGContextAddPath(ctx, path);
    CGContextStrokePath(ctx);
    
    CGContextAddPath(ctx, path);
    CGContextFillPath(ctx);
    
    
    CGPathRelease(path);
    
    
}


@end

#define INNER_TIP_HEIGHT 20.0
#define LINE_OFFSET 6.0
#define OUTER_TIP_HEIGHT 25.0
#define OUTER_TIP_OFFSET 11.0
#define END_HEIGHT_OFFSET 10.0


void CGPathAddArrowBetweenRects(CGMutablePathRef path, CGRect dest, CGRect origin){
    
    CGPoint point1 = CGPointMake(CGRectGetMidX(dest), CGRectGetMidY(dest));
    CGPoint point2 = CGPointMake(CGRectGetMidX(origin), CGRectGetMidY(origin));
    
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    
    
    double radius1 = sqrt(pow(CGRectGetWidth(dest),2.0) + pow(CGRectGetHeight(dest),2.0))/2.0;
    double radius2 = sqrt(pow(CGRectGetWidth(origin),2.0) + pow(CGRectGetHeight(origin),2.0))/2.0;
    
    double dist = sqrt(pow(point1.x - point2.x,2.0) + pow(point1.y - point2.y,2.0)) - radius1 - radius2;
    
    [bezierPath moveToPoint:CGPointMake(0.0, radius1)];
    
    [bezierPath addLineToPoint:CGPointMake(OUTER_TIP_OFFSET, radius1 + OUTER_TIP_HEIGHT)];
    [bezierPath addLineToPoint:CGPointMake(LINE_OFFSET, radius1 + INNER_TIP_HEIGHT)];
    
    [bezierPath addLineToPoint:CGPointMake(LINE_OFFSET, radius1 + dist)];
    [bezierPath addLineToPoint:CGPointMake(0.0, radius1 + dist - END_HEIGHT_OFFSET)];
    [bezierPath addLineToPoint:CGPointMake(-1*LINE_OFFSET, radius1 + dist)];
    [bezierPath addLineToPoint:CGPointMake(-1*LINE_OFFSET, radius1 + INNER_TIP_HEIGHT)];
    [bezierPath addLineToPoint:CGPointMake(-1*OUTER_TIP_OFFSET, radius1 + OUTER_TIP_HEIGHT)];
    [bezierPath addLineToPoint:CGPointMake(0.0, radius1)];
    
    [bezierPath closePath];
    
    float direction = -1;//point1.x > point2.x ? 1 : -1.0;
    
    float rotation = direction*atan((point1.x - point2.x)/(point1.y - point2.y));
    
    CGAffineTransform t1 = CGAffineTransformMakeTranslation( point1.x, point1.y);
    
    CGAffineTransform t2 = CGAffineTransformRotate(t1, rotation);
    
    
    [bezierPath applyTransform:t2];
    
    CGPathAddPath(path, NULL, [bezierPath CGPath]);
    
}

#define SEGMENT_COUNT 6
#define THICKNESS_RATIO 0.1
#define SPACING_RATIO 0.01

void CGPathAddDashedHollowCircleInRect(CGMutablePathRef path, CGRect rect){
    
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    
    CGFloat thicknessRatio = 0.1;
    
    //CGPathAddEllipseInRect(path, NULL, rect);
    
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
    CGFloat outerRadius = MIN(rect.size.width, rect.size.height)/2.0;
    
    CGFloat innerRadius = outerRadius*(1 - thicknessRatio);
    
    for (int index = 0; index < SEGMENT_COUNT; index++) {
        
        float f_index = (float)index;
        
        float startAngle = 2*M_PI*(f_index/((float)SEGMENT_COUNT) + SPACING_RATIO);
        float endAngle = 2*M_PI*((1+f_index)/((float)SEGMENT_COUNT) - SPACING_RATIO);
        
        CGPoint innerPoint1 = CGPointZero;
        innerPoint1.x = cos(startAngle)*innerRadius + center.x;
        innerPoint1.y = sin(startAngle)*innerRadius + center.y;
        
        
        CGPoint outerPoint1 = CGPointZero;
        outerPoint1.x = cos(startAngle)*outerRadius + center.x;
        outerPoint1.y = sin(startAngle)*outerRadius + center.y;
        
        CGPoint outerPoint2 = CGPointZero;
        outerPoint2.x = cos(endAngle)*outerRadius + center.x;
        outerPoint2.y = sin(endAngle)*outerRadius + center.y;
        
        CGPoint innerPoint2 = CGPointZero;
        innerPoint2.x = cos(endAngle)*innerRadius + center.x;
        innerPoint2.y = sin(endAngle)*innerRadius + center.y;
        
        [bezierPath moveToPoint:innerPoint1];
        
        [bezierPath addLineToPoint:outerPoint1];
        
        [bezierPath addArcWithCenter:center radius:outerRadius startAngle:startAngle endAngle:endAngle clockwise:YES];
        
        [bezierPath addLineToPoint:outerPoint2];
        
        [bezierPath addLineToPoint:innerPoint2];
        
        [bezierPath addArcWithCenter:center radius:innerRadius startAngle:endAngle endAngle:startAngle clockwise:NO];
        
        [bezierPath addLineToPoint:innerPoint1];
        
        [bezierPath closePath];
        
        CGPathAddPath(path, NULL, [bezierPath CGPath]);
        
    }
    
    

    
}
