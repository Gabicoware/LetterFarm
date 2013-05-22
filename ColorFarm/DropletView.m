//
//  DropletView.m
//  LetterFarm
//
//  Created by Daniel Mueller on 4/14/13.
//
//

#import "DropletView.h"
#import "UIValues.h"

@implementation DropletView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)awakeFromNib{
    self.backgroundColor = [UIColor clearColor];
}

-(void)setColor:(NSString *)color{
    _color = color;
    
    
    [self setNeedsDisplay];
}

-(void)sizeToFit{
    CGRect selfBounds = CGRectZero;
    UIImage* maskImage = [UIImage imageNamed:@"droplet"];
    selfBounds.size = maskImage.size;
    self.bounds = selfBounds;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIImage* maskImage = [UIImage imageNamed:@"droplet"];
    
    CGRect maskFrame = CGRectZero;
    
    CGRect selfBounds = [self bounds];
    
    CGContextSaveGState(context);
    
    UIColor* color = [UIValues colorWithLetter:self.color];
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    CGFloat height = self.bounds.size.height;
    CGContextTranslateCTM(context, 0.0, height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    maskFrame.size =maskImage.size;
    
    maskFrame.origin.x = ceil((selfBounds.size.width - maskImage.size.width)/2.0);
    maskFrame.origin.y = ceil((selfBounds.size.height - maskImage.size.height)/2.0);
    
    CGContextClipToMask(context, maskFrame, maskImage.CGImage);
    CGContextFillRect(context, self.bounds);
    CGContextRestoreGState(context);

    
}

@end
