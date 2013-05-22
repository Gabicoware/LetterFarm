//
//  SkyBackgroundView.m
//  LetterFarm
//
//  Created by Daniel Mueller on 12/3/12.
//
//

#import "WorldBackgroundView.h"
#import <QuartzCore/QuartzCore.h>

#define INITIAL_CLOUD_Z {4,11,1,8,13}
#define INITIAL_CLOUD_COUNT 5
#define INITIAL_WIDTH (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 768 : 320)

NSString* UpdateWorldThemeNotification = @"UpdateWorldThemeNotification";
NSString* UpdateWorldThemeNameKey = @"UpdateWorldThemeNameKey";
NSString* WorldThemeSummer = @"WorldThemeSummer";
NSString* WorldThemeAutumn = @"WorldThemeAutumn";
NSString* WorldThemeWinter = @"WorldThemeWinter";
NSString* WorldThemeSpring = @"WorldThemeSpring";

#define SPRING_IMAGE @"hills_spring"
#define SUMMER_IMAGE @"hills_summer"
#define AUTUMN_IMAGE @"hills_autumn"
#define WINTER_IMAGE @"hills_winter"


@interface CloudLayer : CALayer

@property (nonatomic) UIImage* cloudImage;

@end

@implementation CloudLayer


-(void)drawInContext:(CGContextRef)ctx{
    
    CGRect cloudFrame = CGRectZero;
    cloudFrame.size = self.cloudImage.size;
        
    CGContextTranslateCTM(ctx, 0, cloudFrame.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    CGContextDrawImage(ctx, cloudFrame, self.cloudImage.CGImage);
}

@end

@interface SkyLayer : CALayer

@property (nonatomic) NSTimer* animationTimer;

-(void)prepopulateClouds;

@property (nonatomic) UIImage* grassImage;

@property (nonatomic) NSString* worldTheme;

@end

@implementation SkyLayer

-(void)dealloc{
    [self.animationTimer invalidate];
}

@synthesize animationTimer=_animationTimer;
@synthesize worldTheme=_worldTheme;

-(id)init{
    if((self = [super init])){
#ifndef FREEZE_START_SCREEN
        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                               target:self
                                                             selector:@selector(didFireWithTimer:)
                                                             userInfo:nil
                                                              repeats:YES];
#endif
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUpdateWorldThemeNotification:) name:UpdateWorldThemeNotification object:nil];
        
        
        self.contentsScale = [[UIScreen mainScreen] scale];
        
        self.worldTheme = WorldThemeSummer;
        
    }
    return self;
}

-(void)setWorldTheme:(NSString *)worldTheme{
    _worldTheme = worldTheme;
    
    if ([worldTheme isEqual:WorldThemeWinter]) {
        self.grassImage = [UIImage imageNamed:WINTER_IMAGE];
    }else if ([worldTheme isEqual:WorldThemeAutumn]) {
        self.grassImage = [UIImage imageNamed:AUTUMN_IMAGE];
    }else if ([worldTheme isEqual:WorldThemeSpring]) {
        self.grassImage = [UIImage imageNamed:SPRING_IMAGE];
    }else{
        self.grassImage = [UIImage imageNamed:SUMMER_IMAGE];
    }
    
    [self setNeedsDisplay];
    
}

-(void)handleUpdateWorldThemeNotification:(NSNotification*)notification{
    NSString* theme = [[notification userInfo] objectForKey:UpdateWorldThemeNameKey];
    
    BOOL isValidTheme = [@[WorldThemeSummer,WorldThemeWinter,WorldThemeAutumn,WorldThemeSpring] containsObject:theme];
    
    if (isValidTheme) {
        self.worldTheme = theme;
    }
    
}

-(void)prepopulateClouds{
    
    CGFloat xIncrement = INITIAL_WIDTH/INITIAL_CLOUD_COUNT ;
    
    int perceivedZs[] = INITIAL_CLOUD_Z;
    
    CGFloat currentX = 0;
    for (int index = 0; index < INITIAL_CLOUD_COUNT; index++) {
        int cloudIndex = index%3;
        CGFloat perceivedZ = perceivedZs[index];
        [self createCloudLayerWithX:currentX cloudType:cloudIndex z:perceivedZ];
        currentX += xIncrement;
    }
    
}


-(void)drawInContext:(CGContextRef)ctx{
    
    CGColorSpaceRef rgbColorspace = CGColorSpaceCreateDeviceRGB();
    
    
    CGFloat topY = 0.0; //CGRectGetMinY(self.bounds);
    CGFloat bottomY = 1.0;//CGRectGetMaxY(self.bounds);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        bottomY = self.bounds.size.height - 404;
    }else{
        bottomY = self.bounds.size.height - 268;
    }
    
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 0.0/255.0, 164.0/255.0, 202.0/255.0, 1.0,  // Start color
        132.0/255.0, 232.0/255.0, 244.0/255.0, 1.0 }; // End color
    CGGradientRef gradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(self.bounds), topY );
    CGPoint endPoint = CGPointMake(CGRectGetMidX(self.bounds), bottomY );
    
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, kCGGradientDrawsAfterEndLocation);
    
    CGGradientRelease(gradient);

    CGColorSpaceRelease(rgbColorspace);
    
    CGRect grassFrame = CGRectZero;
    grassFrame.size = self.grassImage.size;
    
    grassFrame.origin.y = self.bounds.size.height - self.grassImage.size.height;
    grassFrame.origin.x = (self.bounds.size.width - self.grassImage.size.width)/2.0;
    
    CGContextTranslateCTM(ctx, 0, self.bounds.size.height + grassFrame.origin.y);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    CGContextDrawImage(ctx, grassFrame, self.grassImage.CGImage);
    
    //[self.grassImage drawInRect:grassFrame];

}

-(void)didFireWithTimer:(id)timer{
    if (self.sublayers.count < 8) {
        
        long maxZ = 14;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            maxZ = 14;
        }else{
            maxZ = 20;
        }
        int cloudIndex = random()%3;
        CGFloat perceivedZ = (CGFloat)(random()%maxZ);
        [self createCloudLayerWithX:self.bounds.size.width cloudType:cloudIndex z:perceivedZ];
    }
}

-(void)createCloudLayerWithX:(CGFloat)x cloudType:(int)type z:(CGFloat)perceivedZ{
    [CATransaction begin];
    
    CloudLayer* cloudLayer = [CloudLayer layer];
    
    
    NSString* imageName = @"cloud_1.png";
    
    switch (type) {
        case 0:
            imageName = @"cloud_1.png";
            break;
        case 1:
            imageName = @"cloud_2.png";
            break;
        case 2:
            imageName = @"cloud_3.png";
            break;
    }
    
    UIImage* image = [UIImage imageNamed:imageName];
    
    cloudLayer.cloudImage = image;
    
    [cloudLayer setNeedsDisplay];
    
    CGRect cloudLayerFrame = CGRectZero;
    
    cloudLayerFrame.size = image.size;
    cloudLayerFrame.origin.x = x;
    
    cloudLayer.frame = cloudLayerFrame;
    
    [self addSublayer:cloudLayer];
    
    
    CGPoint destPoint = cloudLayer.position;
    
    destPoint.x = -1.0*cloudLayerFrame.size.width/2.0;
    
    CGFloat maxY = 0.0;
    CGFloat rate = 1.0;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        maxY = 404;
        rate = 35.0;
    }else{
        maxY = 200;
        rate = 18.0;
    }
        
    
    CGFloat perceivedY = maxY*(1 - pow(0.9, perceivedZ));
    
    CGPoint cloudLayerPosition = cloudLayer.position;
    cloudLayerPosition.y = perceivedY;
    cloudLayer.position = cloudLayerPosition;
    
    
    destPoint.y = floor(perceivedY);
    
    
    cloudLayer.affineTransform = CGAffineTransformScale(cloudLayer.affineTransform, 1/pow(1.1, perceivedZ), 1/pow(1.1, perceivedZ));
        
    [CATransaction commit];

#ifndef FREEZE_START_SCREEN
    CGFloat perceivedDistance = (cloudLayer.position.x - destPoint.x)*pow(1.1, perceivedZ);
    
    CGFloat duration = perceivedDistance/rate;
    [self animateLayer:cloudLayer toPosition:destPoint withDuration:duration];
#endif
}

-(void)animateLayer:(CALayer*)layer toPosition:(CGPoint)position withDuration:(CGFloat)duration{
    // Prepare the animation from the current position to the new position
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    
    animation.fromValue = [layer valueForKey:@"position"];
    animation.toValue = [NSValue valueWithCGPoint:position];
    animation.delegate = self;
    
    animation.duration = duration;
    
    [animation setValue:layer forKey:@"cloudLayer"];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    // Add the animation, overriding the implicit animation.
    [layer addAnimation:animation forKey:@"position"];
}

- (void)animationDidStart:(CAAnimation *)anim{
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    CALayer *animatedLayer = [anim valueForKey:@"cloudLayer"];
    [animatedLayer removeFromSuperlayer];
    
}


@end

@interface WorldBackgroundView()

@property (nonatomic) SkyLayer* skyLayer;

@end

@implementation WorldBackgroundView

-(void)layoutSubviews{
    [super layoutSubviews];
    
    if (self.skyLayer == nil) {
        self.skyLayer = [SkyLayer layer];
        [self.skyLayer prepopulateClouds];
        self.skyLayer.opaque = YES;
    }
    [[self layer] insertSublayer:self.skyLayer atIndex:0];
    
    CGRect skyFrame = CGRectZero;
    skyFrame.size = self.layer.bounds.size;
    
    self.skyLayer.frame = skyFrame;
    [self.skyLayer setNeedsDisplay];
    
}

@end
