//
//  PuCompleteViewController.m
//  Letter Farm
//
//  Created by Daniel Mueller on 6/29/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "PuCompleteViewController.h"
#import "WordTableController.h"
#import "LFActivityController.h"
#import "Puzzle.h"
#import "LFURLCoder.h"
#import "CompareResultsView.h"
#import <QuartzCore/QuartzCore.h>

@interface PuCompleteViewController ()



@property (nonatomic) LFActivityController* activityController;

@property (nonatomic) IBOutlet CompareResultsView* compareResultsView;


@property (nonatomic) IBOutlet UILabel* titleLabel;

@property (nonatomic) IBOutlet UIView* solutionBackgroundView;
@property (nonatomic) IBOutlet UILabel* movesLabel;
@property (nonatomic) IBOutlet UILabel* dateLabel;

@property (nonatomic) IBOutlet UILabel* solutionYoursLabel;
@property (nonatomic) IBOutlet UILabel* solutionOriginalLabel;

@property (nonatomic) IBOutlet UIButton* nextButton;
@property (nonatomic) IBOutlet UIButton* shareButton;

-(IBAction)didTapNextButton:(id)sender;

-(IBAction)didTapShareButton:(id)sender;

-(IBAction)didTapDoneButton:(id)sender;

@end

@implementation PuCompleteViewController

@synthesize puzzleGame=_puzzleGame;
@synthesize activityController=_activityController;

-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    [self.compareResultsView reloadWithLeftWords:self.puzzleGame.solutionWords rightWords:self.puzzleGame.guessedWords endWord:self.puzzleGame.endWord];
    
    self.solutionBackgroundView.layer.cornerRadius=10.0;
    
    NSDate* date = self.puzzleGame.completionDate;
    
    if (date == nil || !self.isShowingHistory) {
        self.dateLabel.hidden = YES;
    }else{
        self.dateLabel.text = [NSDateFormatter localizedStringFromDate:self.puzzleGame.completionDate
                                                             dateStyle:NSDateFormatterShortStyle
                                                             timeStyle:NSDateFormatterShortStyle];
        self.dateLabel.hidden = NO;
    }
    
    if( self.puzzleGame.solutionWords == nil ) {
        self.solutionYoursLabel.hidden = YES;
        self.solutionOriginalLabel.hidden = YES;
        
        CGRect yoursFrame = self.solutionYoursLabel.frame;
        yoursFrame.origin.x = 0.0;
        yoursFrame.size.width = self.view.bounds.size.width;
        self.solutionYoursLabel.frame = yoursFrame;
        
    }else if(self.puzzleGame.playerID != nil){
        self.solutionOriginalLabel.text =  [self.puzzleGame.playerID stringByAppendingString:@"'s"];
    }
    
    int moves = self.puzzleGame.guessedWords.count - 1;
    
    self.movesLabel.text = [NSString stringWithFormat:@"Completed in %d moves", moves];
    
    if (self.isShowingHistory) {
        
        self.nextButton.hidden = YES;
        
        CGPoint shareButtonCenter = self.shareButton.center;
        shareButtonCenter.x = self.view.bounds.size.width/2.0;
        self.shareButton.center = shareButtonCenter;
        
    }
    
    NSString* message = @"Nice Work!";
    
    if (self.puzzleGame.solutionWords == nil) {
        message = @"Nice Work!";
    }else{
        
        int difference = self.puzzleGame.solutionWords.count - self.puzzleGame.guessedWords.count;
        
        if (difference < 0) {
            message = @"Okay!";
        }else if (difference == 0) {
            message = @"Nice Work!";
        }else if (difference > 0) {
            message = @"Awesome!";
        }
    }
    
    self.titleLabel.text = message;
    
}

-(IBAction)didTapNextButton:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:NextPuzzleGameNotification object:self];
}

#define playerName() [[NSUserDefaults standardUserDefaults] objectForKey:@"player_name"]

#define setPlayerName(name) [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"player_name"]


-(IBAction)didTapShareButton:(id)sender{
    
    NSString* playerName = playerName();
    if (playerName==nil) {
        UIAlertView* enterNameView = [[UIAlertView alloc] initWithTitle:@"Enter Your Name:"
                                                                message:@""
                                                               delegate:self
                                                      cancelButtonTitle:@"Skip"
                                                      otherButtonTitles:@"OK", nil];
        [enterNameView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [enterNameView show];
    }else{
        [self shareWithName:playerName];
    }
}

-(IBAction)didTapDoneButton:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:MenuNotification object:self];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSString* response = [[alertView textFieldAtIndex:0] text];
    if (response == nil) {
        response = @"";
    }
    
    NSString* trimmedName = [response stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    setPlayerName(trimmedName);
    
    [self shareWithName:playerName()];
}


-(void)shareWithName:(NSString*)name{
    
    PuzzleGame* puzzleCopy = [self.puzzleGame copy];
    
    puzzleCopy.playerID = name;
    
    NSURL* URL = [LFURLCoder encodePuzzleGame:puzzleCopy];
    
    NSString* message = [NSString stringWithFormat:@"From '%@' to '%@' in %d moves! #letterfarm", puzzleCopy.startWord, puzzleCopy.endWord, (puzzleCopy.guessedWords.count - 1) ];
    
    [self trackEvent:@"Share"];
    if (NSClassFromString(@"UIActivityViewController") != Nil) {
        
        UIActivityViewController* controller = [[UIActivityViewController alloc] initWithActivityItems:@[message,URL] applicationActivities:nil];
        controller.excludedActivityTypes = [NSArray arrayWithObjects:UIActivityTypeAssignToContact, nil];
        
        [self presentViewController:controller animated:YES completion:NULL];
    }else{
        if (self.activityController == nil) {
            self.activityController = [[LFActivityController alloc] initWithParentViewController:self];
        }
        self.activityController.URL = URL;
        self.activityController.message = message;
        
        [self.activityController show];
    }
    
}

-(NSString*)viewName{
    return @"Complete View";
}

@end
