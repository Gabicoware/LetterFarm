//
//  TileImageProvider.h
//  LetterFarm
//
//  Created by Daniel Mueller on 1/19/13.
//
//

#import <Foundation/Foundation.h>

@interface TileImageProvider : NSObject

@property (nonatomic) BOOL isSelected;
@property (nonatomic) BOOL isDragging;
@property (nonatomic) BOOL isWalking;

@property (nonatomic) NSString* name;

@property (nonatomic, weak) UIView* consumerView;

@property (nonatomic) NSDictionary* images;

-(UIImage*)currentColorImage;

-(UIImage*)currentImage;

-(UIImage*)imageWithBaseName:(NSString*)baseName frame:(int)frame;

-(void)updateFrame;

-(int)cycleCountWithBaseName:(NSString*)baseName;

@end
