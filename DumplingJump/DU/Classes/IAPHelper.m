//
//  IAPHelper.m
//  CastleRider
//
//  Created by zero.liu on 5/7/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import "IAPHelper.h"
#import "UserData.h"
#import "Constants.h"



NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";

@interface IAPHelper() <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@end

@implementation IAPHelper
{
    SKProductsRequest *_productsRequest;
    RequestProductsCompletionHandler _completionHandler;
    NSSet *_productIdentifiers;
    NSMutableSet *_purchasedProductIdentifiers;
}

- (void)dealloc
{
    [_productsRequest release];
    _productsRequest = nil;
    
    [_completionHandler release];
    _completionHandler = nil;
    
    [_productIdentifiers release];
    _productIdentifiers = nil;
    
    [_purchasedProductIdentifiers release];
    _purchasedProductIdentifiers = nil;
    
    [super dealloc];
}

- (id) initWithProductIdentifiers:(NSSet *)productIdentifiers
{
    if (self = [super init])
    {
        //Store product identifiers
        _productIdentifiers = [productIdentifiers retain];
        
        _purchasedProductIdentifiers = [[NSMutableSet alloc] init];
        for (NSString *productIdentifier in _productIdentifiers)
        {
            BOOL productPurchased = [[USERDATA objectForKey:productIdentifiers] boolValue];
            if (productPurchased)
            {
                [_purchasedProductIdentifiers addObject:productIdentifiers];
                NSLog(@"Previously purchased: %@", productIdentifier);
            }
            else
            {
                NSLog(@"Not purchased: %@", productIdentifier);
            }
        }
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    
    return self;
}

- (void) requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler
{
    _completionHandler = [completionHandler copy];
    
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
}

- (void) buyProduct:(SKProduct *)product
{
    NSLog(@"Buying %@...", product.productIdentifier);
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (BOOL) productPurchased:(NSString *)productIdentifier
{
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

#pragma mark - SKProductsRequestDelegate
- (void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"Loaded list of products...");
    [_productsRequest release];
    _productsRequest = nil;
    
    NSArray *skProducts = response.products;
    for (SKProduct *skProduct in skProducts)
    {
        NSLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
    
    _completionHandler(YES, skProducts);
    [_completionHandler release];
    _completionHandler = nil;
}

- (void) request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Failed to load list of products");
    [_productsRequest release];
    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    [_completionHandler release];
    _completionHandler = nil;
}

#pragma mark - SKPaymentTransactionObserver

- (void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void) completeTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"completeTransaction...");
    
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void) restoreTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"restoreTransaction...");
    
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void) failedTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) provideContentForProductIdentifier:(NSString *)productIdentifier
{    
    [_purchasedProductIdentifiers addObject:productIdentifier];
    [USERDATA setObject: [NSNumber numberWithBool:YES] forKey:productIdentifier];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
}
@end
