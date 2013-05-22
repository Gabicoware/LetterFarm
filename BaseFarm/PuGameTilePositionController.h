//
//  PuGameTilePositionController.h
//  LetterFarm
//
//  Created by Daniel Mueller on 4/7/13.
//
//

#import <Foundation/Foundation.h>

extern NSString* PuGameTilePositionControllerDidSelectTile;

@protocol PuGameTilePositionController <NSObject,UIGestureRecognizerDelegate>

@property (nonatomic) NSString* activeWord;

@property (nonatomic) NSString* targetWord;

@property (weak, nonatomic, readonly) NSString* proposedActiveWord;

-(void)reload;

-(void)reset;

-(void)canNotMoveToWord:(NSString*)word;

-(void)didMoveToWord:(NSString*)word;

-(void)didCompleteWithWord:(NSString*)word finished:(void(^)(void))finish;

//these are internal items
-(BOOL)hasSelectedTileView;
-(UIView*)keyViewWithLetter:(NSString*)letter;
-(UIView*)activeViewWithIndex:(int)index;

@end