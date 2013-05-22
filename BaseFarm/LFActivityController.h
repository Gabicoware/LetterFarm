//
//  LFActivityController.h
//  LetterFarm
//
//  Created by Daniel Mueller on 10/4/12.
//
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

//provides similar functionality to UIActivityViewController
@interface LFActivityController : NSObject<UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic) NSURL* URL;

@property (nonatomic) NSString* message;

-(id)initWithParentViewController:(UIViewController*)viewController;

-(void)show;

@end
