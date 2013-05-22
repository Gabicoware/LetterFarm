//
//  GKOpponentController.m
//  LetterFarm
//
//  Created by Daniel Mueller on 7/13/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "GKOpponentController.h"
#import "GKMatchEngine.h"
#import "Analytics.h"
#import "GKSourceData.h"
#import "Reachability+LF.h"

@interface GKOpponentController()

@property (nonatomic) UIViewController* parentViewController;
@property (nonatomic) NSArray* players;

-(void)handleGKDidAuthenticateNotification:(id)notification;

@end

@implementation GKOpponentController

@synthesize parentViewController=_parentViewController;
@synthesize matchInfo=_matchInfo;
@synthesize startingDifficulty=_startingDifficulty;

-(id<MatchEngine>)matchEngine{
    return [GKMatchEngine sharedGKMatchEngine];
}

-(void)selectOpponentWithViewController:(UIViewController*)controller{
    
    [self selectOpponentWithViewController:controller players:nil];
    
}
-(void)selectOpponentWithViewController:(UIViewController*)controller players:(NSArray*)players{
    self.parentViewController = controller;
    self.players = players;
    
#ifdef USE_FAKE_APPLE_ID
#ifdef ADHOC
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Apple ID Warning" message:@"Game Center is in Sandbox mode. Do not use your real Apple ID to set up a game center account in sandbox mode. Please contact Dan at danielmueller@gabicoware.com if you would like him to set up an account for you, or create a testing account of your own." delegate:self cancelButtonTitle:@"Back" otherButtonTitles:@"Continue", nil];
    [alertView show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ( 0 < buttonIndex) {
        [self didAcknowledgeWarning];
    }
}
 
-(void)didAcknowledgeWarning{
#endif
#endif
    
    if (![[Reachability sharedReachability] isReachable]){
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Unable To Connect" message:@"The internet is currently unavailable." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }else if ([[GKMatchEngine sharedGKMatchEngine] isAvailable]){
        
        if ([[GKMatchEngine sharedGKMatchEngine] isAuthenticated]) {
            [self presentMatchmaker];
        }else{
            [self trackEvent:@"Authenticating"];
            [[NSNotificationCenter defaultCenter] addObserver:self 
                                                     selector:@selector(handleGKDidAuthenticateNotification:) 
                                                         name:GKLocalPlayerDidAuthenticateNotification 
                                                       object:[GKMatchEngine sharedGKMatchEngine]];
            
            [[GKMatchEngine sharedGKMatchEngine] authenticate];
        }
        
    }else {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Game Center Unavailable" message:@"Game center is unavailable" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }

}

-(void)handleGKDidAuthenticateNotification:(id)notification{
    [self trackEvent:@"Did Authenticate"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self presentMatchmaker];
}

-(void)presentMatchmaker{
    
    int dismissCount = 0;
    while (self.parentViewController.modalViewController != nil) {
        [self.parentViewController dismissViewControllerAnimated:NO completion:NULL];
        dismissCount++;
        if (5 < dismissCount) {
            break;
        }
    }
    
    [self trackEvent:@"Presenting Matchmaker"];
    
    GKMatchRequest* request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 2;
    if (self.players != nil) {
        request.playersToInvite = self.players;
    }
    request.playerGroup = self.startingDifficulty;
    
    GKTurnBasedMatchmakerViewController * controller = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
    controller.showExistingMatches = NO;
    controller.turnBasedMatchmakerDelegate = self;
    
    [self.parentViewController presentModalViewController:controller animated:YES];
    
}

// The user has cancelled
- (void)turnBasedMatchmakerViewControllerWasCancelled:(GKTurnBasedMatchmakerViewController *)viewController{
    [self trackEvent:@"Did Cancel Mathcmaker"];
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

// Matchmaking has failed with an error
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFailWithError:(NSError *)error{
    [self trackEvent:@"Did Fail With Error"];
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

// A turned-based match has been found, the game should start
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFindMatch:(GKTurnBasedMatch *)match{
    
    NSLog(@"participants %@", match.participants);
    
    [self trackEvent:@"Did Find Match"];
    
    
    GKSourceData* sourceData = [[GKSourceData alloc] init];
    sourceData.match = match;
    sourceData.startingDifficulty = self.startingDifficulty;
    
    [[GKMatchEngine sharedGKMatchEngine] loadMatchInfoWithSourceData:sourceData completionHandler:^(MatchInfo* matchInfo){
        self.matchInfo = matchInfo;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:OpponentSelectedNotification 
                                                                object:self];
            [self.parentViewController dismissModalViewControllerAnimated:YES];
        });
    } ];
}

// Called when a users chooses to quit a match and that player has the current turn.  The developer should call playerQuitInTurnWithOutcome:nextPlayer:matchData:completionHandler: on the match passing in appropriate values.  They can also update matchOutcome for other players as appropriate.
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController playerQuitForMatch:(GKTurnBasedMatch *)match{
    
    [[Analytics sharedAnalytics] trackEvent:@"GK Opponent - Quit Match"];
    
    [[GKMatchEngine sharedGKMatchEngine] loadMatchInfoWithSourceData:match completionHandler:^(MatchInfo *matchInfo) {
        [[GKMatchEngine sharedGKMatchEngine] quitMatch:matchInfo];
    }];
}

-(void)trackEvent:(NSString *)name{
    [[Analytics sharedAnalytics] trackCategory:@"GK Opponent" action:name label:@"" value:0];
}
@end
