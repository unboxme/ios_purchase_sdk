//
//  ADJPConfig.m
//  AdjustPurchase
//
//  Created by Uglješa Erceg on 07/12/15.
//  Copyright © 2015 adjust GmbH. All rights reserved.
//

#import "ADJPConfig.h"
#import "ADJPLogger.h"

static const NSUInteger kAppTokenLength = 12;

@implementation ADJPConfig

#pragma mark - Object lifecycle

- (id)initWithAppToken:(NSString *)appToken
        andEnvironment:(NSString *)environment {
    self = [super init];

    if (!self) {
        return self;
    }

    _appToken = appToken;
    _environment = environment;
    self.logLevel = ADJPLogLevelInfo;

    return self;
}

#pragma mark - Public methods

- (BOOL)isValid:(NSString *)errorMessage {
    NSString *message;

    if (self.appToken == nil) {
        message = @"Invalid app token";
        [ADJPLogger error:message];

        if (errorMessage != nil) {
            errorMessage = message;
        }

        return NO;
    }

    if ([self.appToken length] != kAppTokenLength) {
        message = @"Invalid app token";
        [ADJPLogger error:message];

        if (errorMessage != nil) {
            errorMessage = message;
        }

        return NO;
    }

    if (self.environment == nil) {
        message = @"Invalid environment";
        [ADJPLogger error:message];

        if (errorMessage != nil) {
            errorMessage = message;
        }

        return NO;
    }

    if ([self.environment isEqualToString:ADJPEnvironmentSandbox] == NO &&
        [self.environment isEqualToString:ADJPEnvironmentProduction] == NO) {
        message = @"Invalid environment";
        [ADJPLogger error:message];

        if (errorMessage != nil) {
            errorMessage = message;
        }
        
        return NO;
    }
    
    return YES;
}

@end
