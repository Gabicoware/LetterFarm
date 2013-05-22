//
//  TableViewCellFactory.m
//  Letter Farm
//
//  Created by Daniel Mueller on 6/27/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#define WORD_LABEL_TAG 1001
#define TILE_VIEW_TAG 1002
#define SERVICE_IMAGE_VIEW_TAG 1009
#define SLIDER_TAG 1006
#define SLIDER_LABEL_TAG 1008
#define COLOR_GAME_LABEL_TAG 10010

#define SWITCH_TAG 1007

#define VIEW_OF_CLASS_WITH_TAG(tag,class)(OBJECT_IF_OF_CLASS([[self contentView] viewWithTag:tag],class))

#import "TableViewCellFactory.h"
#import "BaseFarm.h"

@interface MatchTableViewCell : UITableViewCell

@end


@implementation TableViewCellFactory
+(UITableViewCell*)newTextOpponentTableViewCellWithReuseIdentifier:(NSString*)identifier{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
    UIView* backgroundView = [[UIView alloc] initWithFrame:[cell bounds]];
    [backgroundView setBackgroundColor:[UIColor clearColor]];
    cell.backgroundView = backgroundView;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    cell.textLabel.shadowColor = [UIColor lightGrayColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}
+(UITableViewCell*)newGameTableViewCellWithReuseIdentifier:(NSString*)identifier{
    
#ifdef COLOR_WORD
    
    ColorGameTableViewCell* cell = [[ColorGameTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    
#else
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    
    [[cell textLabel] setAdjustsFontSizeToFitWidth:YES];
    [[cell textLabel] setMinimumFontSize:10.0];
#endif
    
    [[cell detailTextLabel] setAdjustsFontSizeToFitWidth:YES];
    [[cell detailTextLabel] setMinimumFontSize:10.0];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    return cell;
    
}

+(UITableViewCell*)newSliderTableViewCellWithReuseIdentifier:(NSString*)identifier{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    UISlider* slider = [[UISlider alloc] initWithFrame:CGRectMake(10, 18, 300, 26)];
    [slider setTag:SLIDER_TAG];
    [slider setMinimumValue:DifficultyEasy];
    [slider setMaximumValue:DifficultyBrutal];
    [slider setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [[cell contentView] addSubview:slider];
    
    [[cell textLabel] setBackgroundColor:[UIColor clearColor]];
    
    CGRect labelFrame = CGRectMake(10, 2, 300, 20);
    
    UILabel* label = [[UILabel alloc] initWithFrame:labelFrame];
    [label setTag:SLIDER_LABEL_TAG];
    [label setFont:[UIFont systemFontOfSize:13]];
    [label setTextColor:[UIColor darkGrayColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [label setTextAlignment:NSTextAlignmentCenter];
    [[cell contentView] addSubview:label];
    
    return cell;
}

+(UITableViewCell*)newSwitchTableViewCellWithReuseIdentifier:(NSString*)identifier{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    
    UISwitch* uiSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(214, 8, 100.0, 44.0)];
    [uiSwitch setTag:SWITCH_TAG];
    [[cell contentView] addSubview:uiSwitch];
    
    [[cell textLabel] setBackgroundColor:[UIColor clearColor]];
    
    return cell;
}

+(UITableViewCell*)newPurchasableTableViewCellWithReuseIdentifier:(NSString*)identifier{
    UITableViewCell* cell = [TableViewCellFactory newTableViewCellWithReuseIdentifier:identifier style:UITableViewCellStyleValue1];
    
    UIFont* detailFont = [[[cell detailTextLabel] font] fontWithSize:12];
    [[cell detailTextLabel] setFont:detailFont];

    return cell;
}

+(UITableViewCell*)newTableViewCellWithReuseIdentifier:(NSString*)identifier{
    return [TableViewCellFactory newTableViewCellWithReuseIdentifier:identifier style:UITableViewCellStyleDefault];
    
}

+(UITableViewCell*)newTableViewCellWithReuseIdentifier:(NSString*)identifier style:(UITableViewCellStyle)style{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:identifier];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    return cell;
}

+(UITableViewCell*)newHistoryTableViewCellWithReuseIdentifier:(NSString*)identifier{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    
    [[cell textLabel] setAdjustsFontSizeToFitWidth:YES];
    [[cell textLabel] setMinimumFontSize:10.0];
    
    [[cell detailTextLabel] setAdjustsFontSizeToFitWidth:YES];
    [[cell detailTextLabel] setMinimumFontSize:8.0];
    
    //[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

+(UITableViewCell*)newWordTableViewCellWithReuseIdentifier:(NSString*)identifier{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
    WordLabel* wordLabel = [[WordLabel alloc] initWithFrame:[[cell contentView] bounds]];
    
    [wordLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [[cell contentView] addSubview:wordLabel];
    
    [wordLabel setTag:WORD_LABEL_TAG];
    
    
    return cell;
}

+(UITableViewCell*)newArrowTableViewCellWithReuseIdentifier:(NSString*)identifier{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"down_arrow"]];
    
    [imageView setContentMode:UIViewContentModeTopLeft];
    UIViewAutoresizing mask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin;
    [imageView setAutoresizingMask:mask];
    
    CGRect contentViewBounds = cell.contentView.bounds;
    CGRect imageViewFrame = imageView.frame;
    
    imageViewFrame.origin.y = roundf((contentViewBounds.size.height - imageViewFrame.size.height)/2.0);
    imageViewFrame.origin.x = roundf((contentViewBounds.size.width - imageViewFrame.size.width)/2.0);
    
    imageView.frame = imageViewFrame;
    
    [cell.contentView addSubview:imageView];
    
    return cell;

}

+(UITableViewCell*)newMatchTableViewCellWithReuseIdentifier:(NSString*)identifier{
    UITableViewCell* cell = [[MatchTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    TileView* tileView = [[TileView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [tileView setIsSmallFormat:YES];
    [tileView setUserInteractionEnabled:NO];
    tileView.center = CGPointMake(32.0, cell.contentView.bounds.size.height/2.0);
    tileView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    [tileView setTag:TILE_VIEW_TAG];
    [cell.contentView addSubview:tileView];
    
    UIImageView* serviceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,29,15,15)];
    [serviceImageView setUserInteractionEnabled:NO];
    serviceImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    [serviceImageView setTag:SERVICE_IMAGE_VIEW_TAG];
    [tileView addSubview:serviceImageView];
    
    cell.textLabel.minimumFontSize = 12.0;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
    
}

+(UITableViewCell*)newAnimalTableViewCellWithReuseIdentifier:(NSString*)identifier{
    UITableViewCell* cell = [[MatchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    TileView* tileView = [[TileView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [tileView setIsSmallFormat:YES];
    [tileView setUserInteractionEnabled:NO];
    tileView.center = CGPointMake(32.0, cell.contentView.bounds.size.height/2.0);
    tileView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    [tileView setTag:TILE_VIEW_TAG];
    [cell.contentView addSubview:tileView];
    
    cell.textLabel.minimumFontSize = 12.0;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
    
}


@end


@implementation UITableViewCell (CustomDifficulty)

-(UILabel*)sliderLabel{
    return VIEW_OF_CLASS_WITH_TAG(SLIDER_LABEL_TAG, UILabel);
}

-(UISlider*)slider{
    return VIEW_OF_CLASS_WITH_TAG(SLIDER_TAG, UISlider);
}

@end

@implementation UITableViewCell (Preferences)

-(UISwitch*)uiSwitch{
    return VIEW_OF_CLASS_WITH_TAG(SWITCH_TAG, UISwitch);
}

@end

@implementation UITableViewCell (Word)

-(WordLabel*)wordLabel{
    return VIEW_OF_CLASS_WITH_TAG(WORD_LABEL_TAG, WordLabel);
}

@end

@implementation UITableViewCell (GameMenu)

-(TileView*)tileView{
    return VIEW_OF_CLASS_WITH_TAG(TILE_VIEW_TAG, TileView);
}

-(UIImageView*)serviceImageView{
    return VIEW_OF_CLASS_WITH_TAG(SERVICE_IMAGE_VIEW_TAG, UIImageView);
}

@end

@implementation MatchTableViewCell

-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGRect contentViewFrame = self.contentView.frame;
    
    CGRect tileViewFrame = CGRectMake(0, 0, 44, 44);
    CGRect serviceImageViewFrame = CGRectMake(3,29,15,15);
    
    tileViewFrame.origin.y = floorf((contentViewFrame.size.height - tileViewFrame.size.height)/2.0);
    serviceImageViewFrame.origin.y = tileViewFrame.size.height + tileViewFrame.origin.y - serviceImageViewFrame.size.height - 2.0;
    
    self.tileView.frame = tileViewFrame;
    self.serviceImageView.frame = serviceImageViewFrame;
    
    CGRect textLabelFrame = self.textLabel.frame;
    CGRect detailLabelFrame = self.detailTextLabel.frame;
    
    textLabelFrame.origin.x = 52.0;
    detailLabelFrame.origin.x = 52.0;
    
    textLabelFrame.size.width = contentViewFrame.size.width - textLabelFrame.origin.x - 10.0;
    detailLabelFrame.size.width = contentViewFrame.size.width - detailLabelFrame.origin.x - 10.0;
    
    self.textLabel.frame = textLabelFrame;
    self.detailTextLabel.frame = detailLabelFrame;
    
}

@end

#ifdef COLOR_WORD


@implementation ColorGameTableViewCell

-(ColorGameLabel*)colorGameLabel{
    
    ColorGameLabel* label = VIEW_OF_CLASS_WITH_TAG(COLOR_GAME_LABEL_TAG, ColorGameLabel);
    if (label == nil) {
        label = [[ColorGameLabel alloc] initWithFrame:CGRectMake(10, 1, 300, 26)];
        [label setTag:COLOR_GAME_LABEL_TAG];
        [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [[self contentView] addSubview:label];
    }
    return label;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.colorGameLabel.frame = CGRectMake(10, 1, self.contentView.bounds.size.width- 20.0, 20);
    self.colorGameLabel.backgroundColor = [self backgroundColor];
    
    self.detailTextLabel.frame = CGRectMake(10, 23, self.contentView.bounds.size.width- 20.0, 17);
}

@end


#endif
