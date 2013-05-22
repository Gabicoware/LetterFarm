//
//  InAppPurchases.h
//  LetterFarm
//
//  Created by Daniel Mueller on 8/22/12.
//
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

extern NSString* HintIdentifier;
extern NSString* RestoreIdentifier;

extern NSString* InAppPurchasesDidLoadProductsNotification;
extern NSString* InAppPurchasesDidUpdatePurchasesNotification;
extern NSString* InAppPurchasesDidCompletePurchaseNotification;
extern NSString* InAppPurchasesDidFailNotification;

extern NSString* ProductIdentifierKey;
extern NSString* DidRestorePurchasesKey;
extern NSString* DidPurchaseHintsKey;

@interface InAppPurchases : NSObject<SKProductsRequestDelegate,SKPaymentTransactionObserver>

+ (id)sharedInAppPurchases;

@property (nonatomic) NSArray* availableProducts;

-(BOOL)canPurchaseProduct:(NSString*)identifier;
-(BOOL)hasPurchasedProduct:(NSString*)identifier;
-(void)purchaseProduct:(NSString*)identifier;

-(void)retrieveProducts;

-(void)restorePurchases;

#ifdef ENABLE_RESET_PURCHASES

-(void)reset;

#endif

@end

@interface InAppPurchases (Products)

-(BOOL)canPurchaseHints;
-(BOOL)hasPurchasedHints;
-(void)purchaseHints;

@end