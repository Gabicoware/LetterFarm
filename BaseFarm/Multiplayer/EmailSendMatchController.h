//
//  EmailSendMatchController.h
//  LetterFarm
//
//  Created by Daniel Mueller on 12/28/12.
//
//

#import <Foundation/Foundation.h>
#import "EmailMatch.h"
#import <MessageUI/MFMailComposeViewController.h>

typedef void(^EmailSendCompleteHandler)(BOOL didComplete);

@interface EmailSendMatchController : NSObject<MFMailComposeViewControllerDelegate>

-(void)sendEmailForMatch:(MatchInfo*)matchInfo withCompletion:(EmailSendCompleteHandler)completionBlock;

@end
