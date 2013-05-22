//
//  FBOpponentController.m
//  LetterFarm
//
//  Created by Daniel Mueller on 12/12/12.
//
//

#import "FBOpponentController.h"
#import "FBFriendsViewController.h"
#import "FBMatchEngine.h"
#import "Analytics.h"
#import "Facebook.h"

// Generally we need to notify users that the game has started

// 0. Opponent is selected with super custom UI
// 0.0 Users are divided into "app_users" and "non_app_users"
// 0.1 You can not select a user we know you are already playing a game with
// 1. Player plays first game
// 2. Send the invitation
// 3. Create "Player Started Playing Match" action
// 4. Create "Player Played Game"
// 5. Opponent receives notification and opens app OR just opens App
// 6. Delete notification
// 7. Friends actions in game read
// 8. Find "Start" actions by friends
// 9. Resolve matches from "Start Playing" actions that relates to the player by loading games and Completed Matches

@interface FBOpponentController ()

@property (nonatomic) FBFriendsViewController* friendsViewController;

@end

@implementation FBOpponentController

@synthesize matchInfo=_matchInfo;

@synthesize playerGroup=_playerGroup;

-(id<MatchEngine>)matchEngine{
    return [FBMatchEngine sharedFBMatchEngine];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)selectOpponentWithViewController:(UIViewController*)controller{
    //do nothing
    
    if ([[FBMatchEngine sharedFBMatchEngine] isFBAvailable]){
        
        if (self.friendsViewController == nil) {
            
            //Show the UI immediately
            FBFriendsViewController* viewController = [[FBFriendsViewController alloc] initWithNibName:@"FBFriendsViewController" bundle:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(handleFBFriendsViewDidSelectNotification:)
                                                         name:FBFriendsViewDidSelectNotification
                                                       object:viewController];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(handleFBFriendsViewDidCancelNotification:)
                                                         name:FBFriendsViewDidCancelNotification
                                                       object:viewController];
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                [viewController setModalPresentationStyle:UIModalPresentationFormSheet];
            }
            self.friendsViewController = viewController;
        }
        
        if ([self.friendsViewController parentViewController] == nil) {
            [controller presentViewController:self.friendsViewController animated:YES completion:NULL];
        }
        
        if ([[FBMatchEngine sharedFBMatchEngine] isAuthenticated]) {
            [self loadFriends];
        }else{
            [self trackEvent:@"Authenticating"];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(handleFBDidAuthenticateNotification:)
                                                         name:FBLocalPlayerDidAuthenticateNotification
                                                       object:[FBMatchEngine sharedFBMatchEngine]];
            
            [[FBMatchEngine sharedFBMatchEngine] authenticate];
        }
        
    }else {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Facebook Unavailable" message:@"Facebook is unavailable" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

-(void)handleFBDidAuthenticateNotification:(id)notification{
    [[Analytics sharedAnalytics] trackEvent:@"Did Authenticate"];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FBLocalPlayerDidAuthenticateNotification
                                                  object:[FBMatchEngine sharedFBMatchEngine]];
    [self loadFriends];
}

-(void)loadFriends{
    
    if ([[FBMatchEngine sharedFBMatchEngine] friends] == nil) {
        [[FBMatchEngine sharedFBMatchEngine] loadFriends];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleFBFriendsDidLoadNotification:)
                                                     name:FBFriendsDidLoadNotification
                                                   object:[FBMatchEngine sharedFBMatchEngine]];
        
    }else{
        [self setFriends];
    }
    
}

-(void)handleFBFriendsDidLoadNotification:(id)notification{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FBFriendsDidLoadNotification
                                                  object:[FBMatchEngine sharedFBMatchEngine]];
    [self setFriends];
}

-(void)setFriends{
    self.friendsViewController.friends = [[FBMatchEngine sharedFBMatchEngine] friends];
}

-(void)handleFBFriendsViewDidCancelNotification:(id)notification{
    [self.friendsViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

-(void)handleFBFriendsViewDidSelectNotification:(id)notification{
    
    [self.friendsViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    id opponent = self.friendsViewController.selectedFriend;
    
    self.matchInfo = [[FBMatchEngine sharedFBMatchEngine] matchInfoWithOpponent:opponent];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:OpponentSelectedNotification object:self];
}

-(void)trackEvent:(NSString *)name{
    [[Analytics sharedAnalytics] trackCategory:@"FB Opponent" action:name label:@"" value:0];
}


@end
