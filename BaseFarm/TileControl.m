//
//  TileControl.m
//  LetterFarm
//
//  Created by Daniel Mueller on 2/4/13.
//
//

#import "TileControl.h"
#import "LocalConfiguration.h"
#import "UIValues.h"
#import <QuartzCore/QuartzCore.h>

//this is included here because it is the default
#import "ImageProviderManager.h"


#define DURATION 0.2


@implementation TileControl

@synthesize letter=_letter;
@synthesize color=_color;

-(void)awakeFromNib{
    [self setNeedsDisplay];
}

-(void)setLetter:(NSString *)letter{
    _letter = letter;
    [self setNeedsDisplay];
}

-(void)setColor:(NSString *)color{
    _color = color;
    [self setNeedsDisplay];
}

-(void)setIsSmallFormat:(BOOL)isSmallFormat{
    _isSmallFormat = isSmallFormat;
    [self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor=  [UIColor clearColor];
    }
    return self;
}

-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    [self setNeedsDisplay];
}

-(void)setTileImageProvider:(TileImageProvider *)tileImageProvider{
    _tileImageProvider = tileImageProvider;
    _tileImageProvider.consumerView = self;
    [self setNeedsDisplay];
    
}

-(void)setTileImageName:(NSString*)tileImageName{
    self.tileImageProvider = [[ImageProviderManager sharedImageProviderManager] newImageProviderWithName:tileImageName];
}

-(void)setupTileImageProvider{
    
    if (self.tileImageProvider == nil) {
        _tileImageProvider = [[ImageProviderManager sharedImageProviderManager] newImageProvider];
        _tileImageProvider.consumerView = self;
    }
    
    self.tileImageProvider.isSelected = self.isHighlighted;
}

-(UIImage*)currentImage{
    return [self.tileImageProvider currentImage];
}

-(UIImage*)currentColorImage{
    return [self.tileImageProvider currentColorImage];
}

//this is very similar to the TileView drawRect implementation, with a few minor differences
-(void)drawRect:(CGRect)rect{
    
    [self setupTileImageProvider];
    
    NSString* l = [[self letter] uppercaseString];
    
    CGRect selfBounds = [self bounds];
    
    CGSize letterCenteredSize = CGSizeZero;
    
    UIFont* font = self.font;
    
    if(font == nil){
        font = [UIValues letterFontOfSize:(selfBounds.size.width*0.45)];
    }
    
    UIImage* image = [self currentImage];
    
    letterCenteredSize.width = selfBounds.size.width - 13.0;
    letterCenteredSize.height = selfBounds.size.height - 2.0;
    
    
    CGSize constrainedSize = [l sizeWithFont:font constrainedToSize:letterCenteredSize];
    
    CGRect letterTextFrame = CGRectZero;
    letterTextFrame.origin.x = 13.0 + ( letterCenteredSize.width - constrainedSize.width ) / 2.0;
    letterTextFrame.origin.y = ( letterCenteredSize.height - constrainedSize.height ) / 2.0;
    letterTextFrame.size = constrainedSize;
    
    CGRect backgroundFrame = CGRectZero;
    
    CGSize imageSize = image.size;
    
    if (self.isSmallFormat) {
        imageSize = [ImageProviderManager smallFormatSizeWithSize:imageSize];
    }
    
    backgroundFrame.size =imageSize;
    
    backgroundFrame.origin.x = floor((selfBounds.size.width - imageSize.width)/2.0);
    backgroundFrame.origin.y = floor((selfBounds.size.height - imageSize.height)/2.0);
    
    [image drawInRect:backgroundFrame];
    
    if (self.color != nil && ![[self color] isEqualToString:@"w"]) {
        
        UIImage* maskImage = [self currentColorImage];
                
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSaveGState(context);
        
        UIColor* color = [UIValues colorWithLetter:self.color];
        
        CGContextSetFillColorWithColor(context, color.CGColor);
        
        CGFloat height = self.bounds.size.height;
        CGContextTranslateCTM(context, 0.0, height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        CGRect maskFrame = CGRectZero;
        
        maskFrame.size =maskImage.size;
        
        if (self.isSmallFormat) {
            maskFrame.size = [ImageProviderManager smallFormatSizeWithSize:maskFrame.size];
        }
        
        maskFrame.origin.x = floor((selfBounds.size.width - maskImage.size.width)/2.0);
        maskFrame.origin.y = ceil((selfBounds.size.height - maskImage.size.height)/2.0);

        CGContextClipToMask(context, maskFrame, maskImage.CGImage);
        CGContextFillRect(context, self.bounds);
        CGContextRestoreGState(context);

        CGContextSetRGBFillColor(context, 0.2, 0.2, 0.2, 1.0);
        
    }
    
    [l drawInRect:letterTextFrame withFont:font];
    
}

-(void)setHighlighted:(BOOL)highlighted{
    super.highlighted = highlighted;
    [self setNeedsDisplay];
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@: %p; letter = %@; frame = %@>",NSStringFromClass([self class]), self, self.letter, NSStringFromCGRect(self.frame)];
}

@end