//
//  CGCloudedRect.c
//  LetterFarm
//
//  Created by Daniel Mueller on 9/25/12.
//
//

#include <stdio.h>
#include "CGCloudedRect.h"

void CGContextAddCurve(CGContextRef ctx, CGPoint c, CGPoint e, CGFloat r);

void CGContextAddRoundedRect(CGContextRef c, CGRect rect, CGFloat radius){
    
    CGPoint tl = rect.origin;
    CGPoint tr = CGPointMake(tl.x + rect.size.width, tl.y);
    CGPoint bl = CGPointMake(tl.x, tl.y + rect.size.height);
    CGPoint br = CGPointMake(tl.x + rect.size.width, tl.y + rect.size.height);
    
    CGContextMoveToPoint(c, tl.x + radius, tl.y);
    
    CGContextAddLineToPoint(c, tr.x - radius, tr.y);
    
    CGContextAddCurveToPoint(c, tr.x, tr.y, tr.x, tr.y, tr.x, tr.y + radius);
    
    CGContextAddLineToPoint(c, br.x, br.y - radius);
    
    CGContextAddCurveToPoint(c, br.x, br.y, br.x, br.y, br.x - radius, br.y );
    
    CGContextAddLineToPoint(c, bl.x + radius, bl.y);
    
    CGContextAddCurveToPoint(c, bl.x, bl.y, bl.x, bl.y, bl.x, bl.y - radius);
    
    CGContextAddLineToPoint(c, tl.x, tl.y + radius);
    
    CGContextAddCurveToPoint(c, tl.x, tl.y, tl.x, tl.y, tl.x + radius, tl.y);
    
}

void CGContextAddCloudedRect(CGContextRef c, CGRect rect, CGFloat radius){
    
    CGRect insetRect = CGRectInset(rect, 0.05*rect.size.width,  0.05*rect.size.height);
    
    CGPoint tl = rect.origin;
    CGPoint tr = CGPointMake(tl.x + rect.size.width, tl.y);
    CGPoint bl = CGPointMake(tl.x, tl.y + rect.size.height);
    CGPoint br = CGPointMake(tl.x + rect.size.width, tl.y + rect.size.height);

    CGPoint itl = insetRect.origin;
    CGPoint itr = CGPointMake(itl.x + insetRect.size.width, itl.y);
    CGPoint ibl = CGPointMake(itl.x, itl.y + insetRect.size.height);
    CGPoint ibr = CGPointMake(itl.x + insetRect.size.width, itl.y + insetRect.size.height);
    
    CGFloat internalWidth = itr.x - itl.x - 2*radius;
    
    float hCloudCount = ceilf(internalWidth/(2*radius));
    
    float hCloudWidth = internalWidth/hCloudCount;
    
    CGContextMoveToPoint(c, itl.x + radius, itl.y);
    
    {
        CGPoint start = CGPointMake(itl.x + radius, itl.y);
        
        CGPoint end = CGPointMake(start.x + hCloudWidth, start.y);
        
        CGFloat controlYCoord = tl.y;
        
        for (int index = 0; index < hCloudCount; index++) {
            
            CGFloat controlXCoord = (end.x + start.x)/2.0;
            
            CGContextAddCurveToPoint(c, controlXCoord, controlYCoord, controlXCoord, controlYCoord, end.x, end.y);
            
            start = end;
            end.x = end.x + hCloudWidth;
            
        }
    }
    
    CGContextAddCurve(c,tr,CGPointMake(itr.x, itr.y + radius),0.6);
    
    CGContextAddCurveToPoint(c, tr.x, CGRectGetMidY(rect), tr.x, CGRectGetMidY(rect), ibr.x, ibr.y - radius);
    
    CGContextAddCurve(c,br,CGPointMake(ibr.x - radius, ibr.y),0.6);
    
    
    {
        CGPoint start = CGPointMake(br.x - radius, ibr.y);
        
        CGPoint end = CGPointMake(start.x - hCloudWidth, start.y);
        
        CGFloat controlYCoord = br.y;
        
        for (int index = 0; index < hCloudCount; index++) {
            
            CGFloat controlXCoord = (end.x + start.x)/2.0;
            
            CGContextAddCurveToPoint(c, controlXCoord, controlYCoord, controlXCoord, controlYCoord, end.x, end.y);
            
            start = end;
            end.x = end.x - hCloudWidth;
            
        }
    }
    
    CGContextAddCurve(c,bl,CGPointMake(ibl.x, ibl.y - radius),0.6);
    
    CGContextAddCurveToPoint(c, tl.x, CGRectGetMidY(rect), tl.x, CGRectGetMidY(rect), itl.x, itl.y + radius);
    
    CGContextAddCurve(c,tl,CGPointMake(itl.x + radius, itl.y),0.6);
}

void CGContextAddCurve(CGContextRef ctx, CGPoint c, CGPoint e, CGFloat r){
    
    CGPoint s = CGContextGetPathCurrentPoint(ctx);
    
    CGPoint c1 = CGPointZero;
    c1.x = s.x + (c.x -s.x)*r;
    c1.y = s.y + (c.y -s.y)*r;
    
    CGPoint c2 = CGPointZero;
    c2.x = e.x + (c.x -e.x)*r;
    c2.y = e.y + (c.y -e.y)*r;
    
    CGContextAddCurveToPoint(ctx, c1.x, c1.y, c2.x, c2.y, e.x, e.y);
    
}
