//
//  LFContactViewController.m
//  LetterFarm
//
//  Created by Daniel Mueller on 1/10/13.
//
//

#import "LFContactViewController.h"
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import <Twitter/Twitter.h>

enum ContactDestinations {
    ContactDestinationsTwitter,
    ContactDestinationsEmail,
    ContactDestinationsReview,
    ContactDestinationsTotal,
};

@interface LFContactViewController ()

@end

@implementation LFContactViewController

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return ContactDestinationsTotal;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    
    static NSString* CellIdentifier = @"ContactTableViewCell";
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    if ([indexPath row] == ContactDestinationsTwitter) {
        cell.textLabel.text = @"Tweet";
        cell.detailTextLabel.text = @"@gabicoware";
    }else if ([indexPath row] == ContactDestinationsEmail) {
        cell.textLabel.text = @"Email";
        cell.detailTextLabel.text = @"feedback@gabicoware.com";
    }else if ([indexPath row] == ContactDestinationsReview) {
        cell.textLabel.text = @"Write a Review";
        cell.detailTextLabel.text = @"";
    }
    
    return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([indexPath row] == ContactDestinationsTwitter) {
        if (NSClassFromString(@"SLComposeViewController") != Nil) {
            [self presentTweetComposeViewController];
        }else{
            [self presentTweetComposeViewController_ios5];
        }
        
        
    }else if ([indexPath row] == ContactDestinationsEmail) {
        [self presentMailComposeViewController];
    }else if ([indexPath row] == ContactDestinationsReview) {
        [self openWriteAReview];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void)openWriteAReview{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/letter-farm-free-word-puzzle/id545019650?mt=8&uo=4"]];
}

-(void)presentTweetComposeViewController{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [mySLComposerSheet setInitialText:@"@gabicoware "];
        
        
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            self.parentViewController.view.hidden = NO;
            [self.parentViewController dismissModalViewControllerAnimated:YES];
        }];
        
        [self.parentViewController presentViewController:mySLComposerSheet animated:YES completion:^{
            self.parentViewController.view.hidden = YES;
        }];
    }
}

-(void)presentTweetComposeViewController_ios5{
    // Set up the built-in twitter composition view controller.
    TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
    
    [tweetViewController setInitialText:@"@gabicoware "];
    
    // Create the completion handler block.
    [tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
        // Dismiss the tweet composition view controller.
        [self.parentViewController dismissModalViewControllerAnimated:YES];
    }];
    
    // Present the tweet composition view controller modally.
    [self.parentViewController presentModalViewController:tweetViewController animated:YES];
}

-(void)presentMailComposeViewController{
    MFMailComposeViewController* mailController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
    
    [mailController setMailComposeDelegate:self];
    [mailController setToRecipients:[NSArray arrayWithObject:@"feedback@gabicoware.com"]];
    [mailController setSubject:@"Letter Farm"];
    [mailController setMessageBody:@"" isHTML:NO];
    [mailController setModalPresentationStyle:UIModalPresentationFormSheet];
    
    [self.parentViewController presentViewController:mailController animated:YES completion:nil];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [self.parentViewController dismissViewControllerAnimated:YES completion:NULL];
}
@end
