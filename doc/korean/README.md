## 요약

이 문서는 adjust™의 iOS 구매 SDK를 설명하는 요약 정보입니다. adjust™에 대한 자세한 내용은 [adjust.com]에서 확인할 수 있습니다.

## 차례

* [기본 연동](#basic-integration)
   * [SDK 다운로드](#sdk-get)
   * [프로젝트에 SDK 추가](#sdk-add)
   * [SDK를 앱에 연동](#sdk-integrate)
      * [가져오기 명령문](#sdk-import)
      * [기본 설정](#basic-setup)
      * [결제 로그 조절](#sdk-logging)
   * [결제 검증](#verify-purchases)
      * [검증 요청](#verification-request)
      * [검증 응답 처리](#verification-response)
   * [검증된 결제 추적](#track-purchases)
* [모범 사례](#best-practices)
* [라이선스](#license)

## <a id="basic-integration">기본 연동

adjust 구매 SDK를 사용하려면 앱에 대해 **먼저 사기 예방 기능을 활성화**해야 합니다. 자세한 방법은 저희의 공식 문서인 [사기 예방 가이드][fraud-prevention]에서 확인할 수 있습니다.

여기에서는 adjust 구매 SDK를 iOS 프로젝트에 연동하기 위한 기본 절차만 설명합니다. 모든 설명은 Xcode를 사용하여 iOS 앱을 개발하고 있다는 가정을 바탕으로 합니다.

[Carthage][carthage]를 사용 중이라면 다음 줄을 `Cartfile`에 추가하고 [3단계](#step3)를 진행하세요.

```ruby
github "adjust/ios_purchase_sdk"
```

또는 adjust 구매 SDK를 프로젝트에 프레임워크로 추가하여 구매 SDK를 연동할 수도 있습니다. [릴리스 페이지][releases]에서 다음 네 개의 압축 파일을 찾을 수 있습니다.

* `AdjustPurchaseSdkStatic.framework.zip`
* `AdjustPurchaseSdkDynamic.framework.zip`

iOS 8 출시 이후 Apple은 동적 프레임워크(또는 임베디드 프레임워크)를 도입했습니다. 앱이 iOS 8 이상의 기기를 대상으로 한다면 adjust 구매 SDK 동적 프레임워크를 사용할 수 있습니다. 정적 프레임워크와 동적 프레임워크 중에서 선택하여 프로젝트에 추가한 후 [3단계](#step3)를 진행하세요.

### <a id="sdk-get"></a>SDK 다운로드

저희의 [릴리스 페이지][releases]에서 최신 버전을 다운로드하세요. 원하는 디렉터리에 압축 파일을 푸세요.

### <a id="sdk-add"></a>프로젝트에 SDK 추가

Xcode의 Project Navigator에서 `Supporting Files` 그룹 또는 원하는 다른 그룹을 찾으세요. Finder에서 `AdjustPurchase` 하위 디렉터리를 Xcode의 `Supporting Files` 그룹에 끌어다 놓으세요.

![][drag]

`Choose options for adding these files` 대화상자에서 `Copy items if needed` 확인란을 선택하고 `Create groups` 라디오 버튼을 선택하세요.

![][add]

### <a id="sdk-integrate"></a>SDK를 앱에 연동

#### <a id="sdk-import"></a>가져오기 명령문

소스에서 adjust SDK를 추가했다면 다음의 가져오기 명령문을 사용해야 합니다.

```objc
#import "AdjustPurchase.h"
```

adjust SDK를 프레임워크로 추가했거나 Carthage를 통해 추가했다면 다음의 가져오기 명령문을 사용해야 합니다.

```objc
#import <AdjustPurchaseSdk/AdjustPurchase.h>
```

먼저 iOS 구매 SDK를 설정해보겠습니다.

#### <a id="basic-setup"></a>기본 설정

Project Navigator에서 애플리케이션 델리게이트의 소스 파일을 여세요. 파일 상단에 `import` 명령문을 추가하고, 앱 델리게이트의 `didFinishLaunching` 또는 `didFinishLaunchingWithOptions` 메서드에서 `AdjustPurchase`에 다음 콜을 추가하세요.

```objc
#import "AdjustPurchase.h"
// 또는 #import <AdjustPurchaseSdk/AdjustPurchase.h>

// ...

NSString *yourAppToken = @"{YourAppToken}";
NSString *environment = ADJPEnvironmentSandbox;

ADJPConfig *config = [[ADJPConfig alloc] initWithAppToken:yourAppToken andEnvironment:environment];
[AdjustPurchase init:config];
```
![][integration]

`{YourAppToken}`을 앱 토큰으로 교체하세요. 앱 토큰은 [대시보드]에서 찾을 수 있습니다.

앱을 테스트용으로 제작하는지 출시 목적으로 제작하는지에 따라 다음 값 중 하나로 `environment`를 설정해야 합니다.

```objc
NSString *environment = ADJPEnvironmentSandbox;
NSString *environment = ADJPEnvironmentProduction;
```

**중요:** 앱을 테스트할 때에만 이 값을 `ADJPEnvironmentSandbox`로 설정해야 합니다. 앱을 출시할 때에는 반드시 이 값을 `ADJPEnvironmentProduction`으로 설정해야 합니다. 앱을 개발 중이거나 테스트할 때에는 이 값을 다시 `ADJPEnvironmentSandbox`로 설정하세요.

저희는 이 환경 값을 사용하여 테스트 기기로부터 전달되는 실제 트래픽과 테스트 트래픽을 구분합니다. 항상 이 값을 목적에 맞게 설정하는 것이 중요합니다!

#### <a id="sdk-logging"></a>결제 로그 조절

`ADJPConfig` 인스턴스에서 다음 매개변수 중 하나와 함께 `setLogLevel:`을 호출하여 테스트에서 표시되는 로그의 양을 늘리거나 줄일 수 있습니다.

```objc
[config setLogLevel:ADJPLogLevelVerbose]; // 모든 로그를 활성화합니다.
[config setLogLevel:ADJPLogLevelDebug];   // 더 많은 로그를 활성화합니다.
[config setLogLevel:ADJPLogLevelInfo];    // 기본값입니다.
[config setLogLevel:ADJPLogLevelWarn];    // 정보 로그를 비활성화합니다.
[config setLogLevel:ADJPLogLevelError];   // 경고도 비활성화합니다.
[config setLogLevel:ADJPLogLevelAssert];  // 오류도 비활성화합니다.
```

### <a id="verify-purchases"></a>결제 검증

#### <a id="verification-request"></a>검증 요청

앱에서 이루어진 결제를 검증하려면 `AdjustPurchase` 인스턴스에서 `verifyPurchase:forTransaction:productId:withResponseBlock` 메서드를 호출해야 합니다. 상태가 `SKPaymentTransactionStatePurchased`로 바뀐 경우에만 `paymentQueue:updatedTransaction`의 `finishTransaction` 뒤에서 이 메서드를 호출하세요.

```objc
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing: {
                // 내 작업입니다(해당하는 경우).
                break;
            }
            case SKPaymentTransactionStatePurchased: {
                // 내 작업입니다(해당하는 경우).
                NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
                NSData *receipt = [NSData dataWithContentsOfURL:receiptURL];

                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];

                [AdjustPurchase verifyPurchase:receipt
                                forTransaction:transaction
                                productId:@"your_product_id"
                             withResponseBlock:^(ADJPVerificationInfo *info) {
                                 // ADJPVerificationInfo 개체를 처리합니다... 
                                 [self adjustVerificationUpdate:info];
                             }];

                break;
            }
            case SKPaymentTransactionStateFailed: {
                // 내 작업입니다(해당하는 경우).
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

검증 요청에 사용되는 adjust 구매 SDK의 메서드에서는 다음 매개변수를 전달해야 합니다.

```objc
receipt         // NSData 유형의 앱 영수증
transaction     // SKPaymentTransaction 유형의 완료 트랜잭션 개체
productId       // NSString 유형의 구매 제품 식별자
responseBlock   // 검증 응답을 처리하는 콜백 메서드
```

#### <a id="verification-response"></a>검증 응답 처리

위 코드에 설명된 대로 검증 응답을 처리할 블록을 `verifyPurchase:forTransaction:productId:withResponseBlock` 메서드에 전달해야 합니다.

위 예에서 저희는 응답이 도착하면 `adjustVerificationUpdate` 메서드가 호출되도록 설계했습니다. 결제 검증에 대한 응답은 `ADJPVerificationInfo` 개체로 표시되고 다음 정보를 포함합니다.

```objc
[info verificationState];   // 결제 검증 상태입니다.
[info statusCode];          // 백엔드 응답 상태 코드를 표시하는 정수입니다.
[info message];             // 결제 검증 상태를 설명하는 메시지입니다.
```

검증 상태는 다음 값 중 하나를 가질 수 있습니다.

```
ADJPVerificationStatePassed         - Purchase verification successful.
ADJPVerificationStateFailed         - Purchase verification failed.
ADJPVerificationStateUnknown        - Purchase verification state unknown.
ADJPVerificationStateNotVerified    - Purchase was not verified.
```

* Apple 서버에서 결제가 성공적으로 검증되면 `ADJPVerificationStatePassed`가 `200` 상태 코드와 함께 보고됩니다.
* Apple 서버에서 결제가 유효하지 않다고 인식하면 `ADJPVerificationStateFailed`가 `406` 상태 코드와 함께 보고됩니다.
* Apple 서버가 결제 검증 요청에 대해 아무런 응답도 하지 않으면 `ADJPVerificationStateUnknown`이 `204` 상태 코드와 함께 보고됩니다. 이 상황은 저희가 Apple 서버로부터 결제의 유효성에 관해 아무런 정보도 받지 못했음을 의미합니다. 이 상태는 결제 자체에 대해 아무런 정보를 제공하지 않으며, 결제가 유효할 수도 있고 유효하지 않을 수도 있습니다. 또한 기타 다른 상황으로 인해 저희가 결제 검증에 대한 정확한 상태를 보고받지 못했을 때에도 이 상태가 보고됩니다. 이러한 오류에 대한 자세한 내용은 `ADJPVerificationInfo` 개체의 `message` 필드에서 확인할 수 있습니다.
* `ADJPVerificationStateNotVerified`가 보고되면, `verifyPurchase:forTransaction:productId:withResponseBlock` 메서드에 대한 콜에 유효하지 않은 매개변수가 사용되었음을 의미입니다.

### <a id="track-purchases"></a>검증된 결제 추적

결제가 성공적으로 검증되면 저희의 공식 adjust SDK를 사용하여 결제를 추적하고 대시보드에서 수익을 파악할 수 있습니다. 또한 중복 수익을 추적하지 않기 위해 이벤트에서 생성된 선택적인 트랜잭션 ID를 전달할 수도 있습니다. 마지막 10개의 트랜잭션 ID가 기억되고, 트랜잭션 ID가 같은 매출 이벤트는 건너뜁니다.

위의 예를 사용하여 다음과 같이 이 작업을 수행할 수 있습니다.

```objc
#import "Adjust.h"
// 또는 #import <AdjustSdk/Adjust.h>
#import "AdjustPurchase.h"
// 또는 #import <AdjustPurchaseSdk/AdjustPurchase.h>

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

## <a id="best-practices"></a>모범 사례

`ADJPVerificationStatePassed` 또는 `ADJPVerificationStateFailed`가 보고되면 이러한 결정이 Apple 서버에서 이루어졌으므로 안심하고 구매 수익을 추적하거나 추적하지 않을 수 있습니다. `ADJPVerificationStateUnknown`이 보고되면 이러한 구매에 대해 수행할 작업을 결정할 수 있습니다.

통계 목적으로 adjust 대시보드에서 이러한 각 시나리오에 대해 단일 이벤트를 지정하는 것이 좋습니다. 이렇게 하면 얼마나 많은 수의 결제가 검증되었는지, 검증에 실패했는지, 검증할 수 없어 검증 상태를 알 수 없는지 한눈에 살펴볼 수 있습니다. 원하는 경우 검증되지 않은 결제도 추적할 수 있습니다.

이렇게 하려면 응답 처리를 위한 메서드를 다음과 같이 설정할 수 있습니다.

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

결제 검증은 판매된 상품의 배달을 승인하거나 거절하는 용도로는 사용되지 않습니다. 결제 검증은 보고된 트랜잭션 데이터와 실제 트랜잭션 데이터가 일치하는지 확인하는 작업입니다.

[dashboard]:        http://adjust.com
[adjust.com]:       http://adjust.com

[carthage]:         https://github.com/Carthage/Carthage
[releases]:         https://github.com/adjust/ios_purchase_sdk/releases
[cocoapods]:        http://cocoapods.org
[fraud-prevention]: https://docs.adjust.com/en/fraud-prevention/

[add]:              https://raw.github.com/adjust/sdks/master/Resources/ios_purchase/add.png
[drag]:             https://raw.github.com/adjust/sdks/master/Resources/ios_purchase/drag.png
[integration]:      https://raw.github.com/adjust/sdks/master/Resources/ios_purchase/integration.png

## <a id="license"></a>라이선스

adjust 구매 SDK는 MIT 라이선스에 의거하여 사용이 허가됩니다.

Copyright (c) 2016 adjust GmbH,
http://www.adjust.com

이 소프트웨어와 부속 문서 파일(이하 ‘소프트웨어’)을 소유하고 있는 사람은 무료로 소프트웨어의 복사본을 사용, 복사, 수정, 병합, 발행, 배포, 2차 라이선스 허가, 판매할 수 있는 권한을 부여받았으며, 소프트웨어를 제공받는 사람에게도 그러한 권한을 부여할 수 있는 권한이 있습니다. 단, 반드시 아래의 조건을 충족해야 합니다.

소프트웨어의 모든 복사본이나 소프트웨어의 중요 부분에 상기 저작권 고지와 이 권한 고지를 포함해야 합니다.

소프트웨어는 상품성, 특정 목적에의 적합성, 저작권 비침해에 대한 보증을 비롯하여 어떠한 종류의 묵시적 또는 명시적 보증 없이 '있는 그대로' 제공됩니다. 소프트웨어 제작자 또는 저작권자는 어떠한 경우에도 계약 이행, 계약 위반, 기타 상황에서 소프트웨어, 소프트웨어 사용, 소프트웨어에서의 거래와 관련하여 발생하는 배상 청구, 손해, 또는 기타 책임 문제에 대해 책임을 지지 않습니다.
