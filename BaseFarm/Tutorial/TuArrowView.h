//
//  TuArrowView.h
//  LetterFarm
//
//  Created by Daniel Mueller on 2/28/13.
//
//

#import <UIKit/UIKit.h>

@interface TuArrowView : UIView

-(void)drawArrowFrom:(UIView*)fromView toView:(UIView*)toView;

//setting these directly will not trigger the drawing, and may result in an error
@property (nonatomic) UIView* fromView;
@property (nonatomic) UIView* toView;

@end
