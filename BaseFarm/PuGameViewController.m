//
//  PuGameViewController.m
//  Letter Farm
//
//  Created by Daniel Mueller on 5/24/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "PuGameViewController.h"

#import "PuGameTilePositionController.h"
#import "PuGameWordHistoryController.h"
#import "PuGameLogicController.h"
#import "PresentationController.h"

#import "TuArrowView.h"

#import "Puzzle.h"
#import "NSObject+Notifications.h"
#import "WordProvider.h"

#import "NibNames.h"

#import <QuartzCore/QuartzCore.h>
#import "SoundEffectManager.h"


@interface PuGameViewController()

@property (nonatomic) TuArrowView* tutorialArrowView;
@property (nonatomic) NSTimer* tutorialTimer;

@property (nonatomic) BOOL needsSetup;

@property (nonatomic) UITapGestureRecognizer* tapGestureRecognizer;

@property (nonatomic) PuGameLogicController* gameLogicController;
@property (nonatomic) IBOutlet PresentationController* presentationController;

@property (nonatomic) IBOutlet id<PuGameTilePositionController> tilePositionController;
@property (nonatomic) IBOutlet PuGameWordHistoryController* wordHistoryController;

@property (nonatomic) IBOutlet UIButton* undoButton;
@property (nonatomic) IBOutlet UIButton* soundButton;

@property (nonatomic) IBOutlet UIView* creatingView;

@property (nonatomic) IBOutlet UIView* congratulationsView;
@property (nonatomic) IBOutlet UILabel* endGameMessageView;
@property (nonatomic) IBOutlet UIView* tapToContinueView;



-(IBAction)didTapPauseButton:(id)sender;
-(IBAction)didTapUndoButton:(id)sender;
-(IBAction)didTapSoundButton:(id)sender;

-(void)presentCreatingView;
-(void)dismissCreatingView;

@end

@implementation PuGameViewController{
    NSString* _gameCompleteMessage;
}

@synthesize tapGestureRecognizer = _tapGestureRecognizer;
@synthesize congratulationsView = _congratulationsView;
@synthesize endGameMessageView = _endGameMessageView;

@synthesize tilePositionController=_tilePositionController;
@synthesize wordHistoryController=_wordHistoryController, gameLogicController=_gameLogicController;
@synthesize presentationController=_presentationController;
@synthesize creatingView=_creatingView;

@synthesize undoButton=_undoButton;

@synthesize isCreating=_isCreating, needsSetup=_needsSetup;
@synthesize isTutorial=_isTutorial;

-(void)setGameCompleteMessage:(NSString*)message{
    _gameCompleteMessage = message;
    self.endGameMessageView.text = message;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.tutorialTimer invalidate];
}

-(void)viewDidUnload{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.tutorialTimer invalidate];
    
    self.creatingView = nil;
    self.undoButton = nil;
    
    self.tapToContinueView = nil;
    self.endGameMessageView = nil;
    self.congratulationsView = nil;
    
    self.gameLogicController = nil;
    self.tilePositionController = nil;
    self.wordHistoryController = nil;
    self.presentationController = nil;
    self.needsSetup = YES;
    
    if (self.tapGestureRecognizer != nil) {
        [[[UIApplication sharedApplication] keyWindow] removeGestureRecognizer:self.tapGestureRecognizer];
        self.tapGestureRecognizer = nil;
    }
}

-(void)setIsTutorial:(BOOL)isTutorial{
    _isTutorial=isTutorial;
    self.tutorialArrowView.hidden = !isTutorial;
    if(isTutorial){
        self.tutorialTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                              target:self
                                                            selector:@selector(didFireTutorialTimer:)
                                                            userInfo:nil
                                                             repeats:YES];
    }else{
        [self.tutorialTimer invalidate];
        self.tutorialTimer = nil;
    }
    
}

-(PuzzleGame*)puzzleGame{
    return self.gameLogicController.puzzleGame;
}

-(void)setIsCreating:(BOOL)isCreating{
    
    BOOL shouldUpdate = _isCreating != isCreating && [self isViewLoaded];
    
    _isCreating = isCreating;
    
    if (shouldUpdate) {
        if (isCreating) {
            [self presentCreatingView];
        }else{
            [self dismissCreatingView];
        }
    }
    
}

-(void)startGame:(PuzzleGame*)puzzleGame{
    
    [[SoundEffectManager sharedSoundEffectManager] startIdle];

    
    self.view.userInteractionEnabled = YES;
    [self setupGame:puzzleGame];
}

-(void)setupGame:(PuzzleGame*)state{
        
    [self dismissCreatingView];
    
    PuGameLogicController* gameLogicController = [[PuGameLogicController alloc] initWithState:state];
    
    self.gameLogicController = gameLogicController;
    
    
    [self setupView];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    //observe notifications
    NSDictionary* notifications = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"handleProposedWordNotification:", ProposedWordNotification,
                                   @"handleDidSelectTileNotification:", PuGameTilePositionControllerDidSelectTile,
                                   nil];
        
    [self observeNotifications:notifications];
    
    self.endGameMessageView.text = _gameCompleteMessage;
    
    if(self.needsSetup){
        [self setupView];
    }
    
    [[SoundEffectManager sharedSoundEffectManager] setGroupName:@"Sheep"];
    
    BOOL isMute = [[SoundEffectManager sharedSoundEffectManager] isMute];
    self.soundButton.selected = isMute;

}

-(void)setupView{
    if (self.gameLogicController != nil && [self isViewLoaded]) {
        self.tilePositionController.activeWord = [self.gameLogicController.puzzleGame.guessedWords lastObject];

        self.tilePositionController.targetWord = self.gameLogicController.puzzleGame.endWord;

        [[self tilePositionController] reload];
        
        [[self wordHistoryController] resetWithGame:self.gameLogicController.puzzleGame];
        
        [self.undoButton setEnabled:[self.gameLogicController canUndo]];
        
        self.needsSetup = NO;
        
    }else{
        self.needsSetup = YES;
    }
}

-(void)setGuessedWords:(NSArray *)guessedWords{
    self.gameLogicController.puzzleGame.guessedWords = guessedWords;
    
    [self setupView];
}

-(void)presentCreatingView{
    for(UIView* subview in self.creatingView.subviews){
        UIActivityIndicatorView* av = OBJECT_IF_OF_CLASS(subview, UIActivityIndicatorView);
        [av startAnimating];
    }
    
    [self.presentationController presentView:self.creatingView withMode:UIViewContentModeCenter];

}

-(void)dismissCreatingView{
    
    [self.presentationController dismissCurrentView];

    for(UIView* subview in self.creatingView.subviews){
        UIActivityIndicatorView* av = OBJECT_IF_OF_CLASS(subview, UIActivityIndicatorView);
        [av stopAnimating];
    }
}


-(IBAction)didTapPauseButton:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:PauseNotification object:self];
}

-(IBAction)didTapUndoButton:(id)sender{
    [self undoMove];

}

-(IBAction)didTapSoundButton:(id)sender{
    BOOL isMute = [[SoundEffectManager sharedSoundEffectManager] isMute];
    
    [[SoundEffectManager sharedSoundEffectManager] setIsMute:!isMute];
    self.soundButton.selected = !isMute;
    
}

-(void)undoMove{
    if ([self.gameLogicController canUndo]) {
        
        
        //update the display for the word history controller, so it responds appropriately
        [[self wordHistoryController] popWord];
        
        [self.gameLogicController undo];
        
        self.tilePositionController.activeWord = [self.gameLogicController.puzzleGame.guessedWords lastObject];
        
        [[self tilePositionController] reload];
        
    }
    [self.undoButton setEnabled:[self.gameLogicController canUndo]];
    
}

-(void)restartGame{
    self.view.userInteractionEnabled = YES;
    
    [self.gameLogicController restart];
    
    self.tilePositionController.activeWord = [self.gameLogicController.puzzleGame.guessedWords lastObject];
    
    [[self tilePositionController] reload];
    
    [[self wordHistoryController] resetWithGame:self.gameLogicController.puzzleGame];
        
    [self.undoButton setEnabled:[self.gameLogicController canUndo]];
}

-(void)handleProposedWordNotification:(id)notification{
    NSString* activeWord = [[self tilePositionController] proposedActiveWord];
    
    [self proposeWord:activeWord];
    
}

-(void)proposeWord:(NSString*)proposedWord{
    
    [self.gameLogicController.puzzleGame incrementGuessCount];
    
    if([self.gameLogicController canMoveToWord:proposedWord]){
        
        //update the display for the word history controller, so it responds appropriately
        [[self wordHistoryController] pushWord:proposedWord];
        
        PuzzleLogicState state = [self.gameLogicController moveToWord:proposedWord];
                
        if (state == PuzzleLogicStateComplete) {
            
            [[SoundEffectManager sharedSoundEffectManager] endIdle];
            
            //dispatch the complete notification when animations are complete
            [[NSNotificationCenter defaultCenter] postNotificationName:WillCompletePuzzleGameNotification object:self];
            
            [self showPuzzleCompleteAnimated:YES finished:^{
            }];
            
            [[SoundEffectManager sharedSoundEffectManager] playFinalTone];
            
        }else{
            NSString* activeWord = [self.gameLogicController.puzzleGame.guessedWords lastObject];

            [[self tilePositionController] didMoveToWord: activeWord ];
            
            int move = self.puzzleGame.guessedWords.count - 1;
            
            [[SoundEffectManager sharedSoundEffectManager] playToneForMove:move];
            
        }
        
    }else{
        
        [[SoundEffectManager sharedSoundEffectManager] playIncorrectGroupSound];
        
        [[self tilePositionController] canNotMoveToWord:proposedWord];
        
    }
    
    [self.undoButton setEnabled:[self.gameLogicController canUndo]];
}
//225	184	104
//216	175	95	
-(void)showPuzzleCompleteAnimated:(BOOL)animated finished:(void(^)(void))finish{
    
    NSString* activeWord = [self.gameLogicController.puzzleGame.guessedWords lastObject];
    [[self tilePositionController] didCompleteWithWord:activeWord finished:^{
        self.view.userInteractionEnabled = NO;
        
        self.congratulationsView.alpha = 0.0;
        self.congratulationsView.hidden = NO;
        
        self.endGameMessageView.alpha = 0.0;
        self.endGameMessageView.hidden = NO;
        
        self.tapToContinueView.alpha = 0.0;
        self.tapToContinueView.hidden = NO;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.tapToContinueView.alpha = 1.0;
            self.congratulationsView.alpha = 1.0;
            self.endGameMessageView.alpha = 1.0;
        } completion:^(BOOL finished) {
            
            
            if (finish != NULL) {
                int64_t delayInSeconds = 2.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    
                    finish();
                });
            }
        }];
        
    }];
    
    if (self.tapGestureRecognizer == nil) {
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapContinueWindow:)];
        [self.view.window addGestureRecognizer:self.tapGestureRecognizer];
    }
}

-(void)didTapContinueWindow:(id)sender{
    [self.view.window removeGestureRecognizer:self.tapGestureRecognizer];
    self.tapGestureRecognizer = nil;
    
    //dispatch the complete notification when animations are complete
    [[NSNotificationCenter defaultCenter] postNotificationName:DidCompletePuzzleGameNotification object:self];
    
    self.congratulationsView.hidden = YES;
    self.endGameMessageView.hidden = YES;
    self.tapToContinueView.hidden = YES;


}

-(NSString*)viewName{
    return @"Game View";
}

-(void)handleDidSelectTileNotification:(id)notification{
    if(self.tutorialArrowView != nil && 0 < self.tutorialArrowView.alpha){
        [UIView animateWithDuration:0.5 animations:^{
            self.tutorialArrowView.alpha = 0.0;
        }];
        
    }
}

-(void)didFireTutorialTimer:(NSTimer*)timer{
    //do something
    BOOL hasNotGuessed = self.puzzleGame.guessedWords.count < self.puzzleGame.solutionWords.count;
    BOOL hasSolution = 1 < self.puzzleGame.solutionWords.count;
    BOOL hasNoSelectedTile = ![self.tilePositionController hasSelectedTileView];
    
    if(hasNotGuessed && hasSolution && hasNoSelectedTile){
        NSString* activeWord = [self.puzzleGame.guessedWords lastObject];
        NSString* nextWord = [self.puzzleGame.solutionWords objectAtIndex:self.puzzleGame.guessedWords.count];
        
        NSString* neededNextLetter = nil;
        int neededNextIndex = -1;
        
        NeededMove neededMove = [[WordProvider currentWordProvider] neededMoveWithWord:activeWord next:nextWord];
        
        neededNextLetter = neededMove.letter != '\0' ? [NSString stringWithUTF8String:&(neededMove.letter)] : nil;
        neededNextIndex = neededMove.index;
        
        if( neededNextLetter != nil ){
            
            [self setupTutorialView];
            
            UIView* neededView = [self.tilePositionController keyViewWithLetter:neededNextLetter];
            
            UIView* destinationView = [self.tilePositionController activeViewWithIndex:neededNextIndex];
            
            if(![self.tutorialArrowView.fromView isEqual:neededView] && ![self.tutorialArrowView.toView isEqual:destinationView]){
                
                [self.tutorialArrowView drawArrowFrom:neededView toView:destinationView];
                
            }
            
            [UIView animateWithDuration:0.5 animations:^{
                self.tutorialArrowView.alpha = 1.0;
            }];
            
        }
        
    }
    
}

#define IPAD_ARROW_VIEW_FRAME CGRectMake(0, 0, 768, 748);

-(void)setupTutorialView{
    if(self.tutorialArrowView == nil){
        CGRect arrowViewFrame;
        UIViewAutoresizing autoresizingMask;
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            
            arrowViewFrame = IPAD_ARROW_VIEW_FRAME;
            arrowViewFrame.origin.x = (self.view.bounds.size.width - arrowViewFrame.size.width)/2;
            arrowViewFrame.origin.y = (self.view.bounds.size.height - arrowViewFrame.size.height);
            
            autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
        }else{
            arrowViewFrame = self.view.bounds;
            autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        }
        
        self.tutorialArrowView = [[TuArrowView alloc] initWithFrame:arrowViewFrame];
        self.tutorialArrowView.userInteractionEnabled = NO;
        self.tutorialArrowView.autoresizingMask = autoresizingMask;
        self.tutorialArrowView.alpha = 0.0;
        
        [self.view addSubview:self.tutorialArrowView];
    }
}

@end
