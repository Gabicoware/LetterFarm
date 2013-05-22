//
//  MatchGameCompleteViewController.m
//  LetterFarm
//
//  Created by Daniel Mueller on 8/1/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "MatchGameCompleteViewController.h"

#import "MatchInfo+Strings.h"
#import "WordTableController.h"
#import "PuzzleGame.h"
#import "CompareResultsView.h"

@interface MatchGameCompleteViewController ()


@property (nonatomic) IBOutlet UILabel* firstGameLabel;
@property (nonatomic) IBOutlet UILabel* secondGameLabel;

@property (nonatomic) IBOutlet UILabel* waitingLabel;

@property (nonatomic) IBOutlet CompareResultsView* compareResultsView;

@end

@implementation MatchGameCompleteViewController

@synthesize matchInfo=_matchInfo;
@synthesize yourName=_yourName;

@synthesize firstGame=_firstGame;
@synthesize secondGame=_secondGame;

@synthesize firstGameLabel=_firstGameLabel;
@synthesize secondGameLabel=_secondGameLabel;

@synthesize waitingLabel=_waitingLabel;

-(NSString*)title{
    return [NSString stringWithFormat:@"Round #%d",self.roundNumber];
}

-(void)setFirstGame:(id<MatchGame>)firstGame{
    _firstGame = firstGame;
    
    [self refreshFields];
}

-(void)setSecondGame:(id<MatchGame>)secondGame{
    _secondGame = secondGame;
    
    [self refreshFields];
}

-(void)setMatchInfo:(MatchInfo*)matchInfo{
    _matchInfo = matchInfo;
    
    [self refreshFields];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self refreshFields];
}

-(void)refreshFields{
    if([self isViewLoaded]){
        
        NSString* endWord = [((PuzzleGame*)self.firstGame) endWord];
        
        UIColor* color = [MatchInfo neutralColor];
        
        if(((PuzzleGame*)self.firstGame).guessedWords.count != ((PuzzleGame*)self.secondGame).guessedWords.count){
            color = [self.matchInfo matchColor];
        }
        
        
        self.compareResultsView.compareColor = color;
        
        [self.compareResultsView reloadWithLeftWords:self.firstGame.gameWords rightWords:self.secondGame.gameWords endWord:endWord];
        
        BOOL doesSecondGameExist = self.secondGame != nil;
        
        if (!doesSecondGameExist) {
            CGRect compareViewRect = self.compareResultsView.frame;
            compareViewRect.size.width = self.firstGameLabel.frame.size.width;
            self.compareResultsView.frame = compareViewRect;
        }
        
        [self.waitingLabel setHidden:doesSecondGameExist];
        
        NSString* firstGamePlayerName = @"";
        NSString* secondGamePlayerName = @"";
        
        if([self.firstGame.playerID isEqualToString:self.matchInfo.opponentID]){
            firstGamePlayerName = self.matchInfo.opponentName;
            secondGamePlayerName = self.yourName;
        }else{
            firstGamePlayerName = self.yourName;
            secondGamePlayerName = self.matchInfo.opponentName;
        }
        
        self.firstGameLabel.text = firstGamePlayerName;
        self.secondGameLabel.text = secondGamePlayerName;
        
    }
}

@end
