//
//  EmailOpponentController.m
//  LetterFarm
//
//  Created by Daniel Mueller on 12/23/12.
//
//

#import "EmailOpponentController.h"
#import "EmailMatchEngine.h"
#import "EmailMatch.h"
#import <AddressBook/AddressBook.h>
#import "UIBlockAlertView.h"

@interface EmailOpponentController()

@property (nonatomic) id viewController;

@end

@implementation EmailOpponentController

@synthesize playerGroup=_playerGroup;
@synthesize matchInfo=_matchInfo;

-(id<MatchEngine>)matchEngine{
    return [EmailMatchEngine sharedEmailMatchEngine];
}

-(void)selectOpponentWithViewController:(UIViewController*)controller{
    
    if ([[EmailMatchEngine sharedEmailMatchEngine] playerID] == nil) {
        self.viewController = controller;
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter YOUR email address:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView show];
    }else{
        
        ABPeoplePickerNavigationController* pickerController = [[ABPeoplePickerNavigationController alloc] initWithNibName:nil bundle:nil];
        
        pickerController.modalPresentationStyle = UIModalPresentationFormSheet;
        pickerController.peoplePickerDelegate = self;
        
        [controller presentViewController:pickerController animated:YES completion:NULL];
        
        [pickerController.viewControllers.lastObject setTitle:@"Select Opponent"];
    }
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex != 0) {
        NSString* playerID = [[alertView textFieldAtIndex:0] text];
        
        [[EmailMatchEngine sharedEmailMatchEngine] setPlayerID:playerID];
        
        [self selectOpponentWithViewController:self.viewController];
        self.viewController = nil;
    }
    
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    
    [peoplePicker.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person{
    [peoplePicker setDisplayedProperties:[NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonEmailProperty]]];
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    
    NSString* email = nil;
    
    // Only inspect the value if it's an email
    if (property == kABPersonEmailProperty) {
        /*
         * Set up an ABMultiValue to hold the address values; copy from address
         * book record.
         */
        ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
        
        CFIndex index = ABMultiValueGetIndexForIdentifier(emails, identifier);
        
        id value = (id)CFBridgingRelease(ABMultiValueCopyValueAtIndex(emails, index));
        
        email = OBJECT_IF_OF_CLASS(value, NSString);
        
        CFRelease(emails);
        
    }
    
    if (email != nil) {
        [peoplePicker.presentingViewController dismissViewControllerAnimated:YES completion:^{
            [self startMatchWithEmail:email];
        }];
    }
    return NO;
}

-(void)startMatchWithEmail:(NSString*)email{
    
    EmailMatch* match = [[EmailMatch alloc] init];
    match.matchStatus = MatchStatusYourTurn;
    match.games = [NSArray array];
    match.targetEmail = email;
    match.sourceEmail = [[EmailMatchEngine sharedEmailMatchEngine] playerID];
    self.matchInfo = nil;
    
    [[self matchEngine] loadMatchInfoWithSourceData:match completionHandler:^(MatchInfo *matchInfo) {
        
        self.matchInfo = matchInfo;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:OpponentSelectedNotification object:self];
        
    } ];
    
}

@end
