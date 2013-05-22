//
//  MultiplayerGameController.m
//  LetterFarm
//
//  Created by Daniel Mueller on 11/29/12.
//
//

#import "MultiplayerGameController.h"

#ifndef DISABLE_GK
#import "GKMatchEngine.h"
#import "GKOpponentController.h"
#endif
#ifndef DISABLE_LOCAL
#import "ComputerMatchEngine.h"
#import "ComputerOpponentController.h"
#import "PassNPlayMatchEngine.h"
#import "PassNPlayOpponentController.h"
#endif
#ifndef DISABLE_FB
#import "FBMatchEngine.h"
#import "FBOpponentController.h"
#endif
#ifndef DISABLE_EMAIL
#import "EmailMatchEngine.h"
#import "EmailOpponentController.h"
#endif

#import <QuartzCore/QuartzCore.h>

#import "Reachability+LF.h"
#import "PuzzleGeneratorFactory.h"
#import "PuzzleGame.h"
#import "ComputerMatchEngine.h"
#import "Analytics.h"
#import "NibNames.h"

#import "MainViewController.h"
#import "SelectMatchViewController.h"
#import "PuPauseViewController.h"
#import "PuGameViewController.h"
#import "MatchViewController.h"
#import "PassNPlayMatchViewController.h"
#import "LFAlertView.h"

#import "LocalConfiguration.h"
#import "MatchListMediator.h"
#import "MatchInfo+Puzzle.h"
#import "MatchInfo+Strings.h"
#import "NSObject+Notifications.h"
#import "Puzzle.h"

NSString* OpponentSelectedNotification = @"OpponentSelectedNotification";
NSString* MatchEngineSelectMatchNotification = @"MatchEngineSelectMatchNotification";
NSString* MatchesDidLoadNotification = @"MatchesDidLoadNotification";
NSString* MatchDidUpdateNotification = @"MatchDidUpdateNotification";
NSString* MatchDidUpdateMatchKey = @"MatchDidUpdateMatchKey";

@interface MultiplayerGameController ()

@property (nonatomic) id generator;

@property (nonatomic, assign) int startingDifficulty;

@property (nonatomic, assign) OpponentType opponentType;

@property (nonatomic) id<OpponentController> opponentController;

-(void)startWithMatchInfo:(MatchInfo*)matchInfo;

@property (nonatomic, readonly) id<MatchEngine> matchEngine;

@property (nonatomic) MatchInfo* matchInfo;

@end

@implementation MultiplayerGameController

@synthesize matchInfo=_matchInfo;
@synthesize opponentType=_opponentType;
@synthesize opponentController=_opponentController;

-(PuGameViewController*)puGameViewController{
    return OBJECT_IF_OF_CLASS(self.gameViewController, PuGameViewController);
}

-(SelectMatchViewController*)selectMatchViewController{
    SelectMatchViewController* result = nil;
    for (UIViewController* controller in self.navigationController.viewControllers) {
        SelectMatchViewController* selectMatchViewController = OBJECT_IF_OF_CLASS(controller, SelectMatchViewController);
        if (selectMatchViewController == nil) {
            result = selectMatchViewController;
        }
    }
    return result;
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(id)init{
    if((self = [super init])){
        
        NSDictionary* noteDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"handleSelectMatchNewGameNotification:",SelectMatchNewGame,
                                  @"handleWillCompletePuzzleGameNotification:",WillCompletePuzzleGameNotification,
                                  @"handleDidCompletePuzzleGameNotification:",DidCompletePuzzleGameNotification,
                                  @"handleOpponentSelectedNotification:",OpponentSelectedNotification,
                                  @"handleSelectMatchMutliplayerNotification:",SelectMatchMutliplayer,
                                  @"handleSelectMatchCompleteMutliplayer:",SelectMatchCompleteMutliplayer,
                                  @"handleShowMatchesMutliplayer:",ShowMatchesMutliplayer,
                                  @"handlePassNotification:",PassNotification,
                                  @"handleResendEmail:",ResendEmail,
                                  @"handleMatchDidUpdateNotification:",MatchDidUpdateNotification,
                                  @"handleReachabilityChangedNotification:",kReachabilityChangedNotification,
                                  nil];
        
        [self observeNotifications:noteDict];
        
    }
    return self;
}

-(NSString*)playerID{
    NSString* result = @"localplayer";
    
    if (self.matchEngine != nil) {
        result = self.matchEngine.playerID;
    }
    
    return result;
    
}

-(id<MatchEngine>)matchEngine{
    id<MatchEngine> result = nil;
    
    switch (self.matchInfo.opponentType) {
#ifndef DISABLE_GK
        case OpponentTypeGK:
            result = [GKMatchEngine sharedGKMatchEngine];
            break;
#endif
#ifndef DISABLE_LOCAL
        case OpponentTypeComputer:
            result = [ComputerMatchEngine sharedComputerMatchEngine];
            break;
        case OpponentTypePassNPlay:
            result = [PassNPlayMatchEngine sharedPassNPlayMatchEngine];
            break;
#endif
#ifndef DISABLE_FB
        case OpponentTypeFB:
            result = [FBMatchEngine sharedFBMatchEngine];
            break;
#endif
#ifndef DISABLE_EMAIL
        case OpponentTypeEmail:
            result = [EmailMatchEngine sharedEmailMatchEngine];
            break;
#endif
        default:
            break;
    }
    
    return result;
}

-(void)start{
    
    [self trackEvent:@"Select Opponent"];
    
    SelectMatchViewController* selectionController = [[SelectMatchViewController alloc] initWithNibName:[NibNames tableView] bundle:nil];
    [[selectionController navigationItem] setHidesBackButton:NO animated:NO];
    
    MatchListMediator* mediator = [MatchListMediator sharedMatchListMediator];
    
    mediator.component = selectionController;
    
    [[self navigationController] pushViewController:selectionController animated:YES];
    
}

-(void)showMatchInfo:(MatchInfo*)matchInfo{
    if (matchInfo != nil) {
        self.matchInfo = matchInfo;
        [self presentMatchView:matchInfo];
    }
}

-(void)handleSelectMatchNewGameNotification:(id)notification{
    
    SelectMatchViewController* selectMatchViewController = OBJECT_IF_OF_CLASS([notification object], SelectMatchViewController);
    
    self.opponentType = selectMatchViewController.opponentType;
    
    self.startingDifficulty = [SelectMatchViewController defaultStartingDifficulty];

    Class selectorClass = Nil;
    
    switch (self.opponentType) {
        case OpponentTypeNone:
            break;
#ifndef DISABLE_LOCAL
        case OpponentTypeComputer:
            selectorClass = [ComputerOpponentController class];
            break;
        case OpponentTypePassNPlay:
            selectorClass = [PassNPlayOpponentController class];
            break;
#endif
#ifndef DISABLE_GK
        case OpponentTypeGK:
            //
            if (![[Reachability sharedReachability] isReachable]) {
                [self showRequiresReachability];
                return;
            }
            selectorClass = [GKOpponentController class];
            break;
#endif
#ifndef DISABLE_FB
        case OpponentTypeFB:
            selectorClass = [FBOpponentController class];
            break;
#endif
#ifndef DISABLE_EMAIL
        case OpponentTypeEmail:
            selectorClass = [EmailOpponentController class];
            break;
#endif
    }
    
    if (selectorClass != Nil) {
        id<OpponentController> controller = [[selectorClass alloc] init];
        self.opponentController = controller;
        
        self.opponentController.startingDifficulty = [self startingDifficulty];
        
        [self.opponentController selectOpponentWithViewController:self.navigationController];
    }
}

-(void)handleReachabilityChangedNotification:(id)notification{
    
    BOOL isGameBeingPlayed = [self.navigationController.topViewController isKindOfClass:[PuGameViewController class]] || self.mainViewController.isGameViewActive;
    
    BOOL isNotConnected = ![[Reachability sharedReachability] isReachable];
    
    if (isNotConnected && isGameBeingPlayed && self.matchEngine.doesNeedReachability) {
        
        [self showRequiresReachability];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self.mainViewController dismissGameViewController];
            [self.mainViewController showMenu];
        }else{
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

-(void)showRequiresReachability{
    
    [[[UIAlertView alloc] initWithTitle:@"Unable to Connect"
                                message:@"Game Center matches can not be played when the internet is unavailable. Please try again when you have reconnected."
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles: nil] show];
    
}

-(void)handlePassNotification:(NSNotification*)notification{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[self gameViewController] dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
    PuzzleGame* game = OBJECT_IF_OF_CLASS([self puGameViewController].puzzleGame, PuzzleGame);
    [game setCompletionDate:[NSDate date]];
    
    if(self.matchInfo.opponentType == OpponentTypePassNPlay){
        [[PassNPlayMatchEngine sharedPassNPlayMatchEngine] updateGame:game forMatch:self.matchInfo];
    }else{
        [game setPlayerID:[self playerID]];
    }
    
    self.matchInfo.currentGame = nil;
    
    self.matchInfo.games = [self.matchInfo.games arrayByAddingObject:[self puGameViewController].puzzleGame];
    
    
    BOOL shouldPresentCompleteAlert = NO;
    
    BOOL disableView = NO;
    if( [self.matchInfo canFinishPuzzleMatch] ){
        [self.matchInfo finishPuzzleMatch];
        disableView = [self.matchEngine completeMatch:self.matchInfo];
        shouldPresentCompleteAlert = YES;
    }else {
        disableView = [self.matchEngine endTurnInMatch:self.matchInfo];
    }
    
    [self trackEvent:@"Completed Game"];
    
    void (^completeBlock)(void) = ^{
        [self presentMatchView:self.matchInfo];
        //present complete alert if appropriate
        if (shouldPresentCompleteAlert) {
            [self presentMatchCompleteAlert:self.matchInfo];
        }
    };
    
    if(disableView && [[self matchEngine] respondsToSelector:@selector(setCompletionBlock:)]){
        [[self matchEngine] setCompletionBlock:completeBlock];
    }else{
        completeBlock();
    }
    

}

-(void)handleMatchDidUpdateNotification:(NSNotification*)notification{
    MatchInfo* match = OBJECT_IF_OF_CLASS([[notification userInfo] objectForKey:MatchDidUpdateMatchKey], MatchInfo);
    
    //show alert if 
    
    for (UIViewController* controller in self.navigationController.viewControllers) {
        MatchViewController* matchViewController = OBJECT_IF_OF_CLASS(controller, MatchViewController);
        if(matchViewController != nil && [matchViewController.matchInfo.matchID isEqualToString:match.matchID]){
            [matchViewController refreshDisplay];
        }
    }
    
    NSString* message = [NSString stringWithFormat:@"Your multiplayer match with %@ has been updated!",match.opponentName];
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Match Updated"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

-(void)presentMatchCompleteAlert:(MatchInfo*)match{
    NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"MatchCompleteAlertView" owner:self options:nil];
    
    LFAlertView* alertView = OBJECT_IF_OF_CLASS(objects[0], LFAlertView);
    
    UILabel* completeLabel = OBJECT_IF_OF_CLASS([alertView viewWithTag:2001], UILabel);
    
    NSString* completeText = [self.matchInfo outcomeString];
    
    [completeLabel setText:completeText];
    
    alertView.isModal = YES;
    
    alertView.layer.cornerRadius = 10;
    
    [alertView show];

}

-(IBAction)didTapMatchCompleteAlertOkButton:(id)sender{
    UIView* view = sender;
    LFAlertView* alertView = OBJECT_IF_OF_CLASS(view.superview, LFAlertView);
    
    [alertView remove];
}

#ifndef DISABLE_GK
-(void)showGKOpponentControllerWithPlayers:(NSArray*)players{
    self.opponentType = OpponentTypeGK;
    
    float value = [SelectMatchViewController defaultStartingDifficulty];
    
    self.startingDifficulty = value;
    
    GKOpponentController* controller = [[GKOpponentController alloc] init];
    self.opponentController = controller;
    
    self.opponentController.startingDifficulty = [self startingDifficulty];
    
    [controller selectOpponentWithViewController:self.navigationController players:players];

}
#endif



-(void)handleOpponentSelectedNotification:(NSNotification*)notification{
    id<OpponentController> opponentController = OBJECT_IF_OF_PROTOCOL([notification object], OpponentController);
    
    if (opponentController.matchInfo.opponentType == OpponentTypePassNPlay) {
        [self showMatchInfo:opponentController.matchInfo];
    }else{
        [self startWithMatchInfo:opponentController.matchInfo];
    }
    
}

-(void)startWithMatchInfo:(MatchInfo*)matchInfo{
    
    self.matchInfo = matchInfo;
    
    BOOL hasValidMatch = self.matchInfo != nil && [self.matchEngine canPlayWithMatchInfo:self.matchInfo];
    
    if ( hasValidMatch ) {
        
        BOOL isFirst = self.matchInfo.opponentType != OpponentTypeNone && self.matchInfo.games.count%2 == 0;
        
        if( isFirst ){
            
            PuzzleGame* currentGame = OBJECT_IF_OF_CLASS( matchInfo.currentGame, PuzzleGame);
            
            //generates a new game if the argument is nil
            [self presentGameViewWithGame:currentGame];
            
        }else{
            
            PuzzleGame* theirPuzzleGame = [self.matchInfo.games lastObject];
            
            PuzzleGame* yourPuzzleGame = [theirPuzzleGame copy];
            
            [yourPuzzleGame setCreationDate:[NSDate date]];
            [yourPuzzleGame setCompletionDate:[NSDate date]];
            
            [yourPuzzleGame setGuessedWords:[NSArray arrayWithObject:theirPuzzleGame.startWord]];
            [self presentGameViewWithGame:yourPuzzleGame];
            
        }
        
    }
    
}

-(void)presentGameViewWithGame:(PuzzleGame*)puzzleGame{
    
    [self trackEvent:@"Creating Game View"];
    
    PuGameViewController* puzzleController = nil;
    
    if ([self puGameViewController] != nil) {
        puzzleController = [self puGameViewController];
    }else{
        puzzleController = [[PuGameViewController alloc] initWithNibName:[NibNames puzzleGameView] bundle:nil];
    }
    
    [self presentGameViewController:puzzleController];
    
    if (puzzleGame == nil) {
        
        [self generateGameForController:puzzleController];
    }else{
        [puzzleController setIsCreating:NO];
        [puzzleController startGame:puzzleGame];
    }
    
    
}



-(void)presentPauseViewController:(UIViewController<PauseViewController> *)pauseViewController{
    
    [pauseViewController setMatchInfo:self.matchInfo];
    [super presentPauseViewController:pauseViewController];
}

-(void)handleWillCompletePuzzleGameNotification:(id)notification{
    
    self.matchInfo.currentGame = nil;
    
    [[LocalConfiguration sharedLocalConfiguration] incrementGameCount];
    
    PuzzleGame* game = OBJECT_IF_OF_CLASS([self puGameViewController].puzzleGame, PuzzleGame);
    [game setCompletionDate:[NSDate date]];
    
    if(self.matchInfo.opponentType == OpponentTypePassNPlay){
        [[PassNPlayMatchEngine sharedPassNPlayMatchEngine] updateGame:game forMatch:self.matchInfo];
    }else{
        [game setPlayerID:[self playerID]];
    }
    
    self.matchInfo.games = [self.matchInfo.games arrayByAddingObject:[self puGameViewController].puzzleGame];
    
    
    BOOL shouldPlayAnotherRound = self.matchInfo.games.count%2 == 0;
    
    if( [self.matchInfo canFinishPuzzleMatch] ){
        [self.matchInfo finishPuzzleMatch];
    }
    
    NSString* message = @"";
    
    if(self.matchInfo.status == MatchStatusTheirTurn && self.matchInfo.opponentType == OpponentTypePassNPlay){
        if( shouldPlayAnotherRound){
            message = @"1 of 2 puzzles complete.";
        }else{
            message = @"Tap to complete your turn.";
        }
    }else if(self.matchInfo.status == MatchStatusYourTurn){
        if( shouldPlayAnotherRound){
            message = @"1 of 2 puzzles complete.";
        }else if(self.matchInfo.opponentType != OpponentTypeComputer){
            message = @"Tap to complete your turn.";
        }
    }else if(self.matchInfo.status == MatchStatusTheyWon ){
        message = @"Tap to complete your turn.";
    }else if(self.matchInfo.status == MatchStatusYouWon ){
        message = @"Tap to complete your turn.";
    }

    [[self puGameViewController] setGameCompleteMessage:message];
    
}

-(void)handleDidCompletePuzzleGameNotification:(id)notification{
        
    BOOL shouldPlayAnotherRound = self.matchInfo.games.count%2 == 0;
    
    BOOL disableView = NO;
    
    BOOL shouldPresentCompleteAlert = NO;
    
    if( [self.matchInfo canFinishPuzzleMatch] ){
        disableView = [self.matchEngine completeMatch:self.matchInfo];
    }else if(!shouldPlayAnotherRound){
        disableView = [self.matchEngine endTurnInMatch:self.matchInfo];
    }
    
    if (MatchStatusIsComplete(self.matchInfo.status)) {
        shouldPresentCompleteAlert = YES;
    }
    
    
    [self trackEvent:@"Completed Game"];
    
    void (^completeBlock)(void) = ^{
        [self presentMatchView:self.matchInfo];
        //present complete alert if appropriate
        if (shouldPresentCompleteAlert) {
            double delayInSeconds = 0.3;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self presentMatchCompleteAlert:self.matchInfo];
            });
        }
    };
    
    if(disableView && [[self matchEngine] respondsToSelector:@selector(setCompletionBlock:)]){
        [[self matchEngine] setCompletionBlock:completeBlock];
    }else{
        completeBlock();
    }
    
    
}

-(void)presentMatchView:(MatchInfo*)matchInfo{
    
    [self trackEvent:@"Match View"];
    
    MatchViewController* matchViewController = [self newMatchViewControllerWithMatchInfo:matchInfo];
    
    [[matchViewController navigationItem] setHidesBackButton:YES animated:NO];
    
    [[self navigationController] pushViewController:matchViewController animated:YES];
        
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.matchInfo.opponentType == OpponentTypePassNPlay) {
            [self.mainViewController dismissGameViewController];
            [self.mainViewController showMenu];
        }else{
            self.mainViewController.shouldShowGameView = NO;
            [[self mainViewController] hideGameViewController];
        }
    }
}

-(id)newMatchViewControllerWithMatchInfo:(MatchInfo*)matchInfo{
    MatchViewController* matchViewController = nil;
    if (matchInfo.opponentType == OpponentTypePassNPlay) {
        matchViewController = [[PassNPlayMatchViewController alloc] initWithNibName:[NibNames matchView] bundle:nil];
    }else{
        matchViewController = [[MatchViewController alloc] initWithNibName:[NibNames matchView] bundle:nil];
    }
    matchViewController.matchInfo = matchInfo;
    return matchViewController;
}

-(void)generateGameForController:(PuGameViewController*)controller{
    if (controller != nil) {
        [controller setIsCreating:YES];
        
        PuzzleGenerator* generator = nil;
        
        DictionaryType type = 5 - (self.matchInfo.games.count/2)%3;
        
        //actually we should always go 5,4,3 for multiplayer games
        
        int count = 0;
        
        PuzzleGame* firstGame = nil;
        
        for (int index = 0; index + 1 < self.matchInfo.games.count; index+=2) {
            
            PuzzleGame* game1 = [self.matchInfo.games objectAtIndex:index];
            PuzzleGame* game2 = [self.matchInfo.games objectAtIndex:index + 1];
            
            if (index == 0) {
                firstGame = game1;
            }
            
            if (game1.solutionWords.count != 0 || game2.solutionWords.count != 0) {
                count += 2;
            }
        }
        
        Difficulty startingDifficulty = DifficultyStarting;
        
        if (0 < self.startingDifficulty) {
            startingDifficulty = self.startingDifficulty;
        }else if(firstGame != nil){
            startingDifficulty = firstGame.solutionWords.count - 1;
        }
        
        Difficulty difficulty = startingDifficulty + count/6;
        
        generator = [PuzzleGeneratorFactory newGameGeneratorForType:type withDifficulty:difficulty];
        
        generator.target = self;
        generator.action = @selector(didGenerateGame:);
        [generator generateInBackground];
        self.generator = generator;
    }

}

-(void)didGenerateGame:(PuzzleGame*)game{
    self.generator = nil;
    
    if ([game endWord] == nil || [game startWord] == nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MenuNotification object:nil];
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Problems!" message:@"We had trouble getting a game for you. It's our fault. Please try again. If you continue having trouble, please contact support@gabicoware.com" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
        
        [[Analytics sharedAnalytics] trackCategory:@"Game Generation" action:@"Failed" label:nil value:0];
        
    }else{
        
        [self trackEvent:@"Created Game"];
        
        [[self puGameViewController] setIsCreating:NO];
        
        [[Analytics sharedAnalytics] trackCategory:@"Game Generation" action:@"Start Word" label:game.startWord value:0];
        [[Analytics sharedAnalytics] trackCategory:@"Game Generation" action:@"End Word" label:game.endWord value:0];
        
        [[self puGameViewController] startGame:game];
        
        self.matchInfo.currentGame = game;
        
        [[self matchEngine] saveMatch:self.matchInfo];
        
    }
    
    
}

-(void)handleResendEmail:(id)notification{
#ifndef DISABLE_EMAIL
    MatchInfo* matchInfo = OBJECT_IF_OF_CLASS([notification userInfo], MatchInfo);
    if (matchInfo != nil && matchInfo.opponentType == OpponentTypeEmail) {
        [[EmailMatchEngine sharedEmailMatchEngine] sendEmailForMatch:matchInfo];
    }
#endif
}

-(void)didExitGame{
    if (self.matchInfo != nil && 0 == [self.matchInfo.games count]) {
        [self.matchEngine deleteMatch:self.matchInfo];
    }
}


-(void)handleShowMatchesMutliplayer:(id)notification{
    NSNotification* note = OBJECT_IF_OF_CLASS(notification, NSNotification);
    SelectMatchViewController* selectMatchViewController = OBJECT_IF_OF_CLASS([note object], SelectMatchViewController);
    
    MatchesViewController* matchesViewController = [[MatchesViewController alloc] initWithNibName:[NibNames tableView] bundle:nil];
    
    matchesViewController.matches = [selectMatchViewController allEndedMatches];
    
    matchesViewController.mediator = selectMatchViewController.mediator;
    
    [[self navigationController] pushViewController:matchesViewController animated:YES];
    
}


-(void)handleSelectMatchCompleteMutliplayer:(id)notification{
    NSNotification* note = OBJECT_IF_OF_CLASS(notification, NSNotification);
    MatchInfo* matchInfo = OBJECT_IF_OF_CLASS([note userInfo], MatchInfo);
    
    MatchViewController* matchViewController = [self newMatchViewControllerWithMatchInfo:matchInfo];
    
    [matchViewController setMatchInfo:matchInfo];
    
    [[self navigationController] pushViewController:matchViewController animated:YES];
        
}

-(void)handleSelectMatchMutliplayerNotification:(id)notification{
    
    NSNotification* note = OBJECT_IF_OF_CLASS(notification, NSNotification);
    MatchInfo* matchInfo = OBJECT_IF_OF_CLASS([note userInfo], MatchInfo);
    
    
    self.matchInfo = matchInfo;
    
    if ([self.matchEngine doesNeedReachability] && ![[Reachability sharedReachability] isReachable]) {
        [self showRequiresReachability];
        return;
    }
    
    
    if (matchInfo.opponentType == OpponentTypePassNPlay) {
        
        BOOL canStart = [[note object] isKindOfClass:[MatchViewController class]] && (matchInfo.status == MatchStatusYourTurn || matchInfo.status == MatchStatusTheirTurn);
        
        if (canStart) {
            [self startWithMatchInfo:matchInfo];
        }else{
            [self presentMatchView:matchInfo];
        }
    }else{
        if (matchInfo.status == MatchStatusYourTurn) {
            [self startWithMatchInfo:matchInfo];
        }else{
            [self presentMatchView:matchInfo];
        }
    }
    
}

-(UIViewController<PauseViewController>*)newPauseViewController{
    PuPauseViewController* puPauseViewController = [[PuPauseViewController alloc] initWithNibName:nil bundle:nil];
    [puPauseViewController setDisableHints:YES];
    
    if (self.matchInfo.opponentType != OpponentTypeComputer) {
        [puPauseViewController setCanPass:YES];
    }
    [puPauseViewController setDisableHints:YES];
    
    return puPauseViewController;
}

-(NSString*)categoryName{
    return @"Multiplayer";
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [super navigationController:navigationController didShowViewController:viewController animated:animated];
    
    BOOL isMatchView = [viewController isKindOfClass:[MatchViewController class]];
    
    if ( isMatchView ) {
        NSArray* controllers =[navigationController viewControllers];
        NSMutableArray* allowedControllers = [NSMutableArray arrayWithObject:[navigationController.viewControllers objectAtIndex:0]];
        for (UIViewController* controller in controllers) {
            if ([controller isKindOfClass:[SelectMatchViewController class]]) {
                [allowedControllers addObject:controller];
            }
        }
        [allowedControllers addObject:viewController];
        NSArray* updatedControllers = [NSArray arrayWithArray:allowedControllers];
        if (![navigationController.viewControllers isEqualToArray:updatedControllers]) {
            navigationController.viewControllers = updatedControllers;
        }
        if ([[viewController navigationItem] hidesBackButton]) {
            [[viewController navigationItem] setHidesBackButton:NO animated:YES];
        }
    }
}

@end