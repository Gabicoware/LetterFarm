//
//  LFTableViewController.h
//  LetterFarm
//
//  Created by Daniel Mueller on 10/8/12.
//
//

#import "LFViewController.h"

@interface LFTableViewController : LFViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UITableView* tableView;

@end

@interface LFTableViewController (Analytics)

-(void)trackDidSelectIndex:(NSIndexPath*)indexPath;

@end