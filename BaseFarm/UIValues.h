//
//  UIValues.h
//  LetterFarm
//
//  Created by Daniel Mueller on 2/21/13.
//
//

#import <Foundation/Foundation.h>

@interface UIValues : NSObject

+(UIColor*)blueTextColor;

+(UIFont*)letterFontOfSize:(CGFloat)fontSize;

+(UIColor*)colorWithLetter:(NSString*)letter;

@end
