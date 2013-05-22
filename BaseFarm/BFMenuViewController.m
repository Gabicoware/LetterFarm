//
//  BFMenuViewController.m
//  Base Farm
//
//  Created by Daniel Mueller on 4/2/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "BFMenuViewController.h"
#import "TableViewCellFactory.h"
#import "PuzzleGame.h"
#import "Analytics.h"
#import "LocalConfiguration.h"
#import <QuartzCore/QuartzCore.h>

typedef enum _MenuSections{
    MenuSectionsGame,
    MenuSectionsStatic,
    MenuSectionsTotal
    
}MenuSections;

typedef enum _StaticRow{
    StaticRowSinglePlayer,
    StaticRowMultiPlayer,
    StaticRowMore,
}StaticRow;

typedef enum _GameRow{
#ifndef COLOR_WORD
    GameRowColorFarm,
#endif
#ifndef LETTER_WORD
    GameRowLetterFarm,
#endif
    GameRowTotal
}GameRow;

NSString* MenuSinglePlayer = @"LFMenuViewControllerSinglePlayer";
NSString* MenuMultiPlayer = @"LFMenuViewControllerMultiPlayer";
NSString* MenuMore = @"LFMenuViewControllerMore";
NSString* MenuDidAppear = @"LFMenuDidAppear";

@interface BFMenuViewController()

@property (nonatomic) NSArray* rows;

-(StaticRow)staticRowWithPath:(NSIndexPath*)indexPath;

@property (nonatomic) IBOutlet UIView* logoView;

@end

@implementation BFMenuViewController

@synthesize rows=_rows;

@synthesize logoView=_logoView;

@synthesize tableView=_tableView;

-(void)updateLogoView{
    for (UIView* subview in self.logoView.subviews) {
        TileView* tileView = OBJECT_IF_OF_CLASS(subview, TileView);
        [tileView setTileImageProvider:nil];
    }
}

-(StaticRow)staticRowWithPath:(NSIndexPath*)indexPath{
    NSNumber* number = [self.rows objectAtIndex:[indexPath row]];
    return [number intValue];
}

-(NSString*)title{
    return @"Main Menu";
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:MenuDidAppear object:nil];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        [self.tableView setBackgroundView:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMenuNotification:)
                                                 name:MenuNotification
                                               object:nil];
    self.tableView.alpha = 0.0;

#ifndef FREEZE_START_SCREEN
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.tableView.alpha = 1.0;
                     }];
#endif
}

-(void)handleMenuNotification:(id)notification{
    [[self tableView] reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return MenuSectionsTotal;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    switch (section) {
        case MenuSectionsStatic:{
            NSMutableArray* mutableRows = [NSMutableArray array];
            [mutableRows addObject:[NSNumber numberWithInt:StaticRowSinglePlayer]];
            [mutableRows addObject:[NSNumber numberWithInt:StaticRowMultiPlayer]];
            [mutableRows addObject:[NSNumber numberWithInt:StaticRowMore]];
            self.rows = [NSArray arrayWithArray:mutableRows];
            return self.rows.count;
        }
            break;
            
        case MenuSectionsGame:{
            return GameRowTotal;
        }
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    
    static NSString* CellIdentifier = @"MenuTableViewCell";
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    
    if (indexPath.section == MenuSectionsStatic) {
        cell.detailTextLabel.text = nil;
        cell.imageView.image = nil;
        StaticRow row = [self staticRowWithPath:indexPath];
        
        switch (row) {
            case StaticRowSinglePlayer:
                [[cell textLabel] setText:@"Single Player"];
                break;
            case StaticRowMultiPlayer:
                [[cell textLabel] setText:@"Multiplayer"];
                break;
            case StaticRowMore:
                [[cell textLabel] setText:@"More"];
                break;
        }
    }else if(indexPath.section == MenuSectionsGame){
        cell.detailTextLabel.text = @"Also available on iTunes";
        switch (indexPath.row) {
#ifndef COLOR_WORD
            case GameRowColorFarm:
                cell.textLabel.text = @"Herd the Hues";
                cell.imageView.image = [UIImage imageNamed:@"colorfarm.png"];
                break;
#endif
#ifndef LETTER_WORD
            case GameRowLetterFarm:
                cell.textLabel.text = @"Herd the Words";
                cell.imageView.image = [UIImage imageNamed:@"letterfarm.png"];
                break;
#endif
            default:
                break;
        }
        cell.imageView.layer.masksToBounds = YES;
        cell.imageView.layer.cornerRadius = 10.0;
    }

    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == MenuSectionsStatic) {
        
        NSString* notificationName = nil;
        StaticRow row = [self staticRowWithPath:indexPath];
        
        switch (row) {
            case StaticRowSinglePlayer:
                notificationName = MenuSinglePlayer;
                [self trackEvent:@"Single Player"];
                break;
            case StaticRowMultiPlayer:
                notificationName = MenuMultiPlayer;
                [self trackEvent:@"Multi Player"];
                break;
            case StaticRowMore:
                notificationName = MenuMore;
                [self trackEvent:@"More"];
                break;
        }
        if (notificationName != nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                                object:self];
        }
    }else if (indexPath.section == MenuSectionsGame) {
        
        NSString* urlString = nil;
        
        switch (indexPath.row) {
#ifndef COLOR_WORD
            case GameRowColorFarm:
                urlString = @"https://itunes.apple.com/us/app/herd-the-hues/id640920002?mt=8&uo=4";
                break;
#endif
#ifndef LETTER_WORD
            case GameRowLetterFarm:
                urlString = @"https://itunes.apple.com/us/app/herd-the-words/id545019650?mt=8&uo=4";
                break;
#endif
            default:
                break;
        }
        
        if (urlString != nil) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        }
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(NSString*)categoryName{
    return @"Main Menu";
}

@end
