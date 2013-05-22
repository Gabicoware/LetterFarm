//
//  TileUtilityTests.m
//  Letter Farm
//
//  Created by Daniel Mueller on 5/8/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "TileUtilityTests.h"
#import "TileUtilities.h"

@implementation TileUtilityTests


-(void)testCurrentIndexDetection{
    
    NSInteger nilIndex = [TileUtilities indexOfClosestTileCenterTo:CGPointZero fromCenters:nil];
    
    STAssertEquals(nilIndex, NSNotFound,@"Should return NSNotFound when passed a nil centers array");
    
    NSInteger emptyIndex = [TileUtilities indexOfClosestTileCenterTo:CGPointZero fromCenters:[NSArray array]];
    
    STAssertEquals(emptyIndex, NSNotFound,@"Should return NSNotFound when passed an empty centers array");
    
    NSInteger garbageIndex = [TileUtilities indexOfClosestTileCenterTo:CGPointZero fromCenters:[NSArray arrayWithObjects:@"One", @"Two", nil]];
    
    STAssertEquals(garbageIndex, NSNotFound,@"Should return NSNotFound when passed a garbage centers array");
    
    NSInteger zeroWithGarbageIndex = [TileUtilities indexOfClosestTileCenterTo:CGPointZero fromCenters:[NSArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointZero], @"Two", nil]];
    
    STAssertEquals(zeroWithGarbageIndex, 0, @"Should return 0");
    
    NSInteger oneWithGarbageIndex = [TileUtilities indexOfClosestTileCenterTo:CGPointZero fromCenters:[NSArray arrayWithObjects: @"Two", [NSValue valueWithCGPoint:CGPointZero],nil]];
    
    STAssertEquals(oneWithGarbageIndex, 1, @"Should return 1");
    
    NSArray* centers = [NSArray arrayWithObjects:
                        [NSValue valueWithCGPoint:CGPointMake(0, 0)],
                        [NSValue valueWithCGPoint:CGPointMake(1, 0)],
                        [NSValue valueWithCGPoint:CGPointMake(2, 0)],
                        [NSValue valueWithCGPoint:CGPointMake(3, 0)], 
                        nil];
    
    NSInteger zeroIndex = [TileUtilities indexOfClosestTileCenterTo:CGPointMake(0, 0) fromCenters:centers];
    
    STAssertEquals(zeroIndex, 0, @"Should return 0");
    
}

-(void)testPositionDetection{
    //we won't go too into detail for testing this
    TilePointPosition onPosition = [TileUtilities positionOfPoint:CGPointZero relativeToTileCenter:CGPointZero size:CGSizeMake(1, 1)];
    STAssertEquals(onPosition, TilePointPositionOn, @"Should be on");
    
    TilePointPosition offPosition = [TileUtilities positionOfPoint:CGPointZero 
                                              relativeToTileCenter:CGPointMake(10, 10) 
                                                              size:CGSizeMake(1, 1)];
    STAssertEquals(offPosition, TilePointPositionOff, @"Should be off");
}
@end
