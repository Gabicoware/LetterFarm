//
//  EmailSendMatchController.m
//  LetterFarm
//
//  Created by Daniel Mueller on 12/28/12.
//
//

#import "EmailSendMatchController.h"
#import "LFURLCoder.h"

@interface EmailSendMatchController()

//for convenience, we set the completionBlock, instead of passing it in
@property (nonatomic, retain) id completionBlock;

-(UIViewController*)rootViewController;

@property (nonatomic, retain) MFMailComposeViewController* composeController;

@end

@implementation EmailSendMatchController

-(UIViewController*)rootViewController{
    return [[[UIApplication sharedApplication] keyWindow] rootViewController];
}

-(void)sendEmailForMatch:(MatchInfo*)matchInfo withCompletion:(EmailSendCompleteHandler)completionBlock
{
    
    EmailMatch* emailMatch = matchInfo.sourceData;
    
    self.completionBlock = [completionBlock copy];
    
    MFMailComposeViewController* viewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
    viewController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    viewController.mailComposeDelegate = self;
    
    NSString* toEmail = nil;
    if (emailMatch.isSource) {
        toEmail = emailMatch.targetEmail;
    }else{
        toEmail = emailMatch.sourceEmail;
    }
    
    [viewController setToRecipients:[NSArray arrayWithObject:toEmail]];
    
    NSString* matchSubString = [emailMatch.matchID substringToIndex:5];
    
    NSString* subject = [NSString stringWithFormat:@"Letter Farm Game #%@",matchSubString ];
    
    int round = emailMatch.games.count/2 + 1;
    
    NSURL* httpURL = [LFURLCoder encodeMatchInfo:matchInfo];
    
    NSURL* lfURL = [httpURL URLWithScheme:@"lf"];
    
    NSString* body = nil;
    
    NSString* initialMessage = @"";
    
    switch (matchInfo.status) {
        case MatchStatusTheirTurn:
            if (round == 1) {
                initialMessage = @"Let's play Letter Farm!";
            }else{
                initialMessage = @"It's your turn!";
            }
            break;
        case MatchStatusYouWon:
        case MatchStatusTheyWon:
        case MatchStatusTied:
            initialMessage = @"The match is complete!";
            break;
        case MatchStatusYouQuit:
            initialMessage = @"I've quit our match.";
            break;
            
        default:
            break;
    }
    
    body = [NSString stringWithFormat:@"%@<br/><br/>Requires the Letter Farm app.<br /><a href=\"%@\">Install Letter Farm</a><br /><b>or</b><br /><a href=\"%@\">Click Here</a> to open the match directly.", initialMessage, [httpURL absoluteString], [lfURL absoluteString]];
    
    if (round != 1) {
        subject = [@"RE:" stringByAppendingString:subject];
    }
    
    [viewController setSubject:subject];
    [viewController setMessageBody:body isHTML:YES];
    
    [[self rootViewController] presentViewController:viewController animated:YES completion:NULL];
    
    self.composeController = viewController;
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    [self.rootViewController dismissViewControllerAnimated:YES completion:^{
        EmailSendCompleteHandler handler = self.completionBlock;
        handler(result == MFMailComposeResultSent);
        self.completionBlock = nil;
        self.composeController = nil;
    }];
    
}

@end
