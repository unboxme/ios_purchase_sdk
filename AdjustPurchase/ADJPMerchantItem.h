//
//  ADJPMerchantItem.h
//  AdjustPurchase
//
//  Created by Uglješa Erceg on 05/11/15.
//  Copyright © 2015 adjust GmbH. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import <Foundation/Foundation.h>

#import "ADJPCommon.h"

@interface ADJPMerchantItem : NSObject

@property (nonatomic, readonly) NSData *receipt;
@property (nonatomic, readonly) SKPaymentTransaction *transaction;
@property (nonatomic, readonly) ADJPVerificationAnswerBlock responseBlock;

- (id)initWithReceipt:(NSData *)receipt
          transaction:(SKPaymentTransaction *)transaction
     andResponseBlock:(ADJPVerificationAnswerBlock)responseBlock;

- (BOOL)isValid:(NSString *)errorMessage;

@end
