//
//  TileUtilities.m
//  Letter Farm
//
//  Created by Daniel Mueller on 4/21/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "TileUtilities.h"
#import "BaseFarm.h"
#import "TileView.h"

#ifdef COLOR_WORD

#define TILE_VIEW_BOUNDS ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? CGRectMake(0,0,72,62) : CGRectMake(0,0,60,62) )

#else

#define TILE_VIEW_BOUNDS ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? CGRectMake(0,0,72,62) : CGRectMake(0,0,42,60) )

#endif

#define TILE_VIEW_SPACING 2.0

CGFloat CGPointDist(CGPoint point1, CGPoint point2){
    return sqrt(pow(point1.x - point2.x, 2.0) + pow(point1.y - point2.y, 2.0));
}

CGPoint CGPointRound(CGPoint point){
    return CGPointMake(round(point.x), round(point.y));
}

@implementation TileUtilities

+(CGRect)defaultTileBounds{
    return TILE_VIEW_BOUNDS;
}

+(NSInteger)indexOfClosestTileTo:(CGPoint)center fromTiles:(NSArray*)tiles{
    NSInteger result = NSNotFound;
    
    NSInteger index = 0;
    
    CGFloat currentMinimumDistance = CGFLOAT_MAX;
    
    for (id object in tiles) {
        
        TileView* tile = OBJECT_IF_OF_CLASS(object, TileView);
        
        if (tile != nil) {
            CGPoint tileCenter = [tile defaultCenter];
            
            CGFloat distance = CGPointDist(tileCenter, center);
            
            if (distance < currentMinimumDistance) {
                result = index;
                currentMinimumDistance = distance;
            }
        }
        index++;
        
    }
    
    return result;

}

+(NSInteger)indexOfClosestTileCenterTo:(CGPoint)center fromCenters:(NSArray*)tileCenters{
    
    NSInteger result = NSNotFound;
        
    NSInteger index = 0;
    
    CGFloat currentMinimumDistance = CGFLOAT_MAX;
    
    for (id object in tileCenters) {
        
        NSValue* tileCenterValue = OBJECT_IF_OF_CLASS(object, NSValue);
        
        if (tileCenterValue != nil) {
            CGPoint tileCenter = [tileCenterValue CGPointValue];
            
            CGFloat distance = CGPointDist(tileCenter, center);
            
            if (distance < currentMinimumDistance) {
                result = index;
                currentMinimumDistance = distance;
            }
        }
        index++;
        
    }
    
    return result;
    
}

+(TilePointPosition)positionOfPoint:(CGPoint)point relativeToTileCenter:(CGPoint)tileCenter size:(CGSize)tileSize{
    
    CGFloat rectY = tileCenter.y - tileSize.height;
    CGFloat rectHeight = tileSize.height*2.0;
    
    CGFloat quarterWidth = tileSize.width/4.0;
    
    CGRect beforeRect = CGRectMake(tileCenter.x - quarterWidth*3.0, rectY , 2.0*quarterWidth, rectHeight);
    CGRect onRect = CGRectMake(tileCenter.x - quarterWidth*1.0, rectY , quarterWidth*2.0, rectHeight);
    CGRect afterRect = CGRectMake(tileCenter.x + quarterWidth*1.0, rectY, 2.0*quarterWidth, rectHeight);
    
    TilePointPosition position = TilePointPositionOff;
    
    if (CGRectGetMinY(onRect) < point.y && point.y < CGRectGetMaxY(onRect)) {
        
        if (CGRectContainsPoint(beforeRect, point)) {
            position = TilePointPositionBefore;
        }else if (CGRectContainsPoint(onRect, point)) {
            position = TilePointPositionOn;
        }else if (CGRectContainsPoint(afterRect, point)) {
            position = TilePointPositionAfter;
        }else if(point.x < CGRectGetMinX(beforeRect)){
            position = TilePointPositionFarBefore;
        }else if( CGRectGetMaxX(afterRect) < point.x){
            position = TilePointPositionFarAfter;
        }
        
    }
    return position;

}

+(BOOL)isOnPoint:(CGPoint)point relativeToTileCenter:(CGPoint)tileCenter size:(CGSize)tileSize{
    
    CGRect containingRect = CGRectMake(tileCenter.x - tileSize.width/2.0, tileCenter.y - tileSize.height/2.0, tileSize.width, tileSize.height);
    
    return CGRectContainsPoint(containingRect, point);
    
}

+(CGPoint)centerWithGuideFrame:(CGRect)guideFrame index:(int)index count:(int)count{
    
    CGFloat f_index = (CGFloat)index;
    CGFloat f_count = (CGFloat)count;
    
    CGFloat trayMidY = CGRectGetMidY(guideFrame);
    
    CGFloat tileWidth = TILE_VIEW_BOUNDS.size.width;
    
    CGFloat tilesWidth = f_count*tileWidth + (f_count - 1.0)*TILE_VIEW_SPACING;
    
    CGFloat tileCenterOffset = f_index*TILE_VIEW_SPACING + (f_index + 0.5)*tileWidth;
    
    CGFloat leftMargin = (guideFrame.size.width - tilesWidth)/2.0;
    
    CGFloat tileCenterX = tileCenterOffset + leftMargin;
    
    CGPoint tileCenter = CGPointMake(tileCenterX, trayMidY);
    
    return CGPointRound(tileCenter);
    
}

+(TileView*)newTileView{
    CGRect frame = TILE_VIEW_BOUNDS;
    TileView* tileView = [[TileView alloc] initWithFrame:frame];
    return tileView;
}

///WARNING!!!!! PARALLEL FUNCTIONS BELOW! MODIFY BOTH WITH CARE!!!!

+(NSMutableArray*)tilesForLetters:(NSArray*)letters existingTiles:(NSArray*)existingTiles guideView:(UIView*)guideView superview:(UIView*)superview animateFromRight:(BOOL)animate{
    
    BOOL existingTilesExist = YES;
    
    for (int index = 0; index < [existingTiles count]; index++) {
        TileView* tileView = [existingTiles objectAtIndex:index];
        
        if (![letters containsObject:[tileView letter]]) {
            existingTilesExist = NO;
        }
        
    }
    
    NSAssert(existingTilesExist,@"does exist");
    
    CGRect guideViewFrame = [superview convertRect:[guideView bounds] fromView:guideView];
    
    NSMutableArray* mutableTileArray = [NSMutableArray array];
    
    
    int existingTileIndex = 0;
    
    CGFloat fromRightX = guideViewFrame.origin.x + guideViewFrame.size.width + TILE_VIEW_BOUNDS.size.width/2.0;
    CGFloat fromRightY = CGRectGetMidY(guideViewFrame);
    
    CGPoint fromRightCenter = CGPointMake(fromRightX, fromRightY);
    
    for (int index = 0; index < [letters count]; index++) {
        
        NSString* letter = [letters objectAtIndex:index];
        
        TileView* tileView = nil;
        if (existingTileIndex < [existingTiles count]) {
            tileView = [existingTiles objectAtIndex:existingTileIndex];
            if ([[tileView letter] isEqualToString:letter]) {
                existingTileIndex++;
            }else{
                tileView = nil;
            }
        }
        
        CGPoint center = [TileUtilities centerWithGuideFrame:guideViewFrame index:index count:[letters count]];
        
        if (tileView == nil) {
            
            CGRect frame = TILE_VIEW_BOUNDS;
            
            frame.origin.x = fromRightX - frame.size.width/2.0;
            frame.origin.y = fromRightX - frame.size.height/2.0;
            
            tileView = [[TileView alloc] initWithFrame:frame];
            
            [tileView setLetter:letter];
            [tileView setNeedsLayout];
            
            [superview addSubview:tileView]; 
            if (animate) {
                
                [tileView setCenter:fromRightCenter];
                [tileView setDefaultCenter:center animated:YES];
                
            }else{
                [tileView setDefaultCenter:center animated:NO];
            }
            
            
            [mutableTileArray addObject:tileView];
        }else{
            
            [superview addSubview:tileView]; 
            [tileView setDefaultCenter:center animated:YES];
            [mutableTileArray addObject:tileView];
        }
        
    }
    
    return mutableTileArray;
}


+(NSMutableArray*)tilesForColors:(NSArray*)colors existingTiles:(NSArray*)existingTiles guideView:(UIView*)guideView superview:(UIView*)superview animateFromRight:(BOOL)animate{
    
    BOOL existingTilesExist = YES;
    
    for (int index = 0; index < [existingTiles count]; index++) {
        TileView* tileView = [existingTiles objectAtIndex:index];
        
        if (![colors containsObject:[tileView color]]) {
            existingTilesExist = NO;
        }
        
    }
    
    NSAssert(existingTilesExist,@"does exist");
    
    CGRect guideViewFrame = [superview convertRect:[guideView bounds] fromView:guideView];
    
    NSMutableArray* mutableTileArray = [NSMutableArray array];
        
    int existingTileIndex = 0;
    
    CGFloat fromRightX = guideViewFrame.origin.x + guideViewFrame.size.width + TILE_VIEW_BOUNDS.size.width/2.0;
    CGFloat fromRightY = CGRectGetMidY(guideViewFrame);
    
    CGPoint fromRightCenter = CGPointMake(fromRightX, fromRightY);
    
    for (int index = 0; index < [colors count]; index++) {
        
        NSString* color = [colors objectAtIndex:index];
        
        TileView* tileView = nil;
        if (existingTileIndex < [existingTiles count]) {
            tileView = [existingTiles objectAtIndex:existingTileIndex];
            if ([[tileView color] isEqualToString:color]) {
                existingTileIndex++;
            }else{
                tileView = nil;
            }
        }
        
        CGPoint center = [TileUtilities centerWithGuideFrame:guideViewFrame index:index count:[colors count]];
        
        
        if (tileView == nil) {
            
            CGRect frame = TILE_VIEW_BOUNDS;
            
            frame.origin.x = fromRightX - frame.size.width/2.0;
            frame.origin.y = fromRightX - frame.size.height/2.0;
            
            tileView = [[TileView alloc] initWithFrame:frame];
            
            [tileView setColor:color];
            [tileView setNeedsLayout];
            
            [superview addSubview:tileView];
            if (animate) {
                
                [tileView setCenter:fromRightCenter];
                [tileView setDefaultCenter:center animated:YES];
                
            }else{
                [tileView setDefaultCenter:center animated:NO];
            }
            
            
            [mutableTileArray addObject:tileView];
        }else{
            
            [superview addSubview:tileView];
            [tileView setDefaultCenter:center animated:YES];
            [mutableTileArray addObject:tileView];
        }
        
    }
    
    return mutableTileArray;
}

///WARNING!!!!! PARALLEL FUNCTIONS ABOVE! MODIFY BOTH WITH CARE!!!!

+(NSMutableArray*)tilesForLetters:(NSArray*)letters guideView:(UIView*)guideView superview:(UIView*)superview{
    return [TileUtilities tilesForLetters:letters existingTiles:nil guideView:guideView superview:superview animateFromRight:NO];
}

+(NSMutableArray*)tilesForColors:(NSArray*)colors guideView:(UIView*)guideView superview:(UIView*)superview{
    return [TileUtilities tilesForColors:colors existingTiles:nil guideView:guideView superview:superview animateFromRight:NO];
}


+(TileView*)tileWithTile:(TileView*)tile{
    
    
    TileView* tileView = [[TileView alloc] initWithFrame:[tile frame]];
    
    NSString* letter = [tile letter];
    [tileView setLetter:letter];
    
    NSString* color = [tile color];
    [tileView setColor:color];
    
    [tileView setNeedsLayout];
    
    CGPoint center = [tile defaultCenter];
    
    [tileView setDefaultCenter:center animated:NO];
    
    return tileView;
    
}


@end
