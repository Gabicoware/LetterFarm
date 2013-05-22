//
//  InAppPurchases.m
//  LetterFarm
//
//  Created by Daniel Mueller on 8/22/12.
//
//

#import "InAppPurchases.h"
#import "KeychainItemWrapper.h"
#import <Security/Security.h>
#import "LocalConfiguration.h"

#define Account @"LetterFarm"
#define Service @"InAppPurchases"

#ifdef ADHOC
#define TESTING_APPSTORE 1
#endif

#ifdef RELEASE
#undef TESTING_APPSTORE
#endif

#define InAppPurchasesService @"com.yourdomainhere.somegame.InAppPurchasesService"


#ifdef LETTER_WORD
NSString* HintIdentifier = @"hints";
#endif
#ifdef COLOR_WORD
NSString* HintIdentifier = @"herdhues_hints";
#endif

NSString* RestoreIdentifier = @"restorepurchases";

NSString* InAppPurchasesDidLoadProductsNotification = @"InAppPurchasesDidLoadProductsNotification";
NSString* InAppPurchasesDidUpdatePurchasesNotification = @"InAppPurchasesDidUpdatePurchasesNotification";
NSString* InAppPurchasesDidCompletePurchaseNotification = @"InAppPurchasesDidCompletePurchaseNotification";
NSString* InAppPurchasesDidFailNotification = @"InAppPurchasesDidFailNotification";

NSString* ProductIdentifierKey = @"ProductIdentifierKey";

NSString* DidRestorePurchasesKey = @"DidRestorePurchasesKey";
NSString* DidPurchaseHintsKey = @"DidPurchaseHintsKey";

@interface InAppPurchases ()

@property (nonatomic) KeychainItemWrapper* keychainItemWrapper;

@end

@implementation InAppPurchases

+ (id)sharedInAppPurchases
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

-(id)init{
    if((self = [super init])){
        
        NSString* uuid = [[LocalConfiguration sharedLocalConfiguration] appUUID];
        
        self.keychainItemWrapper = [[KeychainItemWrapper alloc] initWithService:InAppPurchasesService account:uuid accessGroup:nil];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

-(void)retrieveProducts{
#ifndef TESTING_APPSTORE
    NSSet* productIdentifiers = [NSSet setWithObjects:HintIdentifier, nil];
    SKProductsRequest* productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    [productsRequest setDelegate:(id)self];
    
    [productsRequest start];
#endif
}

-(void)restorePurchases{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

-(void)showStoreUnavailableAlert{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:@"The store is currently unavailable. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}

#ifdef ENABLE_RESET_PURCHASES
-(void)reset{
    [self.keychainItemWrapper resetKeychainItem];
    [[NSNotificationCenter defaultCenter] postNotificationName:InAppPurchasesDidUpdatePurchasesNotification object:self];
}
#endif

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    self.availableProducts = response.products;
}

-(NSString*)didPurchaseKeyForIdentifier:(NSString*)identifier{
    NSString* key = nil;
    if ([identifier isEqualToString:HintIdentifier]) {
        key = DidPurchaseHintsKey;
    }
    return key;
}

-(BOOL)canPurchaseProduct:(NSString*)identifier{
#ifdef TESTING_APPSTORE
    return YES;
#else
    return [self productWithIdentifier:identifier] != nil && [SKPaymentQueue canMakePayments];
#endif
}
-(BOOL)hasPurchasedProduct:(NSString*)identifier{
    NSString* key = [self didPurchaseKeyForIdentifier:identifier];
    return [self boolWithDidPurchaseKey:key];
}
-(void)purchaseProduct:(NSString*)identifier{
#ifdef TESTING_APPSTORE
    NSInteger tag = [self tagForIdentifier:identifier];
    [self showFreeUpgradeAlertWithTag:tag];
#else
    SKProduct* product = [self productWithIdentifier:identifier];
    if (product != nil && [SKPaymentQueue canMakePayments]) {
        SKPayment* payment = [SKPayment paymentWithProduct:[self productWithIdentifier:identifier]];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }else{
        [self showStoreUnavailableAlert];
        int64_t delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self didFailWithIdentifier:identifier];
        });
    }
#endif
}

#ifdef TESTING_APPSTORE

#define NOTIFY_HINTS 1
#define CONFIRM_HINTS 2

-(NSInteger)tagForIdentifier:(NSString*)identifier{
    NSInteger result = 0;
    if ([identifier isEqualToString:HintIdentifier]) {
        result = NOTIFY_HINTS;
    }
    return result;
}

-(void)showFreeUpgradeAlertWithTag:(NSInteger)tag{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Testing Purchases" message:@"Testers can unlock all upgrades for free." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
    [alertView setTag:tag];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
        switch ([alertView tag]) {
            case NOTIFY_HINTS:
            {
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Activate Hints and Solutions?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                [alertView show];
                [alertView setTag:CONFIRM_HINTS];
            }
                break;
            case CONFIRM_HINTS:
                if (buttonIndex == 1) {
                    [self didPurchaseProductWithIdentifier:HintIdentifier];
                }
                break;
        }
}

#endif

-(SKProduct*)productWithIdentifier:(NSString*)identifier{
    SKProduct* result= nil;
    
    for (SKProduct* product in self.availableProducts) {
        if ([[product productIdentifier] isEqualToString:identifier]) {
            result = product;
        }
    }
    
    return result;
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for (SKPaymentTransaction* transaction in transactions) {
        
        BOOL hasPurchased = transaction.transactionState == SKPaymentTransactionStatePurchased ;
        BOOL hasFailed = transaction.transactionState == SKPaymentTransactionStateFailed;
        
        NSString* identifier = [[transaction payment] productIdentifier];
        
        if (hasPurchased) {
            [self didPurchaseProductWithIdentifier:identifier];
            [queue finishTransaction:transaction];
        }else if(hasFailed){
            
            [self didFailWithIdentifier:identifier];
            [queue finishTransaction:transaction];
        }
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
    for (SKPaymentTransaction* transaction in [queue transactions]) {
        
        BOOL hasRestored = transaction.transactionState == SKPaymentTransactionStateRestored;
        
        if ( hasRestored ) {
            [self didPurchaseProductWithIdentifier:transaction.payment.productIdentifier];
            [queue finishTransaction:transaction];
        }
    }
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    [self didFailWithIdentifier:RestoreIdentifier];
}

-(void)didFailWithIdentifier:(NSString*)identifier{
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:identifier forKey:ProductIdentifierKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:InAppPurchasesDidFailNotification object:self userInfo:userInfo];
}

-(void)didPurchaseProductWithIdentifier:(NSString*)identifier{
    
    NSString* key = [self didPurchaseKeyForIdentifier:identifier];
    
    if(key != nil){
        [self setBool:YES withDidPurchaseKey:key];
        
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:identifier forKey:ProductIdentifierKey];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:InAppPurchasesDidCompletePurchaseNotification object:self userInfo:userInfo];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:InAppPurchasesDidUpdatePurchasesNotification object:self];
    }
}

#define KeychainYes @"YES"
#define KeychainNo @"NO"

-(BOOL)boolWithDidPurchaseKey:(NSString*)key{
    if (key != nil) {
        NSString* object = [[self purchasesDictionary] objectForKey:key];
        
        return object != nil && [object isEqualToString:KeychainYes];
    }else{
        return NO;
    }
}

-(void)setBool:(BOOL)value withDidPurchaseKey:(NSString*)key{
    
    if (key != nil) {
        NSMutableDictionary* purchasesDictionary = [[self purchasesDictionary] mutableCopy];
        
        NSString* object = value ? KeychainYes : KeychainNo;
        
        if (![object isEqualToString:[purchasesDictionary objectForKey:key]]) {
            [purchasesDictionary setObject:object forKey:key];
            
            [self setPurchasesDictionary:[NSDictionary dictionaryWithDictionary:purchasesDictionary]];
        }else{
#ifdef DEBUG
            NSLog(@"Attempting to set a bool that is already set");
#endif
        }
        
    }
}

-(NSDictionary*)purchasesDictionary{
    
    NSData* data = [self.keychainItemWrapper objectForKey:(__bridge id)kSecValueData];
    
    id object = nil;
    
    if (0 < [data length] ) {
        object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    if (object == nil) {
        object = [NSDictionary dictionary];
    }
    
    return OBJECT_IF_OF_CLASS(object, NSDictionary);
}

-(void)setPurchasesDictionary:(NSDictionary*)dictionary{
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    
    [[self keychainItemWrapper] setObject:data forKey:(__bridge id)kSecValueData];
}

@end

@implementation InAppPurchases (Products)

-(BOOL)canPurchaseHints{
    return [self canPurchaseProduct:HintIdentifier];
}

-(BOOL)hasPurchasedHints{
    return [self hasPurchasedProduct:HintIdentifier];
}

-(void)purchaseHints{
    [self purchaseProduct:HintIdentifier];
}

@end
