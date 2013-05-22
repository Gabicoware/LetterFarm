//
//  FBFriendsViewController.m
//  LetterFarm
//
//  Created by Daniel Mueller on 12/20/12.
//
//

#import "FBFriendsViewController.h"
#import "Facebook.h"
#import "FBGraphObject.h"

NSString* FBFriendsViewDidSelectNotification = @"FBFriendsViewDidSelectNotification";
NSString* FBFriendsViewDidCancelNotification = @"FBFriendsViewDidCancelNotification";


@interface FBFriendsViewController ()

@property (nonatomic) IBOutlet UITableView* tableView;
@property (nonatomic) IBOutlet UISearchBar* searchBar;

@property (nonatomic) NSArray* filteredFriends;

-(IBAction)didTapCancelButton:(id)sender;

@end

@implementation FBFriendsViewController

@synthesize friends=_friends, tableView=_tableView;

-(void)setFriends:(NSArray *)friends{
    _friends = friends;
    
    [self reloadData];
    
}

-(void)reloadData{
    
    NSMutableArray* mFriends = [NSMutableArray array];
    
    NSString* filterText = [[self.searchBar.text lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([filterText isEqualToString:@""]) {
        filterText = nil;
    }
    
    for (FBGraphObject* friend in self.friends) {
        
        NSString* name = [friend objectForKey:@"name"];
        
        BOOL hasFilter = filterText == nil || [[name lowercaseString] rangeOfString:filterText].location != NSNotFound;
        
        if (hasFilter) {
            [mFriends addObject:friend];
        }
    
    }
    
    [mFriends sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        id<FBGraphUser> friend1 = OBJECT_IF_OF_PROTOCOL(obj1, FBGraphUser);
        id<FBGraphUser> friend2 = OBJECT_IF_OF_PROTOCOL(obj2, FBGraphUser);
        if (friend1.name != nil && friend2 != nil) {
            return [friend1.name compare:friend2.name];
        }else{
            return 0;
        }
    }];
    
    self.filteredFriends = [NSArray arrayWithArray:mFriends];
    [self.tableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.filteredFriends != nil ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.filteredFriends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    
    static NSString* CellIdentifier = @"FBFriendsTableViewCell";
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    
    id<FBGraphUser> friend = [[self filteredFriends] objectAtIndex:[indexPath row]];
    
    [[cell textLabel] setText:friend.name];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    id<FBGraphUser> friend = [[self filteredFriends] objectAtIndex:[indexPath row]];
    
    if (friend != nil) {
        self.selectedFriend = friend;
        [[NSNotificationCenter defaultCenter] postNotificationName:FBFriendsViewDidSelectNotification
                                                            object:self];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self reloadData];
}

-(IBAction)didTapCancelButton:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:FBFriendsViewDidCancelNotification
                                                        object:self];
}

@end
