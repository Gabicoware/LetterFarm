//
//  PuPauseViewController.m
//  LetterFarm
//
//  Created by Daniel Mueller on 8/11/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "PuPauseViewController.h"
#import "PuGameViewController.h"
#import "LocalConfiguration.h"
#import "PuzzleGame.h"
#import "Puzzle.h"
#import "TableViewCellFactory.h"
#import "InAppPurchases.h"
#import "NSObject+Notifications.h"
#import "Analytics.h"
#import "NibNames.h"

typedef enum _PuPauseTableRow {
    PuPauseTableRowContinue,
    PuPauseTableRowRestart,
    PuPauseTableRowPass,
    PuPauseTableRowExit,
#ifndef COLOR_WORD
    PuPauseTableRowNeedsHintSolution,
    PuPauseTableRowHint,
    PuPauseTableRowSolution,
#endif
}PuPauseTableRow;

@interface PuPauseViewController ()

-(PuGameViewController*)puGameViewController;

@property (nonatomic, retain) NSArray* rows;

@property (nonatomic, assign) BOOL isPurchasingHints;

@end

@implementation PuPauseViewController

@synthesize matchInfo=_matchInfo;

@synthesize gameViewController=_gameViewController;

@synthesize rows=_rows;

@synthesize disableHints=_disableHints;

-(NSString*)title{
    return @"Pause";
}

-(NSString*)nibName{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return [NibNames tableView];
    }else{
        return [NibNames modalTableView];
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    NSDictionary* noteDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"handlePurchasesUpdateNotification:",InAppPurchasesDidUpdatePurchasesNotification,
                              @"handlePurchasesFailNotification:",InAppPurchasesDidFailNotification,
                              nil];
    
    [self observeNotifications:noteDict];
    
    [[self tableView] setBackgroundView:nil];
    [[self tableView] reloadData];
}

-(void)viewDidUnload{
    [self viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)handlePurchasesFailNotification:(NSNotification*)notification{
    self.isPurchasingHints = NO;
    [[self tableView] reloadData];
}

-(void)handlePurchasesUpdateNotification:(NSNotification*)notification{
    self.isPurchasingHints = NO;
    [[self tableView] reloadData];
}


-(PuGameViewController*)puGameViewController{
    return OBJECT_IF_OF_CLASS(self.gameViewController, PuGameViewController);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSMutableArray* mRows = [NSMutableArray array];
    
    [mRows addObject:[NSNumber numberWithInt:PuPauseTableRowContinue]];
    [mRows addObject:[NSNumber numberWithInt:PuPauseTableRowRestart]];
    
    if(self.canPass){
        [mRows addObject:[NSNumber numberWithInt:PuPauseTableRowPass]];
    }
    
    [mRows addObject:[NSNumber numberWithInt:PuPauseTableRowExit]];
    
#ifndef COLOR_WORD
    if (!self.disableHints) {
        if ([[InAppPurchases sharedInAppPurchases] hasPurchasedHints]) {
            //always show the hint
            [mRows addObject:[NSNumber numberWithInt:PuPauseTableRowHint]];
            [mRows addObject:[NSNumber numberWithInt:PuPauseTableRowSolution]];
        }else{
            [mRows addObject:[NSNumber numberWithInt:PuPauseTableRowNeedsHintSolution]];
        }
        
    }
#endif
    
    self.rows = [NSArray arrayWithArray:mRows];
    
    return self.rows.count;
    
}

-(PuPauseTableRow)rowAtPath:(NSIndexPath*)path{
    NSNumber* rowNumber = [self.rows objectAtIndex:[path row]];
    return [rowNumber integerValue];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PuPauseTableRow row = [self rowAtPath:indexPath];
    
    UITableViewCell *cell = nil;
    
#ifndef COLOR_WORD
    if (row == PuPauseTableRowNeedsHintSolution) {
        static NSString* PurchasableCellIdentifier = @"PurchasableTableViewCellIdentifier";
        
        cell = [tableView dequeueReusableCellWithIdentifier:PurchasableCellIdentifier];
        
        if (cell == nil) {
            cell = [TableViewCellFactory newPurchasableTableViewCellWithReuseIdentifier:PurchasableCellIdentifier];
        }
        
        [[cell textLabel] setText:@"Need A Hint?"];
        
        if ([[InAppPurchases sharedInAppPurchases] hasPurchasedHints]) {
            //always show the hint
            [[cell detailTextLabel] setText:@"Purchased"];
        }else if(self.isPurchasingHints){
            [[cell detailTextLabel] setText:@"Purchasing..."];
        }else{
            [[cell detailTextLabel] setText:nil];
        }

        
    }else
#endif
    {
        static NSString* CellIdentifier = @"UITableViewCellIdentifier";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [TableViewCellFactory newTableViewCellWithReuseIdentifier:CellIdentifier];
        }
        NSString* text = @"";
        
        switch (row) {
            case PuPauseTableRowContinue:
                text = @"Continue";
                break;
            case PuPauseTableRowRestart:
                text = @"Restart";
                break;
            case PuPauseTableRowExit:
                text = @"Exit";
                break;
            case PuPauseTableRowPass:
                text = @"Pass";
                break;
#ifndef COLOR_WORD
            case PuPauseTableRowNeedsHintSolution:
                text = @"Need A Hint?";
                break;
            case PuPauseTableRowHint:
                text = @"Hint";
                break;
            case PuPauseTableRowSolution:
                text = @"Solution";
                break;
#endif
            default:
                break;
        }
        
        [[cell textLabel] setText:text];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        
    PuPauseTableRow row = [self rowAtPath:indexPath];
    
    switch (row) {
        case PuPauseTableRowContinue:
            [[NSNotificationCenter defaultCenter] postNotificationName:ResumeNotification object:self];
            break;
        case PuPauseTableRowRestart:
            [[self puGameViewController] restartGame];
            [[NSNotificationCenter defaultCenter] postNotificationName:ResumeNotification object:self];
            break;
        case PuPauseTableRowExit:
            [[NSNotificationCenter defaultCenter] postNotificationName:ExitNotification object:self];
            break;
        case PuPauseTableRowPass:
            [[NSNotificationCenter defaultCenter] postNotificationName:PassNotification object:self];
            break;
#ifndef COLOR_WORD
        case PuPauseTableRowNeedsHintSolution:
            [self buyHintsAndSolutions];
            break;
        case PuPauseTableRowHint:
            [self showHint];
            break;
        case PuPauseTableRowSolution:
            [self showSolution];
            break;
#endif
            
        default:
            break;
    }
    
    [tableView beginUpdates];
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                     withRowAnimation:UITableViewRowAnimationNone];
    [tableView endUpdates];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


#ifndef COLOR_WORD
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PuPauseTableRow row = [self rowAtPath:indexPath];
    if (row == PuPauseTableRowNeedsHintSolution && (self.isPurchasingHints || [[InAppPurchases sharedInAppPurchases] hasPurchasedHints] ) ) {
        indexPath = nil;
    }
    return indexPath;
    
}

-(void)showSolution{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SolutionNotification object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:ResumeNotification object:self];
}

-(void)showHint{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HintNotification object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:ResumeNotification object:self];
}

-(void)buyHintsAndSolutions{
    
    self.isPurchasingHints = YES;
    [[InAppPurchases sharedInAppPurchases] purchaseHints];
}
#endif

-(NSString*)viewName{
    return @"Pause";
}

@end
