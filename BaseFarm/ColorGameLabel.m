//
//  ColorGameLabel.m
//  LetterFarm
//
//  Created by Daniel Mueller on 4/29/13.
//
//

#import "ColorGameLabel.h"
#import "NSString+LF.h"
#import "UIValues.h"

@implementation ColorGameLabel

@synthesize startWord=_startWord, endWord=_endWord, round=_round;

-(void)setEndWord:(NSString *)endWord{
    _endWord = endWord;
    [self setNeedsDisplay];
}

-(void)setStartWord:(NSString *)startWord{
    _startWord=startWord;
    [self setNeedsDisplay];
}

-(void)setRound:(int)round{
    _round=round;
    [self setNeedsDisplay];
}

//we need the entire space (??? I think ???)
- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines{
    return bounds;
}
- (void)drawTextInRect:(CGRect)rect{
    NSString* initialString = [NSString stringWithFormat:@"r%d -",self.round];
    [initialString drawInRect:rect withFont:self.font];
    
    CGFloat colorWordWidth = (rect.size.width - 30 - 30)/2.0;
    
    CGRect startWordRect = rect;
    
    startWordRect.origin.x = 30;
    startWordRect.size.width=colorWordWidth;
    [self drawColorWord:self.startWord inRect:startWordRect];

    NSString* toString = @"to";
    
    CGContextSetGrayFillColor(UIGraphicsGetCurrentContext(), 0.0, 1.0);
    
    CGRect toWordRect = rect;
    
    toWordRect.origin.x = 35 + colorWordWidth;
    toWordRect.size.width=20;
    
    [toString drawInRect:toWordRect withFont:self.font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
    
    CGRect endWordRect = rect;
    
    endWordRect.origin.x = 60 + colorWordWidth;
    endWordRect.size.width=colorWordWidth;
    [self drawColorWord:self.endWord inRect:endWordRect];
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

@end
