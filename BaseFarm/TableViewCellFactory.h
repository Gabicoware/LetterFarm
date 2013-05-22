//
//  TableViewCellFactory.h
//  Letter Farm
//
//  Created by Daniel Mueller on 6/27/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WordLabel.h"
#import "TileView.h"
#ifdef COLOR_WORD
#import "ColorGameLabel.h"
#endif
@interface TableViewCellFactory : NSObject

+(UITableViewCell*)newWordTableViewCellWithReuseIdentifier:(NSString*)identifier;
+(UITableViewCell*)newArrowTableViewCellWithReuseIdentifier:(NSString*)identifier;

+(UITableViewCell*)newGameTableViewCellWithReuseIdentifier:(NSString*)identifier;
+(UITableViewCell*)newTextOpponentTableViewCellWithReuseIdentifier:(NSString*)identifier;
+(UITableViewCell*)newPurchasableTableViewCellWithReuseIdentifier:(NSString*)identifier;;
+(UITableViewCell*)newTableViewCellWithReuseIdentifier:(NSString*)identifier;
+(UITableViewCell*)newTableViewCellWithReuseIdentifier:(NSString*)identifier style:(UITableViewCellStyle)style;
+(UITableViewCell*)newSliderTableViewCellWithReuseIdentifier:(NSString*)identifier;
+(UITableViewCell*)newSwitchTableViewCellWithReuseIdentifier:(NSString*)identifier;
+(UITableViewCell*)newHistoryTableViewCellWithReuseIdentifier:(NSString*)identifier;
+(UITableViewCell*)newMatchTableViewCellWithReuseIdentifier:(NSString*)identifier;
+(UITableViewCell*)newAnimalTableViewCellWithReuseIdentifier:(NSString*)identifier;

@end


@interface UITableViewCell (CustomDifficulty)


@property (weak, nonatomic, readonly) UILabel* sliderLabel;
@property (weak, nonatomic, readonly) UISlider* slider;
@end

@interface UITableViewCell (Preferences)

@property (weak, nonatomic, readonly) UISwitch* uiSwitch;

@end

@interface UITableViewCell (Word)

@property (weak, nonatomic, readonly) WordLabel* wordLabel;

@end

@interface UITableViewCell (GameMenu)

@property (weak, nonatomic, readonly) TileView* tileView;

@property (weak, nonatomic, readonly) UIImageView* serviceImageView;

@end

#ifdef COLOR_WORD
@interface ColorGameTableViewCell:UITableViewCell

@property (weak, nonatomic, readonly) ColorGameLabel* colorGameLabel;

@end
#endif
