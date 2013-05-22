//
//  UIBlockAlertView.h
//  LetterFarm
//
//  Created by Daniel Mueller on 12/22/12.
//
//

#import <UIKit/UIKit.h>

@interface UIBlockAlertView : UIAlertView<UIAlertViewDelegate>


- (id)initWithTitle:(NSString *)title message:(NSString *)message completion:(void (^)(BOOL cancelled, NSInteger buttonIndex))completion cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

@end
