//
//  IAPHelper.h
//  CastleRider
//
//  Created by zero.liu on 5/7/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);
extern NSString *const IAPHelperProductPurchasedNotification;

@interface IAPHelper : NSObject

- (id) initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void) requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void) buyProduct:(SKProduct *)product;
- (BOOL) productPurchased:(NSString *)productIdentifier;
@end
