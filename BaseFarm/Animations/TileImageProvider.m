//
//  TileImageProvider.m
//  LetterFarm
//
//  Created by Daniel Mueller on 1/19/13.
//
//

#import "TileImageProvider.h"


#define FPS 12.0

@interface TileImageProvider()

@property (nonatomic) NSString* lastBaseName;
@property (nonatomic) NSDate* startDate;
@property (nonatomic) BOOL isIdle;

@end

@implementation TileImageProvider{
    NSDictionary* cycleCounts;
    int _lastFrameCount;
}

@synthesize images=_images;

@synthesize isIdle=_isIdle;

-(int)frameCount{
    int result = floor((int)(-1.0*[self.startDate timeIntervalSinceNow]*FPS));
    return result;
}

-(void)resetFrame{
    self.startDate = [NSDate date];
}

-(void)setIsDragging:(BOOL)isDragging{
    if (isDragging != self.isDragging) {
        [self resetFrame];
        _isDragging = isDragging;
    }
}

-(void)setIsWalking:(BOOL)isWalking{
    if (isWalking != self.isWalking) {
        [self resetFrame];
        _isWalking = isWalking;
    }
}

-(void)setIsIdle:(BOOL)isIdle{
    if (isIdle != self.isIdle) {
        [self resetFrame];
        _isIdle = isIdle;
    }
}

-(BOOL)hasIdleImages{
    NSString* baseName = [NSString stringWithFormat: @"%@_idle",self.name];
    return [self imageWithBaseName:baseName frame:0] != nil;
}

-(UIImage*)currentColorImage{
    
    NSString* baseName = [@"color_mask_" stringByAppendingString:self.lastBaseName];
    
    return [self imageWithBaseName:baseName frame:_lastFrameCount];
}

-(UIImage*)currentImage{
    NSString* baseName = nil;
    
    int frame= 0;
    
    if (self.isSelected) {
        baseName = [NSString stringWithFormat: @"%@_static_selected",self.name];
    }else if (self.isDragging) {
        baseName = [NSString stringWithFormat: @"%@_dragging",self.name];
    }else if (self.isWalking) {
        
        baseName = [NSString stringWithFormat: @"%@_walking",self.name];
        int cycleFrameCount = [self cycleCountWithBaseName:baseName];
        frame = self.frameCount%cycleFrameCount;
    }else if (self.isIdle) {
        frame = self.frameCount;
        baseName = [NSString stringWithFormat: @"%@_idle",self.name];
        int cycleFrameCount = [self cycleCountWithBaseName:baseName];
        if (cycleFrameCount <= frame) {
            baseName = [NSString stringWithFormat: @"%@_static",self.name];
            self.isIdle = NO;
            frame = 0;
        }
    }else {
        baseName = [NSString stringWithFormat: @"%@_static",self.name];
    }
    
    self.lastBaseName = baseName;
#ifdef FREEZE_START_SCREEN
    frame = 0;
#endif
    _lastFrameCount = frame;
    
    return [self imageWithBaseName:baseName frame:frame];
    
}

-(void)updateFrame{
    BOOL shouldSetNeedsDisplay = NO;
    if (!self.isSelected ) {
        if (( self.isWalking || self.isIdle) && _lastFrameCount != self.frameCount) {
            shouldSetNeedsDisplay = YES;
        }else{
            
            BOOL beginIdle = 0 == (random()%(5*60*((int)FPS)));
            if (beginIdle && [self hasIdleImages]) {
                self.isIdle = YES;
                shouldSetNeedsDisplay = YES;
            }
        }
    }
    if (shouldSetNeedsDisplay) {
        [self.consumerView setNeedsDisplay];
    }
}

-(UIImage*)imageWithBaseName:(NSString*)baseName frame:(int)frame{
    
    NSString* key = [NSString stringWithFormat:@"%@%04d", baseName, frame];
    
    UIImage* value = [self.images objectForKey:key];
    
    return value;
}

-(int)cycleCountWithBaseName:(NSString*)baseName{
    int index;
    for (index = 0; index < 100; index++) {
        NSString* key = [NSString stringWithFormat:@"%@%04d", baseName, index];
        if ([self.images objectForKey:key] == nil) {
            break;
        }
    }
    return index;
}

@end
