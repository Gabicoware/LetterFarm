//
//  BadgeTileControl.m
//  LetterFarm
//
//  Created by Daniel Mueller on 2/5/13.
//
//

#import "BadgeTileControl.h"

@implementation BadgeTileControl

@synthesize badgeType=_badgeType;

-(void)setBadgeType:(BadgeType)badgeType{
    _badgeType = badgeType;
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect{
    //allow the subclass drawing to occur normally
    [super drawRect:rect];
    
    UIImage* badgeImage = nil;
    
    switch (_badgeType) {
        case BadgeTypeNone:
            break;
        case BadgeTypeComplete:
            badgeImage = [UIImage imageNamed:@"check_mark"];
            break;
        case BadgeTypeLocked:
            badgeImage = [UIImage imageNamed:@"padlock"];
            break;
    }
    
    if(badgeImage != nil){
        CGSize selfSize = self.bounds.size;
        
        CGSize imageSize = badgeImage.size;
        
        CGRect imageRect = CGRectMake(selfSize.width - imageSize.width, selfSize.height - imageSize.height, imageSize.width, imageSize.height);
        
        [badgeImage drawInRect:imageRect];
    }
    
}

@end
