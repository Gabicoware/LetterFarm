//
//  MatchesViewController.m
//  LetterFarm
//
//  Created by Daniel Mueller on 3/11/13.
//
//

#import "MatchesViewController.h"
#import "TableViewCellFactory.h"
#import "MatchInfo+Strings.h"

@interface MatchesViewController ()

@property (nonatomic) NSIndexPath* pendingIndexPath;

@end

@implementation MatchesViewController

@synthesize matches=_matches;

-(id)objectAtIndexPath:(NSIndexPath*)indexPath{
    
    NSArray* objects = [self objectsAtSection:[indexPath section]];
    
    id object = [objects objectAtIndex:[indexPath row]];
    
    return object;
    
}

-(NSMutableArray*)objectsAtSection:(NSInteger)section{
    return self.matches;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(void)setMatches:(NSMutableArray *)matches{
    _matches = matches;
    
    [self.tableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.matches count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self tableView:tableView matchCellForRowAtIndexPath:indexPath];
}


- (UITableViewCell *)tableView:(UITableView *)tableView matchCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    
    static NSString* GameCellIdentifier = @"MatchCell";
    cell = [tableView dequeueReusableCellWithIdentifier:GameCellIdentifier];
    if (cell == nil) {
        cell = [TableViewCellFactory newMatchTableViewCellWithReuseIdentifier:GameCellIdentifier];
        
    }
    
    id object = [self objectAtIndexPath:indexPath];
    
    MatchInfo* match = OBJECT_IF_OF_CLASS(object, MatchInfo);
    if (match != nil) {
        
        NSString* tileLetter = [match tileViewLetter];
        [[cell tileView] setLetter:tileLetter];
        [[cell tileView] setNeedsLayout];
        
        NSString* imageName = nil;
        
        switch(match.opponentType){
            case OpponentTypeNone:
                break;
#ifndef DISABLE_LOCAL
            case OpponentTypeComputer:
                imageName =@"iphone_icon.png";
                break;
            case OpponentTypePassNPlay:
                imageName =@"passnplay_icon.png";
                break;
#endif
#ifndef DISABLE_GK
            case OpponentTypeGK:
                imageName =@"game_center_icon.png";
                break;
#endif
#ifndef DISABLE_FB
            case OpponentTypeFB:
                imageName =@"facebook_icon.png";
                break;
#endif
#ifndef DISABLE_EMAIL
            case OpponentTypeEmail:
                imageName =@"email_icon.png";
                break;
#endif
        }
        
        if (imageName == nil) {
            [[cell serviceImageView] setImage:nil];
            [[cell serviceImageView] setHidden:YES];
        }else{
            [[cell serviceImageView] setImage:[UIImage imageNamed:imageName]];
            [[cell serviceImageView] setHidden:NO];
        }
        
        
        [[cell textLabel] setText:[match mainString]];
        [[cell detailTextLabel] setText:[match detailString]];
        
        if (![match hasData]) {
            
            [[self mediator] loadDataForMatch:match withCompletionHandler:^(BOOL completed){
                NSIndexPath* verifyPath = [[self tableView] indexPathForCell:cell];
                
                if ([verifyPath isEqual:indexPath]) {
                    
                    NSString* tileLetter = [match tileViewLetter];
                    [[cell tileView] setLetter:tileLetter];
                    [[cell tileView] setNeedsLayout];
                    
                    [[cell textLabel] setText:[match mainString]];
                    [[cell detailTextLabel] setText:[match detailString]];
                }
            } ];
            
        }
        
        
        
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 54.0;;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return @"Delete";
    
}

- (NSString *)tableView:(UITableView *)tableView verbForDeleteConfirmationDialogAtIndexPath:(NSIndexPath *)indexPath{
    
    return @"delete";
    
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        
        id object = [self objectAtIndexPath:indexPath];
        
        if (object != nil) {
            
            self.pendingIndexPath = indexPath;
            
            NSString* verb = [self tableView:tableView verbForDeleteConfirmationDialogAtIndexPath:indexPath];
            
            NSString* message = [NSString stringWithFormat:@"Are you sure you want to %@ this game?",verb];
            
            
            
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Confirm"
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:@"No"
                                                      otherButtonTitles:@"Yes", nil];
            
            [alertView show];
            
            
        }
        
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    NSIndexPath* indexPath = self.pendingIndexPath;
    self.pendingIndexPath = nil;
    
    if (buttonIndex == 1) {
        [self deleteMatchInfoAtIndexPath:indexPath];
    }
    
}

-(void)deleteMatchInfoAtIndexPath:(NSIndexPath*)indexPath{
    
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
        
        if ( matchesCount == 1 ) {
            [[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:UITableViewRowAnimationTop];
        }else{
            [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:animation];
        }
        
        [[self mediator] deleteMatch:match];
        
        [[self tableView] endUpdates];
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        
    [[NSNotificationCenter defaultCenter] postNotificationName:SelectMatchCompleteMutliplayer
                                                        object:self
                                                      userInfo:[self objectAtIndexPath:indexPath]];
        
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
