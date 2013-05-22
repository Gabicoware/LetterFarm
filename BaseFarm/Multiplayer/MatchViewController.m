//
//  MatchViewController.m
//  LetterFarm
//
//  Created by Daniel Mueller on 8/1/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "MatchViewController.h"
#import "TableViewCellFactory.h"
#import "MatchGameCompleteViewController.h"
#import "NibNames.h"
#import "PuzzleGame.h"
#import "MatchInfo+Strings.h"

typedef enum _RoundStatus{
    RoundStatusNone,
    RoundStatusYouWon,
    RoundStatusTheyWon,
    RoundStatusTied
}RoundStatus;

NSString* MatchViewNextRoundNotification = @"MatchViewNextRoundNotification";

@interface MatchViewController ()

@property (nonatomic) IBOutlet UITableView* tableView;

@property (nonatomic) IBOutlet UIView* headerView;
@property (nonatomic) IBOutlet UILabel* titleLabel;
@property (nonatomic) IBOutlet UILabel* opponentLabel;
@property (nonatomic) IBOutlet UILabel* roundLabel;

@end

@implementation MatchViewController

@synthesize roundLabel=_roundLabel;
@synthesize titleLabel=_titleLabel;
@synthesize opponentLabel=_opponentLabel;
@synthesize tableView=_tableView;
@synthesize matchInfo=_matchInfo;

-(UIColor*)activeLabelColor{
    return [UIColor colorWithRed:78.0/255.0 green:134.0/255.0 blue:30.0/255.0 alpha:1.0];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self.tableView setBackgroundView:nil];
    [self refreshDisplay];
}

-(void)setMatchInfo:(MatchInfo *)matchInfo{
    _matchInfo = matchInfo;
    [self refreshDisplay];
}

-(void)refreshDisplay{
    
    [[self tableView] reloadData];
    
    self.titleLabel.text = [self.matchInfo outcomeString];
    
    self.opponentLabel.text = self.opponentLabelText;
        
    self.roundLabel.text = self.roundLabelText;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([self isDetailSection:section]) {
        return 1;
    }else if ([self isMatchSection:section]) {
        int count = self.matchInfo.games.count;
        return count/2 + count%2;
    }else if([self isNextRoundSection:section]){
        return 1;
    }else if([self isEmailSection:section]){
        return 1;
    }
    return 0;
}

-(BOOL)doesNeedAnotherRound{
    MatchStatus status = self.matchInfo.status;
    return self.matchInfo.games.count %2 == 0 && !MatchStatusIsComplete(status);
}

-(BOOL)canResendEmail{
#ifndef DISABLE_EMAIL
    BOOL isEmail = self.matchInfo.opponentType == OpponentTypeEmail;
    MatchStatus status = self.matchInfo.status;
    BOOL hasAppropriateStatus = status != MatchStatusTheyQuit && status != MatchStatusYourTurn && status != MatchStatusNone && status != MatchStatusInvalid;
    return isEmail && hasAppropriateStatus;
#else
    return NO;
#endif
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([self doesNeedAnotherRound] || [self canResendEmail]) {
        return 3;
    }else{
        return 2;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return self.headerView.frame.size.height;
    }else{
        return 44.0;
    }
}

-(BOOL)isDetailSection:(int)section{
    return section == 0;
}

-(BOOL)isNextRoundSection:(int)section{
    return [self doesNeedAnotherRound] && section == 1;
}

-(BOOL)isMatchSection:(int)section{
    return ([self doesNeedAnotherRound] && section == 2) ||  (![self doesNeedAnotherRound] && section == 1);
}

-(BOOL)isEmailSection:(int)section{
    return [self canResendEmail] && (([self doesNeedAnotherRound] && section == 3) ||  (![self doesNeedAnotherRound] && section == 2));
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * tableViewCell = nil;
        
    if ([self isDetailSection:[indexPath section]]) {
        tableViewCell = [self tableView:tableView detailsCellForRowAtIndexPath:indexPath];
    }else if ([self isMatchSection:[indexPath section]]) {
        tableViewCell = [self tableView:tableView gameCellForRowAtIndexPath:indexPath];
    }else if([self isNextRoundSection:[indexPath section]]){
        tableViewCell = [self tableView:tableView nextRoundCellForRowAtIndexPath:indexPath];
    }else if([self isEmailSection:[indexPath section]]){
        tableViewCell = [self tableView:tableView resendEmailCellForRowAtIndexPath:indexPath];
    }
    
    return tableViewCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView detailsCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* DetailsCellReuseIdentifier = @"DetailsCellReuseIdentifier";
    
    UITableViewCell * tableViewCell = [[self tableView] dequeueReusableCellWithIdentifier:DetailsCellReuseIdentifier];
    
    if (tableViewCell == nil) {
        tableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                               reuseIdentifier:DetailsCellReuseIdentifier];
        [tableViewCell.contentView addSubview:self.headerView];
        tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return tableViewCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView nextRoundCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* NextRoundCellReuseIdentifier = @"NextRoundCellReuseIdentifier";
    
    UITableViewCell * tableViewCell = [[self tableView] dequeueReusableCellWithIdentifier:NextRoundCellReuseIdentifier];
    
    if (tableViewCell == nil) {
        tableViewCell = [TableViewCellFactory newTableViewCellWithReuseIdentifier:NextRoundCellReuseIdentifier];
        [tableViewCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        tableViewCell.textLabel.textColor = [self activeLabelColor];
    }
    
    tableViewCell.textLabel.text = self.nextRoundText;
    
    return tableViewCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView resendEmailCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* ResendEmailCellReuseIdentifier = @"ResendEmailCellReuseIdentifier";
    
    UITableViewCell * tableViewCell = [[self tableView] dequeueReusableCellWithIdentifier:ResendEmailCellReuseIdentifier];
    
    if (tableViewCell == nil) {
        tableViewCell = [TableViewCellFactory newTableViewCellWithReuseIdentifier:ResendEmailCellReuseIdentifier];
        [tableViewCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    tableViewCell.textLabel.text = @"Resend Email";
    
    return tableViewCell;
}

-(BOOL)isActiveAtIndex:(int)index{
    id firstGame = [self firstGameAtIndex:index];
    id secondGame = [self secondGameAtIndex:index];
    
    BOOL hasGame = firstGame != nil;
    BOOL needsPlayersTurn = secondGame == nil && self.matchInfo.status == MatchStatusYourTurn;
    return hasGame && needsPlayersTurn;
}

- (UITableViewCell *)tableView:(UITableView *)tableView gameCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString* MatchTableViewCellReuseIdentifier = @"MatchTableViewCellReuseIdentifier";
    static NSString* ActiveMatchTableViewCellReuseIdentifier = @"ActiveMatchTableViewCellReuseIdentifier";
    
    int index = [self indexFromRow:indexPath.row];
    BOOL isActiveMatch = [self isActiveAtIndex:index];
    
    NSString* reuseIdentifier = nil;
    
    if (isActiveMatch) {
        reuseIdentifier = MatchTableViewCellReuseIdentifier;
    }else{
        reuseIdentifier = ActiveMatchTableViewCellReuseIdentifier;
    }
    
    UITableViewCell * tableViewCell = [[self tableView] dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (tableViewCell == nil) {
        tableViewCell = [TableViewCellFactory newGameTableViewCellWithReuseIdentifier:reuseIdentifier];
        if (isActiveMatch) {
            tableViewCell.textLabel.textColor = [self activeLabelColor];
            tableViewCell.detailTextLabel.textColor = [self activeLabelColor];
        }
    }
    
#ifdef COLOR_WORD
    
    PuzzleGame* game = [self firstGameAtIndex:index];
    
    ColorGameLabel* colorGameLabel = PROPERTY_IF_RESPONDS(tableViewCell, colorGameLabel);
    
    [colorGameLabel setRound:(index + 1)];
    colorGameLabel.startWord = game.startWord;
    colorGameLabel.endWord = game.endWord;
    
    
    
#else
    
    NSString* text = [self textForIndex:index];
    
    [[tableViewCell textLabel] setText:text];
#endif
    NSString* detailText = [self detailTextForIndex:index];
    
    [[tableViewCell detailTextLabel] setText:detailText];
    
    RoundStatus roundStatus = [self roundStatusForIndex:index];
    
    if ([indexPath row] == 0 && roundStatus != RoundStatusNone && roundStatus != RoundStatusTied ) {
        [tableViewCell setBackgroundColor:self.matchInfo.matchColor];
    }else{
        [tableViewCell setBackgroundColor:[UIColor colorWithWhite:247.0/255.0 alpha:1.0]];
    }
    
    return tableViewCell;
}

-(NSString*)textForIndex:(NSInteger)index{
    
    PuzzleGame* game = [self firstGameAtIndex:index];
    
    return [NSString stringWithFormat:@"r%d - %@ to %@", (index + 1), game.startWord.uppercaseString, game.endWord.uppercaseString];
    
}

-(NSString*)nextRoundText{
    return @"Continue to Next Round";
}

-(NSString*)opponentLabelText{
    
#ifndef DISABLE_GK
    if (self.matchInfo.opponentType == OpponentTypeGK && self.matchInfo.opponentName == nil) {
        return @"Automatching";
    }else
#endif
    {
        return [NSString stringWithFormat:@"vs. %@",self.matchInfo.opponentName];
    }
    
}

-(NSString*)roundLabelText{
    return [NSString stringWithFormat:@"Round %d", self.matchInfo.roundCount];
}

-(RoundStatus)roundStatusForIndex:(NSInteger)index{
    
    id<MatchGame> firstGame = [self firstGameAtIndex:index];
    id<MatchGame> secondGame = [self secondGameAtIndex:index];
            
    RoundStatus roundStatus = RoundStatusNone;
    
    switch ([firstGame outcomeAgainstGame:secondGame]) {
        case MatchGameNone:
            break;
        case MatchGameWon:
            if ([[firstGame playerID] isEqualToString:self.matchInfo.opponentID]) {
                roundStatus = RoundStatusTheyWon;
            }else{
                roundStatus = RoundStatusYouWon;
            }
            break;
        case MatchGameTied:
            roundStatus = RoundStatusTied;
            break;
        case MatchGameDraw:
            roundStatus = RoundStatusTied;
            break;
        case MatchGameLost:
            if ([[secondGame playerID] isEqualToString:self.matchInfo.opponentID]) {
                roundStatus = RoundStatusTheyWon;
            }else{
                roundStatus = RoundStatusYouWon;
            }
            break;
            
    }
    return roundStatus;
}

-(PuzzleGame*)firstGameAtIndex:(NSInteger)index{
    NSInteger gameIndex = index*2;
    
    PuzzleGame* result = nil;
    
    if (gameIndex < [self.matchInfo.games count]) {
        result = OBJECT_IF_OF_CLASS([self.matchInfo.games objectAtIndex:gameIndex], PuzzleGame);
    }
    return result;
}

-(PuzzleGame*)secondGameAtIndex:(NSInteger)index{
    NSInteger gameIndex = index*2 + 1;
    
    PuzzleGame* result = nil;
    
    if (gameIndex < [self.matchInfo.games count]) {
        result = OBJECT_IF_OF_CLASS([self.matchInfo.games objectAtIndex:gameIndex], PuzzleGame);
    }
    return result;
    
}

-(NSString*)detailTextForIndex:(NSInteger)index{
    
    id<MatchGame> secondGame = [self secondGameAtIndex:index];
    
    NSString* result = @"";
    
    if (secondGame == nil) {
        if (self.matchInfo.status == MatchStatusYourTurn) {
            result = @"Your Turn, Tap Here";
        }else{
            result = @"Waiting";
        }
    }else{
        
        result = [MatchInfo timeStringWithDate:secondGame.completionDate];
        
    }
    return result;
    
}

-(NSString*)yourName{
    return @"You";
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath section] == 0) {
        indexPath = nil;
    }
    return indexPath;
}

-(int)indexFromRow:(int)row{
    int count = self.matchInfo.games.count;
    
    int index = count/2 + count%2 - row - 1;
    
    return index;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* notificationName = nil;
    
    if ([self isMatchSection:[indexPath section]]) {
        
        int index = [self indexFromRow:indexPath.row];
        
        id firstGame = [self firstGameAtIndex:index];
        id secondGame = [self secondGameAtIndex:index];
        
        BOOL hasGame = firstGame != nil;
        BOOL isActiveMatch = [self isActiveAtIndex:index];

        if (isActiveMatch) {
            notificationName = SelectMatchMutliplayer;
        }else if (hasGame) {
            //push a MatchGameCompleteViewController
            MatchGameCompleteViewController* completeViewController = [[MatchGameCompleteViewController alloc] initWithNibName:[NibNames matchGameCompleteView] bundle:nil];
            
            completeViewController.roundNumber = index + 1;
            completeViewController.firstGame = firstGame;
            completeViewController.secondGame = secondGame;
            completeViewController.matchInfo = self.matchInfo;
            completeViewController.yourName = [self yourName];
            
            [[self navigationController] pushViewController:completeViewController animated:YES];
        }
        
    }else if([self isNextRoundSection:[indexPath section]]){
            notificationName = SelectMatchMutliplayer;
    }else if([self isEmailSection:[indexPath section]]){
            notificationName = ResendEmail;
    }
    if (notificationName != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                            object:self
                                                          userInfo:(id)self.matchInfo];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
