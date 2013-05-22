//
//  TileUtilities.h
//  Letter Farm
//
//  Created by Daniel Mueller on 4/21/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TileView;

typedef enum _TilePointPosition{
    TilePointPositionOff,//the point is too far from the tile
    TilePointPositionFarBefore,//the point is far before the tile,
    TilePointPositionBefore,//the point is in a position that can be considered "before" the tile
    TilePointPositionOn,//the point is directly "on" the tile
    TilePointPositionAfter,//the point is in a position that can be considered "after" the tile
    TilePointPositionFarAfter,//the point is far after the tile
    
} TilePointPosition;

CGFloat CGPointDist(CGPoint point1, CGPoint point2);

CGPoint CGPointRound(CGPoint point);

@interface TileUtilities : NSObject

+(NSInteger)indexOfClosestTileTo:(CGPoint)center fromTiles:(NSArray*)tiles;

+(NSInteger)indexOfClosestTileCenterTo:(CGPoint)center fromCenters:(NSArray*)tileCenters;

+(TilePointPosition)positionOfPoint:(CGPoint)point relativeToTileCenter:(CGPoint)tileCenter size:(CGSize)tileSize;

+(BOOL)isOnPoint:(CGPoint)point relativeToTileCenter:(CGPoint)tileCenter size:(CGSize)tileSize;

+(CGPoint)centerWithGuideFrame:(CGRect)guideFrame index:(int)index count:(int)count;

+(NSMutableArray*)tilesForLetters:(NSArray*)letters guideView:(UIView*)guideView superview:(UIView*)superview;

+(NSMutableArray*)tilesForLetters:(NSArray*)letters existingTiles:(NSArray*)existingTiles guideView:(UIView*)guideView superview:(UIView*)superview animateFromRight:(BOOL)animate;

+(NSMutableArray*)tilesForColors:(NSArray*)colors guideView:(UIView*)guideView superview:(UIView*)superview;

+(NSMutableArray*)tilesForColors:(NSArray*)colors existingTiles:(NSArray*)existingTiles guideView:(UIView*)guideView superview:(UIView*)superview animateFromRight:(BOOL)animate;

+(CGRect)defaultTileBounds;

+(TileView*)tileWithTile:(TileView*)tile;

//a new tile view
+(TileView*)newTileView;

@end
