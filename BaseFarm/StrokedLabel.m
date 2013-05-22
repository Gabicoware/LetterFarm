//
//  StrokedLabel.m
//  LetterFarm
//
//  Created by Daniel Mueller on 1/7/13.
//
//

#import "StrokedLabel.h"

@implementation StrokedLabel

-(void)drawTextInRect:(CGRect)rect{
    
    if (self.text == nil || [self.text length] == 0) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [[self textColor] CGColor]);
    CGContextSetStrokeColorWithColor(context, [[self shadowColor] CGColor]);
    
    CGContextSetLineWidth(context,10.0);
    CGContextSetLineCap(context, kCGLineCapButt);
    CGContextSetMiterLimit(context, 1.0);
	// Some initial setup for our text drawing needs.
	// First, we will be doing our drawing in Helvetica-36pt with the MacRoman encoding.
	// This is an 8-bit encoding that can reference standard ASCII characters
	// and many common characters used in the Americas and Western Europe.
	CGContextSelectFont(context, [self.font.fontName UTF8String], [self.font pointSize], kCGEncodingMacRoman);
	// Next we set the text matrix to flip our text upside down. We do this because the context itself
	// is flipped upside down relative to the expected orientation for drawing text (much like the case for drawing Images & PDF).
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
	// And now we actually draw some text. This screen will demonstrate the typical drawing modes used.
    
    const char *string = [self.text UTF8String];
    size_t length = strlen(string);
    
    CGFloat height = self.bounds.size.height - (self.bounds.size.height - self.font.lineHeight)/2.0;
    
    CGSize measuredSize = [self.text sizeWithFont:self.font constrainedToSize:self.bounds.size];
    
    CGFloat drawingX = (self.bounds.size.width - measuredSize.width)/2.0;
    
	CGContextSetTextDrawingMode(context, kCGTextStroke);
    CGContextSetLineWidth(context,3.0);
	CGContextShowTextAtPoint(context, drawingX, height, string, length);
    CGContextSetLineWidth(context,6.0);
	CGContextShowTextAtPoint(context, drawingX, height, string, length);
    CGContextSetLineWidth(context,9.0);
	CGContextShowTextAtPoint(context, drawingX, height, string, length);
    
	CGContextSetTextDrawingMode(context, kCGTextFill);
	CGContextShowTextAtPoint(context, drawingX, height, string, length);
	
}

@end
