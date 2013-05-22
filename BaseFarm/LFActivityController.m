//
//  LFActivityController.m
//  LetterFarm
//
//  Created by Daniel Mueller on 10/4/12.
//
//

#import "LFActivityController.h"

#import <Twitter/Twitter.h>

#define CANCEL @"Cancel"
#define TWITTER @"Twitter"
#define FACEBOOK @"Facebook"
#define SMS @"Text"
#define EMAIL @"Email"

@interface LFActivityController()

@property (nonatomic) UIViewController* parentViewController;

@property (nonatomic) TWTweetComposeViewController* tweetComposeViewController;

@end

@implementation LFActivityController

-(id)initWithParentViewController:(UIViewController*)viewController{
    if ((self = [super init])) {
        self.parentViewController = viewController;
    }
    return self;
}

-(void)show{
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    int index = 2;
    
    [actionSheet addButtonWithTitle:FACEBOOK];
    [actionSheet addButtonWithTitle:TWITTER];
    
    BOOL canSMS = [MFMessageComposeViewController canSendText];
    if (canSMS) {
        [actionSheet addButtonWithTitle:SMS];
        index++;
    }
    
    BOOL canEmail = [MFMailComposeViewController canSendMail];
    if (canEmail) {
        [actionSheet addButtonWithTitle:EMAIL];
        index++;
    }
    
    [actionSheet addButtonWithTitle:CANCEL];
    [actionSheet setCancelButtonIndex:index];
    
    [actionSheet showInView:self.parentViewController.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSString* buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        
    if ([buttonTitle isEqualToString:TWITTER]) {
        
        UIViewController* presentingViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        
        // Set up the built-in twitter composition view controller.
        TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
        
        [tweetViewController addURL:self.URL];
        [tweetViewController setInitialText:self.message];
        
        // Create the completion handler block.
        [tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
            // Dismiss the tweet composition view controller.
            [presentingViewController dismissModalViewControllerAnimated:YES];
        }];
        
        // Present the tweet composition view controller modally.
        [presentingViewController presentModalViewController:tweetViewController animated:YES];
        
        
    }else if ([buttonTitle isEqualToString:FACEBOOK]) {
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Facebook Unavailable" message:@"Facebook is not supported in this version of iOS. Update to iOS 6.0 or later for Facebook support." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }else if ([buttonTitle isEqualToString:SMS]) {
        MFMessageComposeViewController* messageController = [[MFMessageComposeViewController alloc] initWithNibName:nil bundle:nil];
        
        NSString* fullString = [NSString stringWithFormat:@"%@\n%@",self.message,self.URL.absoluteString];
        
        [messageController setMessageComposeDelegate:self];
        [messageController setBody:fullString];
        
        [self.parentViewController presentViewController:messageController animated:YES completion:nil];
        
    }else if ([buttonTitle isEqualToString:EMAIL]) {
        
        MFMailComposeViewController* mailController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
        
        NSString* fullString = [NSString stringWithFormat:@"%@\n%@",self.message,self.URL.absoluteString];
        
        [mailController setMailComposeDelegate:self];
        
        [mailController setSubject:@"Letter Farm"];
        [mailController setMessageBody:fullString isHTML:NO];
        [mailController setModalPresentationStyle:UIModalPresentationFormSheet];
        
        [self.parentViewController presentViewController:mailController animated:YES completion:nil];
    }
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

@end
