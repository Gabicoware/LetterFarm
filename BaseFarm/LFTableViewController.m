//
//  LFTableViewController.m
//  LetterFarm
//
//  Created by Daniel Mueller on 10/8/12.
//
//

#import "LFTableViewController.h"

@interface LFTableViewController ()

@end

@implementation LFTableViewController

@synthesize tableView=_tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[self tableView] setBackgroundView:nil];
    [[self tableView] reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}


@end

@implementation LFTableViewController (Analytics)

-(NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self trackDidSelectIndex:indexPath];
    return indexPath;
}

-(void)trackDidSelectIndex:(NSIndexPath*)indexPath{
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSString* eventName = [[cell textLabel] text];
    if ( eventName != nil ) {
        [self trackEvent:eventName];
    }
}

@end