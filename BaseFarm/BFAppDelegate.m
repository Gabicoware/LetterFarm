//
//  BFAppDelegate.m
//  Base Farm
//
//  Created by Daniel Mueller on 4/2/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "BFAppDelegate.h"

#import "BFMenuViewController.h"
#import "LFAboutViewController.h"
#import "LFStoreViewController.h"
#import "MainViewController.h"
#import "LocalConfiguration.h"
#import "PuCompleteViewController.h"
#import "LFMoreViewController.h"
#import "LFContactViewController.h"
#import "LFPreferencesViewController.h"
#import "UIViewController+SoundButton.h"
#import "SoundEffectManager.h"
#import "UIBlockAlertView.h"

#import "SinglePlayerGameController.h"
#import "MultiplayerGameController.h"
#import "LFURLCoder.h"
#import "MatchListMediator.h"
#import "MatchEngine.h"
#ifndef DISABLE_FB
#import "FBMatchEngine.h"
#endif
#ifndef DISABLE_GK
#import "GKMatchEngine.h"
#endif
#ifndef DISABLE_EMAIL
#import "EmailMatchEngine.h"
#endif

#import "WorldBackgroundView.h"

#import "Reachability+LF.h"
#import "NibNames.h"
#import "Analytics.h"
#import "InAppPurchases.h"

#import "NSObject+Notifications.h"


@interface BFAppDelegate()

@property (nonatomic) BFMenuViewController* menuController;

@property (nonatomic) GameController* gameController;

-(void)setupNotifications;

-(MainViewController*)mainViewController;

@end

@implementation BFAppDelegate

@synthesize gameController=_gameController;
@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize menuController=_menuController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[Analytics sharedAnalytics]  startup];
    [[Reachability sharedReachability] startNotifier];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor =[UIColor blackColor];
    
    BFMenuViewController* menuController = [[BFMenuViewController alloc] initWithNibName:[NibNames menuView] bundle:nil];
    
    self.menuController = menuController;
    self.menuController.viewName = @"Main Menu";
    [self.menuController view];
    
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:menuController];
    [menuController updateRightBarButton];
    self.navigationController = navigationController;
    [navigationController setToolbarHidden:YES];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        MainViewController* mainViewController = [[MainViewController alloc] initWithNibName:[NibNames mainView] bundle:nil];
        
        self.window.rootViewController = mainViewController;
        
        [self.window makeKeyAndVisible];
        mainViewController.navigationController = self.navigationController;
        
        [mainViewController showMenu];
        
    }else{
        
        UIViewController* mainViewController = [[UIViewController alloc] initWithNibName:[NibNames mainView] bundle:nil];
        
        self.window.rootViewController = mainViewController;
        
        [mainViewController addChildViewController:self.navigationController];
        
        self.navigationController.view.frame = mainViewController.view.bounds;
        
        [mainViewController.view addSubview:self.navigationController.view];
        
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        
        self.navigationController.view.backgroundColor = [UIColor clearColor];
        
        [self.window makeKeyAndVisible];
        
#ifndef FREEZE_START_SCREEN
        [self.navigationController setNavigationBarHidden:NO animated:YES];
#endif
    }
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:1.0/255.0 green:165.0/255.0 blue:203.0/255.0 alpha:1.0];
    
    [self setupNotifications];
    
    [[MatchListMediator sharedMatchListMediator] reloadMatches];
    
    [[InAppPurchases sharedInAppPurchases] retrieveProducts];
    
    [LocalConfiguration sharedLocalConfiguration];
    
    
#ifdef DEBUG
    
    
    
    NSURL* URL = [NSURL URLWithString:[[LocalConfiguration sharedLocalConfiguration] testURL]];
    
    if (URL != nil && [[LocalConfiguration sharedLocalConfiguration] hasTestCompleteView]) {
        
        /*
         PuzzleGame* game = [[PuzzleGame alloc] init];
         game.guessedWords = @[@"dat",@"mat",@"bat",@"fat",@"fan",@"fun",@"fan"];
         game.solutionWords = @[@"cat",@"bat",@"ban",@"can",@"wan",@"man",@"fan",@"fun",@"fin"];
         game.endWord = @"fin";
         */
        
        PuzzleGame* game = [LFURLCoder decodeURL:URL];
        if (game != nil) {
            PuCompleteViewController* completeController = [[PuCompleteViewController alloc] initWithNibName:[NibNames puzzleCompleteView] bundle:nil];
            
            completeController.puzzleGame = game;
            
            [self.navigationController pushViewController:completeController animated:YES];
        }
    }else if (URL != nil) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self application:application openURL:URL sourceApplication:nil annotation:nil];
        });
    }
    
    
#endif
        
    [[SoundEffectManager sharedSoundEffectManager] didStartup];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    BOOL result = NO;
    
#ifndef DISABLE_FB
    result = [[FBMatchEngine sharedFBMatchEngine] handleOpenURL:url];
#endif
    
#ifndef DISABLE_EMAIL
    if (!result) {
        result = [[EmailMatchEngine sharedEmailMatchEngine] handleOpenURL:url];
    }
#endif
    
    return result || [self openGameURL:url];
    
}

-(MainViewController*)mainViewController{
    return OBJECT_IF_OF_CLASS(self.window.rootViewController, MainViewController);
}

-(void)setupNotifications{
    
    NSDictionary* noteDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"handleNotification:",MenuSinglePlayer,
                              @"handleNotification:",MenuMultiPlayer,
                              @"handleNotification:",MenuMore,
                              @"handleNotification:",MoreAbout,
                              @"handleNotification:",MoreStore,
                              @"handleNotification:",MoreContact,
                              @"handleNotification:",MorePreferences,
                              @"handleNotification:",MenuNotification,
                              @"handleNotification:",MatchEngineSelectMatchNotification,
                              @"handleNotification:",MenuDidAppear,
                              @"handleNotification:",TileImageNameDidChange,
#ifndef DISABLE_GK
                              @"handleNotification:",GKHandleInviteNotification,
#endif
                              
                              nil];
    
    [self observeNotifications:noteDict];
    
}

-(void)handleNotification:(NSNotification*)notification{
    //we handle these in a big list, because having 10 different methods is a little overbearing
    if ([[notification name] isEqualToString:MenuSinglePlayer]) {
        
        self.mainViewController.isLogoViewHidden = YES;
        
        self.gameController = [self newPuzzleGameController];
        [[self gameController] start];
        
    }else if ([[notification name] isEqualToString:MatchEngineSelectMatchNotification]) {
        
        MatchInfo* matchInfo = OBJECT_IF_OF_CLASS(notification.object, MatchInfo);
        if (matchInfo) {
            self.gameController = [self newMultiplayerGameController];
            [(MultiplayerGameController*)self.gameController showMatchInfo:matchInfo];
        }
        
    }else if ([[notification name] isEqualToString:MenuMultiPlayer]) {
        
        self.mainViewController.isLogoViewHidden = YES;
        
        self.gameController = [self newMultiplayerGameController];
        [[self gameController] start];
        
    }else if ([[notification name] isEqualToString:MenuMore]) {
        self.mainViewController.isLogoViewHidden = YES;
        
        [self pushClass:[LFMoreViewController class] nibName:[NibNames tableView] title:@"More"];
    }else if ([[notification name] isEqualToString:MoreAbout]) {
        [self pushClass:[LFAboutViewController class] nibName:[NibNames aboutView] title:@"About"];
        
    }else if ([[notification name] isEqualToString:MoreContact]) {
        [self pushClass:[LFContactViewController class] nibName:[NibNames tableView] title:@"Feedback"];
    }else if ([[notification name] isEqualToString:MorePreferences]) {
        [self pushClass:[LFPreferencesViewController class] nibName:[NibNames tableView] title:@"Preferences"];
        
    }else if ([[notification name] isEqualToString:MoreStore]) {
        [self pushClass:[LFStoreViewController class] nibName:[NibNames tableView] title:@"Store"];
        
    }else if ([[notification name] isEqualToString:MenuNotification]) {
        
        [[self mainViewController] dismissGameViewController];
        [[self navigationController] popToRootViewControllerAnimated:YES];
        
    }else if ([[notification name] isEqualToString:MenuDidAppear]) {
        self.mainViewController.isLogoViewHidden = NO;
        
    }else if ([[notification name] isEqualToString:TileImageNameDidChange]) {
        [self.mainViewController updateLogoView];
        [self.menuController updateLogoView];
        
    }
#ifndef DISABLE_GK
    
    else if ([[notification name] isEqualToString:GKHandleInviteNotification]) {
        
        if(self.gameController.gameViewController == nil){
            self.gameController = [self newMultiplayerGameController];
            
            NSArray* players  = [[notification userInfo] objectForKey:GKHandleInvitePlayersToInviteKey];
            
            [(MultiplayerGameController*)self.gameController showGKOpponentControllerWithPlayers:players];
        }
        
        /*
         [self.mainViewController updateLogoView];
         [self.menuController updateLogoView];
         */
    }
#endif
    
}

-(void)pushClass:(Class)controllerClass nibName:(NSString*)nibName title:(NSString*)title{
    
    self.mainViewController.shouldShowGameView = NO;
    
    UIViewController* viewController = [[controllerClass alloc] initWithNibName:nibName bundle:nil];
    [viewController setTitle:title];
    [[self navigationController] pushViewController:viewController animated:YES];
    
}

-(BOOL)openGameURL:(NSURL*)url{
    PuzzleGame* game = [LFURLCoder decodeURL:url];
    if (game != nil) {
        
        [[Analytics sharedAnalytics] trackCategory:@"Open Game" action:@"From URL" label:[url absoluteString] value:0];
        
        [self openGame:game];
    }
    return game != nil;
}

-(void)openGame:(PuzzleGame*)game{
    
    if (game != nil) {
        self.gameController = [self newPuzzleGameController];
        
        SinglePlayerGameController* controller = OBJECT_IF_OF_CLASS(self.gameController, SinglePlayerGameController);
        
        [controller startWithGame:game];
    }
}

-(SinglePlayerGameController*)newPuzzleGameController{
    return (id)[self newGameControllerWithClass:[SinglePlayerGameController class]];
}

-(MultiplayerGameController*)newMultiplayerGameController{
    return (id)[self newGameControllerWithClass:[MultiplayerGameController class]];
}

-(GameController*)newGameControllerWithClass:(Class)GameControllerClass{
    GameController* gameController = [[[GameControllerClass class] alloc] init];
    gameController.navigationController = self.navigationController;
    self.navigationController.delegate = gameController;
    gameController.mainViewController = [self mainViewController];
    self.gameController = gameController;
    return gameController;
}

@end
