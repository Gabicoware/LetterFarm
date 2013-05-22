//
//  BFMenuViewController.h
//  Base Farm
//
//  Created by Daniel Mueller on 4/2/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "LFTableViewController.h"

#import "BaseFarm.h"

extern NSString* MenuMore;
extern NSString* MenuSinglePlayer;
extern NSString* MenuMultiPlayer;
extern NSString* MenuCompleteMutliplayer;
extern NSString* MenuDidAppear;


@interface BFMenuViewController : LFTableViewController

-(void)updateLogoView;

@end
