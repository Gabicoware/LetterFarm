//
//  LFStoreViewController.m
//  LetterFarm
//
//  Created by Daniel Mueller on 9/24/12.
//
//

#import "LFStoreViewController.h"
#import "TableViewCellFactory.h"
#import "InAppPurchases.h"

enum _StoreRows{
#ifndef COLOR_WORD
    StoreRowsHints,
#endif
    StoreRowsRestorePurchases,
#ifdef ENABLE_RESET_PURCHASES
    StoreRowsResetPurchases,
#endif
    StoreRowsTotal
}StoreRows;

@interface LFStoreViewController()

@property (nonatomic, assign) BOOL isRestoring;
#ifndef COLOR_WORD
@property (nonatomic, assign) BOOL isPurchasingHints;
#endif
@property (nonatomic, assign) BOOL isPurchasingDisableAds;
@property (nonatomic, assign) BOOL isPurchasingUnlimitedGames;

@end

@implementation LFStoreViewController

@synthesize isRestoring=_isRestoring,
#ifndef COLOR_WORD
isPurchasingHints=_isPurchasingHints,
#endif
isPurchasingDisableAds=_isPurchasingDisableAds;
@synthesize isPurchasingUnlimitedGames=_isPurchasingUnlimitedGames;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppPurchaseUpdate:) name:InAppPurchasesDidLoadProductsNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppPurchaseUpdate:) name:InAppPurchasesDidUpdatePurchasesNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppPurchaseFail:) name:InAppPurchasesDidFailNotification object:nil];
    }
    return self;
}

-(void)handleAppPurchaseUpdate:(id)notification{
    [self.tableView reloadData];
}

-(void)handleAppPurchaseFail:(id)notification{
    NSString* identifier = [[notification userInfo] objectForKey:ProductIdentifierKey];
    
#ifndef COLOR_WORD
    if ([identifier isEqualToString:HintIdentifier]) {
        self.isPurchasingHints = NO;
    }
#endif
    if ([identifier isEqualToString:RestoreIdentifier]) {
        self.isRestoring = NO;
    }
    [self.tableView reloadData];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Upgrades for Sale:";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return StoreRowsTotal;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* CellIdentifier = @"UITableViewStoreCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [TableViewCellFactory newPurchasableTableViewCellWithReuseIdentifier:CellIdentifier];
    }
    
    NSString* text = @"";
    
    NSString* detailText = nil;
    
    BOOL hasPurchased = NO;
    BOOL isPurchasing = NO;
    BOOL isRestoring = NO;
    
    switch ([indexPath row]) {
#ifndef COLOR_WORD
        case StoreRowsHints:
            text = @"Single Player Hints";
            hasPurchased = [[InAppPurchases sharedInAppPurchases] hasPurchasedHints];
            isPurchasing = self.isPurchasingHints;
            break;
#endif
        case StoreRowsRestorePurchases:
            text = @"Restore Purchases";
            isRestoring = self.isRestoring;
            break;
#ifdef ENABLE_RESET_PURCHASES
        case StoreRowsResetPurchases :
            text = @"TESTING: Reset Purchases";
            break;
#endif
    }
    
    [[cell textLabel] setText:text];
    
    if (hasPurchased) {
        detailText = @"Purchased";
    }else if(isPurchasing){
        detailText = @"Purchasing...";
    }else if(isRestoring){
        detailText = @"Restoring...";
    }
    
    [[cell detailTextLabel] setText:detailText];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    InAppPurchases* p = [InAppPurchases sharedInAppPurchases];
    
    switch ([indexPath row]) {
#ifndef COLOR_WORD
        case StoreRowsHints:
            if (!self.isPurchasingHints && ![p hasPurchasedHints]) {
                [p purchaseHints];
                self.isPurchasingHints = YES;
            }
            break;
#endif
        case StoreRowsRestorePurchases:
            if (!self.isRestoring) {
                self.isRestoring = YES;
                [p restorePurchases];
            }
            break;
#ifdef ENABLE_RESET_PURCHASES
        case StoreRowsResetPurchases:
            [p reset];
            break;
#endif
    }
    
    [tableView beginUpdates];
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                     withRowAnimation:UITableViewRowAnimationNone];
    [tableView endUpdates];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        
    switch ([indexPath row]) {
#ifndef COLOR_WORD
        case StoreRowsHints:
            if (self.isPurchasingHints || [[InAppPurchases sharedInAppPurchases] hasPurchasedHints]) {
                indexPath = nil;
            }
            break;
#endif
        case StoreRowsRestorePurchases:
            if (self.isRestoring) {
                indexPath = nil;
            }
            break;
        default:
            break;
    }
        
    return indexPath;
}

@end