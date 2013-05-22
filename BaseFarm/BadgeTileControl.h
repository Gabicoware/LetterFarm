//
//  BadgeTileControl.h
//  LetterFarm
//
//  Created by Daniel Mueller on 2/5/13.
//
//

#import "TileControl.h"

typedef enum _BadgeType{
    BadgeTypeNone,
    BadgeTypeComplete,
    BadgeTypeLocked,
}BadgeType;

@interface BadgeTileControl : TileControl

@property (nonatomic) BadgeType badgeType;

@end
