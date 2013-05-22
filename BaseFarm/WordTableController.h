//
//  WordTableController.h
//  Letter Farm
//
//  Created by Daniel Mueller on 6/29/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WordTableController : NSObject<UITableViewDelegate, UITableViewDataSource>

-(void)reloadDataWithWords:(NSArray*)words;

@property (nonatomic) IBOutlet UITableView* tableView;

@end
