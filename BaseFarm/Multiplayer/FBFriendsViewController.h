//
//  FBFriendsViewController.h
//  LetterFarm
//
//  Created by Daniel Mueller on 12/20/12.
//
//

#import <UIKit/UIKit.h>
#import "FBGraphUser.h"

extern NSString* FBFriendsViewDidSelectNotification;
extern NSString* FBFriendsViewDidCancelNotification;

@interface FBFriendsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

@property (nonatomic) NSArray* friends;

@property (nonatomic) id<FBGraphUser> selectedFriend;

@end
