//
//  ADJPMerchantItem.m
//  AdjustPurchase
//
//  Created by Uglješa Erceg on 05/11/15.
//  Copyright © 2015 adjust GmbH. All rights reserved.
//

#import "ADJPLogger.h"
#import "ADJPMerchantItem.h"

#pragma mark - Implementation

@implementation ADJPMerchantItem

#pragma mark - Object lifecycle

- (id)initWithReceipt:(NSData *)receipt
          transaction:(SKPaymentTransaction *)transaction
     andResponseBlock:(ADJPVerificationAnswerBlock)responseBlock {
    self = [super init];

    if (!self) {
        return self;
    }

    _receipt = receipt;
    _transaction = transaction;
    _responseBlock = responseBlock;

    return self;
}

#pragma mark - Public methods

- (BOOL)isValid:(NSString *)errorMessage {
    NSString *message;

    if (self.receipt == nil) {
        message = @"Invalid receipt";
        [ADJPLogger error:message];

        if (errorMessage != nil) {
            errorMessage = message;
        }

        return NO;
    }

    if (self.transaction == nil) {
        message = @"Invalid transaction";
        [ADJPLogger error:message];

        if (errorMessage != nil) {
            errorMessage = message;
        }

        return NO;
    }

    // No need to check responseBlock, was already checked.
    
    return YES;
}

@end
