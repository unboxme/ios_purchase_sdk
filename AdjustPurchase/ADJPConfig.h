//
//  ADJPConfig.h
//  AdjustPurchase
//
//  Created by Uglješa Erceg on 07/12/15.
//  Copyright © 2015 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPCommon.h"

@interface ADJPConfig : NSObject

/**
 *  @property   appToken
 *
 *  @brief      The App Token of your app. This unique identifier can
 *              be found it in your dashboard at http://adjust.com and should always
 *              be 12 characters long.
 */
@property (nonatomic, readonly) NSString *appToken;

/**
 *  @property   environment
 *
 *  @brief      The current environment your app. We use this environment to
 *              distinguish between real traffic and artificial traffic from test devices.
 *              It is very important that you keep this value meaningful at all times!
 *              Especially if you are tracking revenue.
 *              For more info, please check ADJPCommon.h file.
 */
@property (nonatomic, readonly) NSString *environment;

/**
 *  @property   logLevel
 *
 *  @brief      The desired minimum log level (default: info)
 *              Must be one of the following:
 *              - ADJPLogLevelVerbose   (enable all logging)
 *              - ADJPLogLevelDebug     (enable more logging)
 *              - ADJPLogLevelInfo      (the default)
 *              - ADJPLogLevelWarn      (disable info logging)
 *              - ADJPLogLevelError     (disable warnings as well)
 *              - ADJPLogLevelAssert    (disable errors as well)
 *              - ADJPLogLevelNone      (disable all logs)
 */
@property (nonatomic, assign) ADJPLogLevel logLevel;

/**
 *  @brief  Method used for ADJPConfig object initialization.
 *
 *  @param  appToken    The App Token of your app. This unique identifier can
 *                      be found it in your dashboard at http://adjust.com and should 
 *                      always be 12 characters long.
 *  @param  environment The current environment your app.
 *                      For more info, please check ADJPCommon.h file.
 *
 */
- (id)initWithAppToken:(NSString *)appToken
        andEnvironment:(NSString *)environment;

/**
 *  @brief  Method used to check if ADJPConfig object is valid.
 *
 *  @param  String variable where error message will be written.
 *
 *  @return Boolean indicating wether ADJPConfig is valid or not.
 */
- (BOOL)isValid:(NSString *)errorMessage;

@end
