//
//  UIValues.m
//  LetterFarm
//
//  Created by Daniel Mueller on 2/21/13.
//
//

#import "UIValues.h"

@implementation UIValues

+(UIColor*)blueTextColor{
    return [UIColor colorWithRed:71.0/255.0 green:201.0/245.0 blue:225.0/255.0 alpha:1.0];
}

+(UIFont*)letterFontOfSize:(CGFloat)fontSize{
    return [UIFont fontWithName:@"AmericanTypewriter-Bold" size:fontSize];
}

+(UIColor*)colorWithLetter:(NSString*)letter{
    
    letter = [letter lowercaseString];
    
    UIColor* color = [UIColor whiteColor];
    
    if ([letter isEqualToString:@"o"]) {
        color = [UIColor colorWithRed:251/255.0 green: 155/255.0 blue: 51/255.0 alpha: 1.0];
    }else if ([letter isEqualToString:@"y"]) {
        color = [UIColor colorWithRed:241/255.0 green: 224/255.0 blue: 106/255.0 alpha: 1.0];
    }else if ([letter isEqualToString:@"r"]) {
        color = [UIColor colorWithRed:254/255.0 green: 76/255.0 blue: 76/255.0 alpha: 1.0];
    }else if ([letter isEqualToString:@"g"]) {
        color = [UIColor colorWithRed:69/255.0 green: 251/255.0 blue: 95/255.0 alpha: 1.0];
    }else if ([letter isEqualToString:@"b"]) {
        color = [UIColor colorWithRed:74/255.0 green: 119/255.0 blue: 215/255.0 alpha: 1.0];
    }else if ([letter isEqualToString:@"p"]) {
        color = [UIColor colorWithRed:150/255.0 green: 73/255.0 blue: 148.0/255.0 alpha: 1.0];
    }
    
    return color;

}

@end
