//
//  SelectMatchViewController.m
//  LetterFarm
//
//  Created by Daniel Mueller on 11/29/12.
//
//

#import "SelectMatchViewController.h"

#import "TableViewCellFactory.h"
#import "MatchInfo.h"
#import "MatchInfo+Strings.h"
#import "PuzzleGame.h"

typedef enum _NewGameSectionRow{
    NewGameSectionRowDifficulty,
#ifndef DISABLE_EMAIL
    NewGameSectionRowEmail,
#endif
#ifndef DISABLE_GK
    NewGameSectionRowGK,
#endif
#ifndef DISABLE_FB
    NewGameSectionRowFB,
#endif
#ifndef DISABLE_LOCAL
    NewGameSectionRowLocal,
    NewGameSectionRowPassNPlay,
#endif
    NewGameSectionRowTotal,
}NewGameSectionRow;


typedef enum _MatchSection{
    MatchSectionTop,
    MatchSectionYourTurn,
    MatchSectionTheirTurn,
    MatchSectionRecentlyEnded,
} MatchSection;

NSString* SelectMatchNewGame = @"SelectMatchViewControllerNewGame";

NSString* SelectMatchMutliplayer = @"SelectMatchViewControllerMutliplayer";
NSString* SelectMatchCompleteMutliplayer = @"SelectMatchViewControllerCompleteMutliplayer";
NSString* ShowMatchesMutliplayer = @"ShowMatchesMutliplayer";

NSString* ResendEmail = @"ResendEmail";

@interface SelectMatchViewController()

@property (nonatomic) NSArray* sections;

@property (nonatomic) NSIndexPath* pendingIndexPath;

@property (nonatomic) NSMutableArray* yourTurnMatches;
@property (nonatomic) NSMutableArray* theirTurnMatches;
@property (nonatomic) NSMutableArray* recentlyEndedMatches;

@property (nonatomic) NSDateFormatter* dateFormatter;

@end

@implementation SelectMatchViewController{
    BOOL _isTableLocked;
}

@synthesize yourTurnMatches=_yourTurnMatches;
@synthesize theirTurnMatches=_theirTurnMatches;
@synthesize recentlyEndedMatches=_recentlyEndedMatches;
@synthesize pendingIndexPath=_pendingIndexPath;

-(NSMutableArray*)allEndedMatches{
    return self.recentlyEndedMatches;
}

@synthesize isNetworkReachable=_isNetworkReachable;

@synthesize sections=_sections;

@synthesize tableView=_tableView;

@synthesize mediator=_mediator;

@synthesize dateFormatter=_dateFormatter;


-(NSString*)title{
    return @"Select Match";
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setIsNetworkReachable:(BOOL)isNetworkReachable{
    _isNetworkReachable = isNetworkReachable;
    [self reloadData];
}

-(void)updateMatches:(NSArray*)matches{
    self.yourTurnMatches = [NSMutableArray array];
    self.theirTurnMatches = [NSMutableArray array];
    self.recentlyEndedMatches = [NSMutableArray array];
    
    for (MatchInfo* match in matches) {
        
        if (match.status == MatchStatusYourTurn) {
            [self.yourTurnMatches addObject:match];
        }else if (match.status == MatchStatusTheirTurn) {
            [self.theirTurnMatches addObject:match];
        }else{
            [self.recentlyEndedMatches addObject:match];
        }
    }
    
    [self reloadData];
    
}

-(void)reloadData{
    if (!_isTableLocked) {
        [[self tableView] reloadData];
    }

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.mediator reloadMatches];
}

-(MatchSection)tableSectionWithIndex:(NSInteger)index{
    NSNumber* sectionNumber = [self.sections objectAtIndex:index];
    return [sectionNumber integerValue];
}

-(NSMutableArray*)objectsAtSection:(NSInteger)section{
    MatchSection tableSection = [self tableSectionWithIndex:section];
    
    NSMutableArray* objects = nil;
    
    switch (tableSection) {
        case MatchSectionTop:
            break;
        case MatchSectionYourTurn:
            objects = self.yourTurnMatches;
            break;
        case MatchSectionTheirTurn:
            objects = self.theirTurnMatches;
            break;
        case MatchSectionRecentlyEnded:
            objects = self.recentlyEndedMatches;
            break;
    }
    
    return objects;
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    NSMutableArray* mutableSections = [NSMutableArray array];
    
    [mutableSections addObject:[NSNumber numberWithInt:MatchSectionTop]];
    
    if (0 < self.yourTurnMatches.count) {
        [mutableSections addObject:[NSNumber numberWithInt:MatchSectionYourTurn]];
    }
    
    if (0 < self.theirTurnMatches.count) {
        [mutableSections addObject:[NSNumber numberWithInt:MatchSectionTheirTurn]];
    }
    
    if (0 < self.recentlyEndedMatches.count) {
        [mutableSections addObject:[NSNumber numberWithInt:MatchSectionRecentlyEnded]];
    }
        
    self.sections = mutableSections;
    
    return self.sections.count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger rowCount = 0;
    
    MatchSection tableSection = [self tableSectionWithIndex:section];
    
    switch (tableSection) {
        case MatchSectionTop:
            rowCount = NewGameSectionRowTotal;
            break;
        case MatchSectionYourTurn:
            rowCount = self.yourTurnMatches.count;
            break;
        case MatchSectionTheirTurn:
            rowCount = self.theirTurnMatches.count;
            break;
        case MatchSectionRecentlyEnded:
            if(3 < self.recentlyEndedMatches.count){
                //include the "View All" Row
                rowCount = 4;
            }else{
                //just show the matches
                rowCount = self.recentlyEndedMatches.count;
            }
            break;
    }
    
    return rowCount;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    NSString * title = nil;
    
    MatchSection tableSection = [self tableSectionWithIndex:section];
    
    switch (tableSection) {
        case MatchSectionTop:
            title = @"New Match";
            break;
        case MatchSectionYourTurn:
            title = @"Your Turn";
            break;
        case MatchSectionTheirTurn:
            title = @"Their Turn";
            break;
        case MatchSectionRecentlyEnded:
            title = @"Recently Ended Matches";
            break;
    }
    return title;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    
    MatchSection tableSection = [self tableSectionWithIndex:[indexPath section]];
    
    switch (tableSection) {
        case MatchSectionTop:{
            if ([indexPath row] == NewGameSectionRowDifficulty) {
                cell = [self tableView:tableView difficultyCellForRowAtIndexPath:indexPath];
            }else{
                cell = [self tableView:tableView opponentTypeCellForRowAtIndexPath:indexPath];
            }
            break;
        }
        default:{
            
            MatchSection tableSection = [self tableSectionWithIndex:[indexPath section]];
            
            if (tableSection == MatchSectionRecentlyEnded && [indexPath row] == 3) {
                cell = [self tableView:tableView viewAllCellForRowAtIndexPath:indexPath];
            }else{
                cell = [self tableView:tableView matchCellForRowAtIndexPath:indexPath];
            }
            
            
            break;
        }
    }
    
    return cell;
    
}

#define Difficult_Value_Key @"SelectMatchViewController.DefaultMultipleyDifficultyValue"

- (UITableViewCell *)tableView:(UITableView *)tableView difficultyCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* CellIdentifier = @"DifficultyCell";
    
    UITableViewCell* cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [TableViewCellFactory newSliderTableViewCellWithReuseIdentifier:CellIdentifier];
        [[cell slider] addTarget:self action:@selector(didTouchUpInsideSlider:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    float value = [SelectMatchViewController defaultStartingDifficulty];
    
    [[cell slider] setValue:value];
    
    [[cell sliderLabel] setText:[self textWithSliderValue:[[cell slider] value]]];
    
    return cell;
}

-(void)didTouchUpInsideSlider:(id)sender{
    
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:NewGameSectionRowDifficulty inSection:0]];
    
    float f_value = roundf([[cell slider] value]);
    
    [[NSUserDefaults standardUserDefaults] setFloat:f_value forKey:Difficult_Value_Key];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[cell slider] setValue:f_value];
    
    [[cell sliderLabel] setText:[self textWithSliderValue:[[cell slider] value]]];
}

+(int)defaultStartingDifficulty{
    float value = [[NSUserDefaults standardUserDefaults] floatForKey:Difficult_Value_Key];
    
    if (value < DifficultyEasy) {
        value = DifficultyEasy;
        [[NSUserDefaults standardUserDefaults] setFloat:value forKey:Difficult_Value_Key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return value;
}

-(NSString*)textWithSliderValue:(float)value{
    
    Difficulty difficulty = MIN(MAX(((int)value),DifficultyEasy),DifficultyBrutal);
    
    NSString* difficultyName = @"";
    
    switch (difficulty) {
        case DifficultyEasy:
            difficultyName = @"Easy";
            break;
        case DifficultyMedium:
            difficultyName = @"Medium";
            break;
        case DifficultyHard:
            difficultyName = @"Hard";
            break;
        case DifficultyVeryHard:
            difficultyName = @"Very Hard";
            break;
        case DifficultyBrutal:
            difficultyName = @"Brutal";
            break;
        case DifficultyNone:
            break;
    }
    
    int moves = MovesWithDifficulty(difficulty);
    
    return [NSString stringWithFormat: @"Starting Difficulty - %@ (%d)", difficultyName, moves];
}

- (UITableViewCell *)tableView:(UITableView *)tableView opponentTypeCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* CellIdentifier = @"NewMatchCell";
    
    UITableViewCell* cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    
    [[cell textLabel] setTextColor:[UIColor blackColor]];
    [[cell imageView] setAlpha:1.0];

    switch ([indexPath row]) {
#ifndef DISABLE_EMAIL
        case NewGameSectionRowEmail:{
            [[cell textLabel] setText:@"Email"];
            [[cell detailTextLabel] setText:@"Send matches via email"];
            UIImage* image =[UIImage imageNamed:@"email_icon.png"];
            [[cell imageView] setImage:image];
            break;
        }
#endif
#ifndef DISABLE_GK
        case NewGameSectionRowGK:{
            [[cell textLabel] setText:@"Game Center"];
            [[cell detailTextLabel] setText:@"Random opponents available"];
            UIImage* image =[UIImage imageNamed:@"game_center_icon.png"];
            [[cell imageView] setImage:image];
            break;
        }
#endif
#ifndef DISABLE_FB
        case NewGameSectionRowFB:{
            [[cell textLabel] setText:@"Facebook"];
            [[cell detailTextLabel] setText:@"Requires invites and publishing"];
            UIImage* image =[UIImage imageNamed:@"facebook_icon.png"];
            [[cell imageView] setImage:image];
            break;
        }
#endif
#ifndef DISABLE_LOCAL
        case NewGameSectionRowLocal:{
            [[cell textLabel] setText:@"Vs Computer"];
            [[cell detailTextLabel] setText:@"You think you're better than me?"];
            UIImage* image =[UIImage imageNamed:@"iphone_icon.png"];
            [[cell imageView] setImage:image];
            break;
        }
        case NewGameSectionRowPassNPlay:{
            [[cell textLabel] setText:@"Pass and Play"];
            [[cell detailTextLabel] setText:@"In person on the same device"];
            UIImage* image =[UIImage imageNamed:@"passnplay_icon.png"];
            [[cell imageView] setImage:image];
            break;
        }
#endif
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView viewAllCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    
    static NSString* ViewAllCellIdentifier = @"ViewAllCell";
    cell = [tableView dequeueReusableCellWithIdentifier:ViewAllCellIdentifier];
    if (cell == nil) {
        cell = [TableViewCellFactory newTableViewCellWithReuseIdentifier:ViewAllCellIdentifier];
        [[cell textLabel] setText:@"View All"];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat rowHeight;
    
    MatchSection tableSection = [self tableSectionWithIndex:[indexPath section]];
    
    switch (tableSection) {
        case MatchSectionTop:
            rowHeight = 44.0;
            break;
        case MatchSectionYourTurn:
        case MatchSectionTheirTurn:
        case MatchSectionRecentlyEnded:
            rowHeight = 54.0;
            break;
            
    }
    
    return rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MatchSection tableSection = [self tableSectionWithIndex:[indexPath section]];
    
    switch (tableSection) {
        case MatchSectionTop:
            switch ([indexPath row]) {
#ifndef DISABLE_GK
                case NewGameSectionRowGK:
                    self.opponentType = OpponentTypeGK;
                    break;
#endif
#ifndef DISABLE_LOCAL
                case NewGameSectionRowLocal:
                    self.opponentType = OpponentTypeComputer;
                    break;
                case NewGameSectionRowPassNPlay:
                    self.opponentType = OpponentTypePassNPlay;
                    break;
#endif
#ifndef DISABLE_FB
                case NewGameSectionRowFB:
                    self.opponentType = OpponentTypeFB;
                    break;
#endif
#ifndef DISABLE_EMAIL
                case NewGameSectionRowEmail:
                    self.opponentType = OpponentTypeEmail;
                    break;
#endif
            }
            if (self.opponentType != OpponentTypeNone) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SelectMatchNewGame
                                                                    object:self];
            }
            break;
        case MatchSectionYourTurn:
        {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SelectMatchMutliplayer
                                                                object:self
                                                              userInfo:[self objectAtIndexPath:indexPath]];
            
            
            break;
        }
        case MatchSectionTheirTurn:
        case MatchSectionRecentlyEnded:
        {
            if ([indexPath row] < 3) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:SelectMatchCompleteMutliplayer
                                                                    object:self
                                                                  userInfo:[self objectAtIndexPath:indexPath]];
                
            }else{
                
                [[NSNotificationCenter defaultCenter] postNotificationName:ShowMatchesMutliplayer
                                                                    object:self
                                                                  userInfo:nil];
            }
            
        }
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    
    MatchSection tableSection = [self tableSectionWithIndex:[indexPath section]];
    
    BOOL canEdit = NO;
    
    switch (tableSection) {
        case MatchSectionTop:
            break;
        case MatchSectionYourTurn:
        case MatchSectionTheirTurn:
        case MatchSectionRecentlyEnded:
            canEdit = YES;
            break;
            
    }
    
    return canEdit;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MatchSection tableSection = [self tableSectionWithIndex:[indexPath section]];
    
    NSString* buttonTitle = nil;
    
    switch (tableSection) {
        case MatchSectionTop:
            break;
        case MatchSectionYourTurn:
        case MatchSectionTheirTurn:
            buttonTitle = @"Quit";
            break;
        case MatchSectionRecentlyEnded:
            buttonTitle = @"Delete";
            break;
            
    }
    
    return buttonTitle;
    
}

-(void)deleteMatchInfoAtIndexPath:(NSIndexPath*)indexPath{
    
    _isTableLocked= YES;
    
    id object = [self objectAtIndexPath:indexPath];
    
    MatchInfo* match = OBJECT_IF_OF_CLASS(object, MatchInfo);
    
    if (match != nil) {
        UITableViewRowAnimation animation = UITableViewRowAnimationBottom;
        
        NSUInteger matchesCount = [[self objectsAtSection:[indexPath section]] count];
        
        if ( [indexPath row] == matchesCount - 1 ) {
            animation = UITableViewRowAnimationTop;
        }
        
        [[self tableView] beginUpdates];
        
        NSMutableArray* objects = [self objectsAtSection:[indexPath section]];
        [objects removeObject:object];
        
        MatchSection tableSection = [self tableSectionWithIndex:[indexPath section]];
        
        switch (tableSection) {
            case MatchSectionTop:
                break;
            case MatchSectionYourTurn:
            case MatchSectionTheirTurn:
                [[self mediator] quitMatch:match];
                break;
            case MatchSectionRecentlyEnded:
                [[self mediator] deleteMatch:match];
                break;
                
        }
        
        [self numberOfSectionsInTableView:self.tableView];
        
        if (tableSection == MatchSectionRecentlyEnded  ) {
            
            if ( matchesCount == 1 ) {
                [[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:animation];
            }else if( matchesCount < 4 ){
                [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:animation];
            }else{
                
                if( matchesCount == 4){
                    NSArray* deletePaths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:3 inSection:[indexPath section]], nil];
                    [[self tableView] deleteRowsAtIndexPaths:deletePaths withRowAnimation:animation];
                }
                
                NSArray* insertPaths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2 inSection:[indexPath section]], nil];
                [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:animation];
                [[self tableView] insertRowsAtIndexPaths:insertPaths withRowAnimation:animation];
                
            }
        }else{
            
            if ( matchesCount == 1 ) {
                [[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:animation];
            }else{
                [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:animation];
            }
            
            if ([self.recentlyEndedMatches containsObject:object]) {
                int row = [self.recentlyEndedMatches indexOfObject:object];
                
                NSInteger endedSectionIndex = [self.sections indexOfObject:[NSNumber numberWithInt:MatchSectionRecentlyEnded]];
                
                NSIndexPath* updatedIndexPath = [NSIndexPath indexPathForRow:row inSection:endedSectionIndex];
                
                NSInteger endedCount = self.recentlyEndedMatches.count;
                
                if ( endedCount == 0 ) {
                    
                    [[self tableView] insertSections:[NSIndexSet indexSetWithIndex:endedSectionIndex] withRowAnimation:animation];
                    
                }
                
                [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:updatedIndexPath] withRowAnimation:animation];
            }
            
        }
        
        [[self tableView] endUpdates];
        
    }
    _isTableLocked= NO;
}


@end
