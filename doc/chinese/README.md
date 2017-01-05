## 摘要

这是 adjust™ 的iOS收入验证SDK。您可以访问[adjust.com]了解更多有关 adjust™ 的信息。

## 目录

* [基本集成](#basic-integration)
   * [获取SDK](#sdk-get)
   * [添加SDK至您的项目](#sdk-add)
   * [集成SDK至您的应用](#sdk-integrate)
      * [导入语句](#sdk-import)
      * [基本设置](#basic-setup)
      * [Adjust购买日志](#sdk-logging)
   * [收入验证](#verify-purchases)
      * [发出验证请求](#verification-request)
      * [处理验证响应](#verification-response)
   * [跟踪已验证收入](#track-purchases)
* [最佳实践](#best-practices)
* [许可协议](#license)

## <a id="basic-integration">基本集成

您必须 **首先为您的应用启用防作弊** ，以使用adjust收入验证SDK。您可以在我们的官方[防作弊指南][fraud-prevention]文档中找到相关说明。

以下是将adjust收入验证SDK集成至iOS项目的步骤。我们假定您将Xcode用于iOS开发。

如果您正在使用[Carthage][carthage], 您可以添加如下代码行至 `Cartfile` 并从[步骤 3](#step3)继续:

```ruby
github "adjust/ios_purchase_sdk"
```

您还可以通过将adjust收入验证SDK作为框架添加至您的项目来集成它。您可以在[发布专页][releases]找到四个归档文件：

* `AdjustPurchaseSdkStatic.framework.zip`
* `AdjustPurchaseSdkDynamic.framework.zip`

自iOS 8发布后, 苹果已经引入了动态框架（也称为嵌入式框架）。如果您的应用目标平台是iOS 8或者以上版本，您可以使用adjust收入验证SDK动态框架。您可以自由选择您想要使用的框架——静态或动态——将其添加至您的项目，然后继续[步骤 3](#step3)。

### <a id="sdk-get"></a>获取SDK

请从我们的[发布专页][releases]中下载最新版本，并将文档解压至您选择的文件夹中。

### <a id="sdk-add"></a>添加SDK至您的项目

在Xcode的项目导航（Project Navigator）中找到 `Supporting Files` 组 （或者您选择的其它任何组）。在Finder中，将 `AdjustPurchase` 子目录拖进Xcode的 `Supporting Files`组。

![][drag]

在 `Choose options for adding these files` （添加文件选项）对话框中，请确保您勾选了 `Copy items if needed` （必要时复制项目）并点选了 `Create groups` （创建组）。

![][add]

### <a id="sdk-integrate"></a>集成SDK至您的应用

#### <a id="sdk-import"></a>导入语句

如果您是从源文件添加的adjust SDK,请使用以下导入语句：

```objc
#import "AdjustPurchase.h"
```

如果您是作为框架或者通过Carthage添加adjust SDK, 请使用以下导入语句：

```objc
#import <AdjustPurchaseSdk/AdjustPurchase.h>
```

让我们从设置iOS收入验证SDK开始。

#### <a id="basic-setup"></a>基本设置

在项目导航（Project Navigator）中，打开应用委托(application delegate)的源文件，在文件顶部添加 `import` 语句，然后在应用委托的`didFinishLaunching` 或 `didFinishLaunchingWithOptions` 方法中添加如下调用至 `AdjustPurchase` :

```objc
#import "AdjustPurchase.h"
// or #import <AdjustPurchaseSdk/AdjustPurchase.h>

// ...

NSString *yourAppToken = @"{YourAppToken}";
NSString *environment = ADJPEnvironmentSandbox;

ADJPConfig *config = [[ADJPConfig alloc] initWithAppToken:yourAppToken andEnvironment:environment];
[AdjustPurchase init:config];
```
![][integration]

使用您的应用识别码替换 `{YourAppToken}` 。您可以在[控制面板]中找到该识别码。

鉴于您的应用是用于测试还是产品开发，您必须将 `environment` （环境模式）设为以下值之一：

```objc
NSString *environment = ADJPEnvironmentSandbox;
NSString *environment = ADJPEnvironmentProduction;
```

**重要:** 仅当您或其他人测试您的应用时，该值应设为 `ADJPEnvironmentSandbox` 。在您发布应用之前，请确保将环境改设为 `ADJPEnvironmentProduction` 。再次研发和测试时，请将其设回为 `ADJPEnvironmentSandbox` 。

我们按照设置的环境来区分真实流量和来自测试设备的测试流量，所以正确使用环境参数是非常重要的！

#### <a id="sdk-logging"></a>Adjust购买日志

您可以增加或减少在测试中看到的日志数量，方法是用以下参数之一来调用 `ADJPConfig` 实例上的 `setLogLevel` ：

```objc
[config setLogLevel:ADJPLogLevelVerbose]; // Enable all logging.
[config setLogLevel:ADJPLogLevelDebug];   // Enable more logging.
[config setLogLevel:ADJPLogLevelInfo];    // The default.
[config setLogLevel:ADJPLogLevelWarn];    // Disable info logging.
[config setLogLevel:ADJPLogLevelError];   // Disable warnings as well.
[config setLogLevel:ADJPLogLevelAssert];  // Disable errors as well.
```

### <a id="verify-purchases"></a>收入验证

#### <a id="verification-request"></a>发出验证请求

为了验证您的应用内购买，您需要调用 `AdjustPurchase` 实例上的 `verifyPurchase:forTransaction:productId:withResponseBlock`  方法。请确保仅当状态更改为 `SKPaymentTransactionStatePurchased` 后，在 `paymentQueue:updatedTransaction` 中 `finishTransaction` 之后调用该方法。

```objc
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing: {
                // Your stuff if any.
                break;
            }
            case SKPaymentTransactionStatePurchased: {
                // Your stuff if any.
                NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
                NSData *receipt = [NSData dataWithContentsOfURL:receiptURL];

                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];

                [AdjustPurchase verifyPurchase:receipt
                                forTransaction:transaction
                                productId:@"your_product_id"
                             withResponseBlock:^(ADJPVerificationInfo *info) {
                                 // Process ADJPVerificationInfo object...
                                 [self adjustVerificationUpdate:info];
                             }];

                break;
            }
            case SKPaymentTransactionStateFailed: {
                // Your stuff if any.
                break;
            }
            default:
                break;
        }
    }
}

// ...

- (void)adjustVerificationUpdate:(ADJPVerificationInfo *)info {
    // ...
}
```

您需要传递以下参数，以调用adjust收入验证SDK的方法来发出验证请求：

```objc
receipt         // App receipt of NSData type
transaction     // Finished transaction object of SKPaymentTransaction type
productId       // Your purchased product identifier of NSString type
responseBlock   // Callback method which will process the verification response
```

#### <a id="verification-response"></a>处理验证响应

如以上代码所述，您需要传递一个Block用于处理至 `verifyPurchase:forTransaction:productId:withResponseBlock` 方法的验证请求。

在以上例子中，我们设计了 `adjustVerificationUpdate` 方法，该方法在响应到达时将被调用。收入验证响应表示为 `ADJPVerificationInfo` ，并包含以下信息：

```objc
[info verificationState];   // State of purchase verification.
[info statusCode];          // Integer which displays backend response status code.
[info message];             // Message describing purchase verification state.
```

验证状态将为以下值之一：

```
ADJPVerificationStatePassed         - Purchase verification successful.
ADJPVerificationStateFailed         - Purchase verification failed.
ADJPVerificationStateUnknown        - Purchase verification state unknown.
ADJPVerificationStateNotVerified    - Purchase was not verified.
```

* 如果苹果服务器成功验证购买，将会报告 `ADJPVerificationStatePassed` 连带状态码 `200` 。
* 如果苹果服务器将购买视为无效，则会报告 `ADJPVerificationStateFailed` 连带状态码 `406` 。
* 如果苹果服务器并未对我们的收入验证请求给予回复，将会报告 `ADJPVerificationStateUnknown` 连带状态码 `204` 。此种情况意味着我们无法从苹果服务器中获取有关收入有效性的任何信息。这和购买本身并无联系，购买可能是有效或者无效的。报告此种状态的原因也有可能是发生了阻止我们报告收入验证正确状态的情况。您可以在 `ADJPVerificationInfo` 对象上的 `message` 字段中找到关于此故障的更多详细信息。
* 如果报告了 `ADJPVerificationStateNotVerified` ， 则表示使用了无效参数调用 `verifyPurchase:forTransaction:productId:withResponseBlock` 方法。

### <a id="track-purchases"></a>跟踪已验证收入

成功验证收入后，您可以使用我们的adjust SDK来跟踪收入并在您的控制面板中查看收入。您还可以通过传递在事件中创建的可选交易ID，来避免跟踪重复收入。系统将记住最近10个交易ID，并跳过带有重复交易ID的收入事件。

使用以上示例，您可以如下设置跟踪已验证收入：

```objc
#import "Adjust.h"
// or #import <AdjustSdk/Adjust.h>
#import "AdjustPurchase.h"
// or #import <AdjustPurchaseSdk/AdjustPurchase.h>

// ...

- (void)adjustVerificationUpdate:(ADJPVerificationInfo *)info {
    if ([info verificationState] == ADJPVerificationStatePassed) {
        ADJEvent *event = [[ADJEvent alloc] initWithEventToken:@"{YourEventToken}"];

        [event setRevenue:0.01 currency:@"EUR"];
        [event setTransactionId:@"{YourTransactionId}"];

        [Adjust trackEvent:event];
    }
}
```

## <a id="best-practices"></a>最佳实践

一旦报告 `ADJPVerificationStatePassed` 或者 `ADJPVerificationStateFailed` ，您可以信赖来自苹果服务器的反馈并由其决定是否跟踪您的购买收入。如果报告的是 `ADJPVerificationStateUnknown` ，您需要决定对此购买采取的下一步动作。

为了统计的需要，我们建议您在adjust控制面板中对每一个场景设置一个定义事件。这样便于您更好地了解您的收入中有多少被标记为已通过验证，多少被标记为未通过验证，以及多少是无法被验证并返回未知状态。如果需要的话，您还可以跟踪未经验证的收入。

您可以通过以下方法来处理响应：

```objc
- (void)adjustVerificationUpdate:(ADJPVerificationInfo *)info {
    if ([info verificationState] == ADJPVerificationStatePassed) {
        ADJEvent *event = [[ADJEvent alloc] initWithEventToken:@"{RevenueEventPassedToken}"];

        [event setRevenue:0.01 currency:@"EUR"];
        [event setTransactionId:@"{YourTransactionId}"];

        [Adjust trackEvent:event];
    } else if ([info verificationState] == ADJVerificationStateFailed) {
        ADJEvent *event = [[ADJEvent alloc] initWithEventToken:@"{RevenueEventFailedToken}"];
        [Adjust trackEvent:event];
    } else if ([info verificationState] == ADJPVerificationStateUnknown) {
        ADJEvent *event = [[ADJEvent alloc] initWithEventToken:@"{RevenueEventUnknownToken}"];
        [Adjust trackEvent:event];
    } else {
        ADJEvent *event = [[ADJEvent alloc] initWithEventToken:@"{RevenueEventNotVerifiedToken}"];
        [Adjust trackEvent:event];
    }
}
```
收入验证功能不是用来批准/拒绝已售货物的交付，而是用来比较报告交易数据和实际交易数据的一致性。

[dashboard]:        http://adjust.com
[adjust.com]:       http://adjust.com

[carthage]:         https://github.com/Carthage/Carthage
[releases]:         https://github.com/adjust/ios_purchase_sdk/releases
[cocoapods]:        http://cocoapods.org
[fraud-prevention]: https://docs.adjust.com/en/fraud-prevention/

[add]:              https://raw.github.com/adjust/sdks/master/Resources/ios_purchase/add.png
[drag]:             https://raw.github.com/adjust/sdks/master/Resources/ios_purchase/drag.png
[integration]:      https://raw.github.com/adjust/sdks/master/Resources/ios_purchase/integration.png

## <a id="license"></a>许可协议

The adjust purchase SDK is licensed under the MIT License.

Copyright (c) 2016 adjust GmbH,
http://www.adjust.com

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
