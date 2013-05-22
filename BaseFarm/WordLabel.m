//
//  WordLabel.m
//  Letter Farm
//
//  Created by Daniel Mueller on 6/27/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//


#import "WordLabel.h"
#import "NSString+LF.h"
#import "CGCloudedRect.h"
#import <QuartzCore/QuartzCore.h>
#import "UIValues.h"

#define DESIRED_WIDTH (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 48.0 : 38.0)
#define DESIRED_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 44.0 : 38.0)
#define SPACING (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 4.0 : 2.0)
#define STROKE_WIDTH (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 2.0 : 1.0)
#define FONT_SIZE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 24.0 : 19.0)

@implementation WordLabel

@synthesize text=_text;

-(void)setText:(NSString*)text{
    _text = [text copy];
    
    [self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

-(void)awakeFromNib{
    [self setBackgroundColor:[UIColor clearColor]];
}

#ifdef LETTER_WORD

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    NSArray* letters = [[[self text] uppercaseString] letters];
    
    if (letters != nil && 0 < [letters count]) {
        
        CGFloat desiredWidth = DESIRED_WIDTH;
        CGFloat desiredHeight = DESIRED_HEIGHT;
        
        CGFloat spacing = SPACING;
        
        CGFloat strokeWidth = STROKE_WIDTH;
        
        CGFloat requiredVSpace = strokeWidth + 2.0*spacing;
        
        if(rect.size.height - desiredHeight - requiredVSpace < 0.0 ){
            desiredHeight = floor(rect.size.height - requiredVSpace);
        }
        
        CGFloat letterCount = (CGFloat)[letters count];
        
        CGFloat requiredHSpace = (letterCount + 1.0)*spacing + strokeWidth*letterCount;
        
        if(rect.size.width - desiredWidth*letterCount - requiredHSpace < 0.0){
            desiredWidth = floor((rect.size.width - requiredHSpace)/letterCount);
        }
        
        CGFloat leftMargin = (rect.size.width - desiredWidth*letterCount - (letterCount - 1.0)*spacing )/2.0;
        CGFloat topMargin = floor((rect.size.height - desiredHeight)/2.0)+0.5;
        
        CGContextRef c = UIGraphicsGetCurrentContext();
        
        CGFloat radius = floor(MIN(desiredHeight, desiredWidth)*0.3);
        
        CGFloat fontSize = [self fontSizeThatFitsWithinSize:CGSizeMake(desiredWidth*0.9, desiredHeight*0.9)];
        
        UIFont* font = [UIValues letterFontOfSize:fontSize];

        UIColor* textColor = [UIValues blueTextColor];
        
        for (int index = 0; index < [letters count]; index++) {
            
            CGContextBeginPath(c);
            CGFloat letterLeftMargin = floor(leftMargin + ((desiredWidth + spacing)*(CGFloat)index)) + 0.5;
            
            CGRect letterRect = CGRectMake(letterLeftMargin, topMargin, desiredWidth, desiredHeight );
            
            CGContextAddCloudedRect(c, letterRect, radius);
            
            CGContextSetFillColorWithColor(c, [[UIColor whiteColor] CGColor]);
            CGContextClosePath(c);
            
            CGContextFillPath(c);
            
            CGContextSetFillColorWithColor(c, [textColor CGColor]);
            
            NSString* letter = [letters objectAtIndex:index];
                        
            CGSize letterSize = [letter sizeWithFont:font constrainedToSize:letterRect.size];
            
            CGFloat x = letterRect.origin.x + (letterRect.size.width - letterSize.width)/2.0;
            CGFloat y = letterRect.origin.y + (letterRect.size.height - letterSize.height)/2.0;
            
            CGRect constrainedLetterRect = CGRectMake( x, y, letterSize.width, letterSize.height);
            
            [letter drawInRect:constrainedLetterRect withFont:font];
            
        }
        
        
    }
    
    
}

-(CGFloat)fontSizeThatFitsWithinSize:(CGSize)size{
    
    CGFloat currentFontSize = FONT_SIZE;
    
    UIFont* font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:currentFontSize];
    
    for (NSString* letter in [@"ABCDEFGHIJKLMNOPQRSTUVWXYZ" letters]) {
        
        CGSize letterSize = [letter sizeWithFont:font];
        
        while (size.width < letterSize.width || size.height < letterSize.height) {
            currentFontSize = currentFontSize - 1.0;
            font = [font fontWithSize:currentFontSize];
            letterSize = [letter sizeWithFont:font];
        }
        
    }
    
    return currentFontSize;

}

#endif

#ifdef COLOR_WORD

- (void)drawRect:(CGRect)rect{
    [self drawColorWord:self.text inRect:rect];
}

-(void)drawColorWord:(NSString*)word inRect:(CGRect)rect{
    
    NSArray* letters = word.letters;
    
    CGRect segmentRect = rect;
    segmentRect.size.width = rect.size.width/((CGFloat)letters.count);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    
    for (int letterIndex = 0; letterIndex < letters.count; letterIndex++) {
        NSString* letter = [letters objectAtIndex:letterIndex];
        
        segmentRect.origin.x = rect.origin.x + segmentRect.size.width*((CGFloat)letterIndex);
        
        CGRect strokeRect = CGRectInset(segmentRect, 1.0, 1.0);
        
        CGContextSetGrayFillColor(ctx, 0.3, 1.0);
        
        CGContextFillRect(ctx, strokeRect);
        
        CGRect paintRect = CGRectInset(segmentRect, 2.0, 2.0);
        
        UIColor* color = [UIValues colorWithLetter:letter];
        
        CGContextSetFillColorWithColor(ctx, color.CGColor);
        
        CGContextFillRect(ctx, paintRect);
        
    }
}

#endif

@end
