//
//  TileControl.h
//  LetterFarm
//
//  Created by Daniel Mueller on 2/4/13.
//
//

#import <UIKit/UIKit.h>

#import "TileImageProvider.h"


//similar to the tile view, but acts as a simple button
@interface TileControl : UIControl

//can be replaced at any time
@property (nonatomic) TileImageProvider* tileImageProvider;

-(void)setTileImageName:(NSString*)tileImageName;

@property (nonatomic) NSString* letter;


//valid values are: r,g,b,o,p,y
//All other values are transaparent
@property (nonatomic) NSString* color;

@property (nonatomic) UIFont* font;

@property (nonatomic, assign) BOOL isSmallFormat;

//updated before every drawRect
/*!
 * Base implementation creates a new tileImageProvider if needed, with
 * the consumerView set to self. 
 */
-(void)setupTileImageProvider;

@end
