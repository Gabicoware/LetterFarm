//
//  SinglePlayerGameController.m
//  Letter Farm
//
//  Created by Daniel Mueller on 7/2/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "SinglePlayerGameController.h"
#import "PuGameViewController.h"
#import "NibNames.h"
#import "LevelManager.h"
#import "MainViewController.h"

#import "PuzzleGeneratorFactory.h"
#import "PuzzleGame.h"

#import "SelectPackViewController.h"
#import "SelectLevelViewController.h"
#import "CreatePackViewController.h"

#import "PuPauseViewController.h"

#import "PuCompleteViewController.h"
#import "LocalConfiguration.h"
#import "LetterFarmSinglePlayer.h"


#import "Analytics.h"
#import "NSObject+Notifications.h"

NSString* NextPuzzleGameNotification = @"NextPuzzleGameNotification";
NSString* WillCompletePuzzleGameNotification = @"WillCompletePuzzleGameNotification";
NSString* DidCompletePuzzleGameNotification = @"DidCompletePuzzleGameNotification";
NSString* HintNotification = @"HintNotification";
NSString* SolutionNotification = @"SolutionNotification";
NSString* SelectGameNotification = @"SelectGameNotification";

NSString* SelectGamePuzzleGameKey = @"SelectGamePuzzleGameKey";
NSString* SelectGamePackNameKey = @"SelectGamePackNameKey";
NSString* SelectGameLevelIndexKey = @"SelectGameLevelIndexKey";

NSString* CreatePackNotification = @"CreatePackNotification";
NSString* SelectPackNotification = @"SelectPackNotification";
NSString* SelectPackNameKey = @"SelectPackNameKey";

@interface SinglePlayerGameController ()

@property (nonatomic) id generator;

@property (nonatomic) NSString* currentPackName;
@property (nonatomic, assign) int currentLevelIndex;

@property (nonatomic, assign) int customMoves;
@property (nonatomic, assign) int customLetters;
@property (nonatomic, assign) BOOL isCustomLimited;

@end

@implementation SinglePlayerGameController

@synthesize navigationController=_navigationController;
@synthesize generator=_generator;
@synthesize currentPackName=_currentPackName, currentLevelIndex=_currentLevelIndex;

-(PuGameViewController*)puGameViewController{
    return OBJECT_IF_OF_CLASS(self.gameViewController, PuGameViewController);
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(id)init{
    if((self = [super init])){
        
        NSDictionary* noteDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"handleNotification:",NextPuzzleGameNotification,
                                  @"handleNotification:",DidCompletePuzzleGameNotification,
                                  @"handleNotification:",WillCompletePuzzleGameNotification,
                                  @"handleNotification:",HintNotification,
                                  @"handleNotification:",SolutionNotification,
                                  @"handleNotification:",SelectGameNotification,
                                  @"handleNotification:",CreatePackNotification,
                                  @"handleNotification:",SelectPackNotification,
                                  
                                  nil];
        
        [self observeNotifications:noteDict];
        
    }
    return self;
}

-(void)start{
    
    [self presentSelectGameView];
}

-(void)presentSelectGameView{
    [self trackEvent:@"Select Pack"];
    
    UIViewController* selectionController = [[SelectPackViewController alloc] initWithNibName:[NibNames tableView] bundle:nil];
    [selectionController setTitle:@"Select a Pack"];
    [[self navigationController] pushViewController:selectionController animated:YES];
    
}

-(void)startWithGame:(id)game{
    
    [self trackEvent:@"Next Game"];
    
    if ([self puGameViewController] != nil) {
                
        [self presentGameViewController:[self puGameViewController]];
        
        [[self puGameViewController] setIsCreating:NO];
        [[self puGameViewController] startGame:game];
        
    }else{
        
        [self presentGameViewWithGame:game];
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

    puzzleController.isTutorial = [[LevelManager sharedLevelManager] isTutorialPackName:self.currentPackName];
    
    [self presentGameViewController:puzzleController];
    
    [puzzleController setIsCreating:NO];
    [puzzleController startGame:puzzleGame];
    
    
}

-(void)didQuitGame{
        
}

-(void)presentCompleteView{
    
    UIViewController* controller = nil;
    
    PuCompleteViewController* completeViewController = [[PuCompleteViewController alloc] initWithNibName:[NibNames puzzleCompleteView] bundle:nil];
    
    [[completeViewController navigationItem] setHidesBackButton:YES animated:NO];
    
    completeViewController.puzzleGame = [self puGameViewController].puzzleGame;
    
    controller = completeViewController;
    
    [[self navigationController] pushViewController:controller animated:YES];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.mainViewController.shouldShowGameView = NO;
        [[self mainViewController] hideGameViewController];
    }
}


-(void)handleNotification:(NSNotification*)notification{
    if ([[notification name] isEqualToString:SelectGameNotification]) {
        
        NSDictionary* dict = OBJECT_IF_OF_CLASS([notification userInfo], NSDictionary);
        
        PuzzleGame* puzzleGame = OBJECT_IF_OF_CLASS([dict objectForKey:SelectGamePuzzleGameKey], PuzzleGame);

        NSNumber* number = OBJECT_IF_OF_CLASS([dict objectForKey:SelectGameLevelIndexKey], NSNumber);

        NSString* packname = OBJECT_IF_OF_CLASS([dict objectForKey:SelectGamePackNameKey], NSString);
        
        self.currentPackName = packname;
        
        self.currentLevelIndex = [number integerValue];
        
        [self startWithGame:puzzleGame];
        
    }else if([notification isNamed:WillCompletePuzzleGameNotification]){
        
        NSString* packTitle = [[LevelManager sharedLevelManager] packTitleWithName:self.currentPackName];
        
        NSString* message = @"";
        
        if (packTitle != nil) {
            message = [NSString stringWithFormat:@"%@ - Level %d", packTitle, self.currentLevelIndex + 1];
        }
        
        [[self puGameViewController] setGameCompleteMessage:message];
        
    }else if([notification isNamed:DidCompletePuzzleGameNotification]){
        
        [[LocalConfiguration sharedLocalConfiguration] incrementGameCount];
        
        [self puGameViewController].puzzleGame.completionDate = [NSDate date];
        
        if (self.currentPackName != nil) {
            [[LevelManager sharedLevelManager] completeLevel:self.currentLevelIndex
                                                        pack:self.currentPackName
                                                        game:[[self puGameViewController] puzzleGame]];
        }
        
        [self trackEvent:@"Completed Game"];
        
        [self presentCompleteView];
        
    }else if([notification isNamed:NextPuzzleGameNotification]){
        [self trackEvent:@"Next Game"];
        
        int index = self.currentLevelIndex + 1;
        
        if (index < [[LevelManager sharedLevelManager] levelCountForPack:self.currentPackName]) {
            //get the next game
            PuzzleGame* puzzleGame = [[LevelManager sharedLevelManager] puzzleGameForPack:self.currentPackName index:index];
            
            self.currentLevelIndex = index;
            
            [self presentGameViewWithGame:puzzleGame];
            
        }else{
            [self presentSelectGameView];
        }
    }else if([notification isNamed:HintNotification]){
        
        PuzzleGame* game = [[self puGameViewController] puzzleGame];
        NSString* lastGuessedWord = [game.guessedWords lastObject];
        
        HintGenerator* generator = [PuzzleGeneratorFactory newHintGeneratorForWord:lastGuessedWord finalWord:game.endWord];
        
        [generator setTarget:self];
        [generator setAction:@selector(generatorDidCompleteWithHint:)];
        [generator generateInBackground];
        self.generator = generator;
        
    }else if([notification isNamed:SolutionNotification]){
        PuzzleGame* game = [[self puGameViewController] puzzleGame];
        NSString* message = [[game solutionWords] componentsJoinedByString:@"\n"];
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Solution" message:message delegate:nil cancelButtonTitle:@"close" otherButtonTitles: nil];
        
        [alertView show];

    }else if([notification isNamed:CreatePackNotification]){
        UIViewController* createPackViewController = [[CreatePackViewController alloc] initWithNibName:[NibNames createPackView] bundle:nil];
        [createPackViewController setTitle:@"Create Pack"];
        [[self navigationController] pushViewController:createPackViewController animated:YES];
        
    }else if([notification isNamed:SelectPackNotification]){
        
        NSString* packName = [[notification userInfo] objectForKey:SelectPackNameKey];
        
        
        SelectLevelViewController* selectionController = [[SelectLevelViewController alloc] initWithNibName:[NibNames selectLevelView] bundle:nil];
        [selectionController setTitle:@"Select a Level"];
        
        selectionController.packName = packName;
        
        [[self navigationController] pushViewController:selectionController animated:YES];
        
    }
    
    
}

-(void)generatorDidCompleteWithHint:(NSArray*)hint{
    if (hint == nil) {
        [self trackEvent:@"Incomplete Hint"];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Hint"
                                                            message:@"We couldn't find a hint for you! Are you sure you are on the right track?"
                                                           delegate:nil
                                                  cancelButtonTitle:@"close"
                                                  otherButtonTitles: nil];
        
        [alertView show];
        
    }else if(1 < hint.count){
        [self trackEvent:@"Hint"];
        
        NSArray* hintPortion = [hint subarrayWithRange:NSMakeRange(0, 2)];
        
        NSString* message = [hintPortion componentsJoinedByString:@"\n"];
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Hint"
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"close"
                                                  otherButtonTitles: nil];
        
        [alertView show];
        
        PuzzleGame* game = [[self puGameViewController] puzzleGame];
        NSArray* guessedWords = game.guessedWords;
        
        if ([[guessedWords lastObject] isEqualToString:[hintPortion objectAtIndex:0]] && ![[game endWord] isEqualToString:[hintPortion objectAtIndex:1]]) {
            NSArray* hintsToSet = [guessedWords arrayByAddingObject:[hintPortion objectAtIndex:1]];
            [[self puGameViewController] setGuessedWords:hintsToSet];
        }
        
    
    }
}

-(UIViewController<PauseViewController>*)newPauseViewController{
    return [[PuPauseViewController alloc] initWithNibName:nil bundle:nil];
}

-(NSString*)categoryName{
    return @"Single Player";
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [super navigationController:navigationController didShowViewController:viewController animated:animated];
    
    PuCompleteViewController* completeController = OBJECT_IF_OF_CLASS(viewController, PuCompleteViewController);
    
    if ( completeController != nil && !completeController.isShowingHistory ) {
        
        NSMutableArray* updatedControllers = [NSMutableArray arrayWithObjects:[navigationController.viewControllers objectAtIndex:0], nil];
        
        for(UIViewController* controller in navigationController.viewControllers){
            if ([controller isKindOfClass:[SelectLevelViewController class]]) {
                [updatedControllers addObject:controller];
            }
        }
        
        [updatedControllers addObject:viewController];
        
        if (![navigationController.viewControllers isEqualToArray:updatedControllers]) {
            navigationController.viewControllers = [NSArray arrayWithArray:updatedControllers];
        }
        if ([[viewController navigationItem] hidesBackButton]) {
            [[viewController navigationItem] setHidesBackButton:NO animated:YES];
        }
    }
    
    SelectLevelViewController* selectGameViewController = OBJECT_IF_OF_CLASS(viewController, SelectLevelViewController);
    
    if(selectGameViewController != nil){
        
        NSMutableArray* updatedControllers = [NSMutableArray arrayWithObjects:[navigationController.viewControllers objectAtIndex:0], nil];
        
        for(UIViewController* controller in navigationController.viewControllers){
            if ([controller isKindOfClass:[SelectPackViewController class]]) {
                [updatedControllers addObject:controller];
            }
        }
        
        [updatedControllers addObject:viewController];

        if (![navigationController.viewControllers isEqualToArray:updatedControllers]) {
            navigationController.viewControllers = [NSArray arrayWithArray:updatedControllers];
        }
        if ([[viewController navigationItem] hidesBackButton]) {
            [[viewController navigationItem] setHidesBackButton:NO animated:YES];
        }
    }
    
}



@end
