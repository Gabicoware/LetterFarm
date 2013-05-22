//
//  MatchesViewController.h
//  LetterFarm
//
//  Created by Daniel Mueller on 3/11/13.
//
//

#import "LFTableViewController.h"
#import "MatchListMediator.h"

@interface MatchesViewController : LFTableViewController

@property (nonatomic, weak) id<MatchListMediator> mediator;

@property (nonatomic) NSMutableArray* matches;

-(id)objectAtIndexPath:(NSIndexPath*)indexPath;

-(NSMutableArray*)objectsAtSection:(NSInteger)section;

- (UITableViewCell *)tableView:(UITableView *)tableView matchCellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSString *)tableView:(UITableView *)tableView verbForDeleteConfirmationDialogAtIndexPath:(NSIndexPath *)indexPath;

-(void)deleteMatchInfoAtIndexPath:(NSIndexPath*)indexPath;


@end
