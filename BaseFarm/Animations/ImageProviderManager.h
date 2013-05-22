//
//  ImageProviderManager.h
//  LetterFarm
//
//  Created by Daniel Mueller on 1/21/13.
//
//

#import <Foundation/Foundation.h>

#define COLOR_PREFIX @"color_mask_"

extern NSString* DefaultTextureName;

@interface ImageProviderManager : NSObject

+(id)sharedImageProviderManager;

-(id)newImageProviderWithName:(NSString*)name;

+(CGSize)smallFormatSizeWithSize:(CGSize)size;

@end
