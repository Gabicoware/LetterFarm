//
//  ImageProviderTests.m
//  LetterFarm
//
//  Created by Daniel Mueller on 1/21/13.
//
//

#import "ImageProviderTests.h"
#import "ImageProviderManager.h"
#import "TileImageProvider.h"

@implementation ImageProviderTests

-(void)testImageProvider{
    TileImageProvider* tileImageProvider = [[ImageProviderManager sharedImageProviderManager] newImageProviderWithName:@"sheep"];
    
    STAssertTrue([tileImageProvider.images count] != 0, @"");
}

@end
