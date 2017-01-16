## 概要

こちらはadjust™のiOS Purchase SDKです。adjust™について詳しくは[adjust.com]をご覧ください。

## 目次

* [基本的な連携方法](#basic-integration)
    * [SDKダウンロード](#sdk-get)
    * [プロジェクトへのSDKの追加](#sdk-add)
    * [アプリへのSDKの連携](#sdk-integrate)
        * [インポートの記述](#sdk-import)
        * [基本設定](#basic-setup)
        * [Adjust Purchaseログ](#sdk-logging)
    * [課金の検証](#verify-purchases)
        * [検証リクエスト](#verification-request)
        * [検証のレスポンス](#verification-response)
    * [検証された課金のトラッキング](#track-purchases)
* [利用例](#best-practices)
* [ライセンス](#license)

## <a id="basic-integration">基本的な連携方法

adjustのPurchase SDKをご利用になるには、アプリに**まず不正防止ツールを有効化してください**。
詳しくはこちらの公式[不正防止ガイド][fraud-prevention]をご覧ください。

iOSプロジェクトへのadjust Purchase SDKの連携方法を説明します。ここではiOSの開発にXcodeが使われていることを仮定します。

[Carthage][carthage]をお使いの場合、`Cartfile`に以下の行を追加して、[ステップ3](#step3)に移ることができます。

```ruby
github "adjust/ios_purchase_sdk"
```

adjust Purchase SDKをフレームワークとしてプロジェクトに追加する形でも連携できます。
[リリースページ][releases]にてアーカイブを取得してください。

* `AdjustPurchaseSdkStatic.framework.zip`
* `AdjustPurchaseSdkDynamic.framework.zip`

iOS 8リリース以降、Dynamic Framework (またはEmbedded Framework)が使えるようになりました。
アプリがiOS 8以上対応であれば、adjust Purchase SDK dynamic frameworkが利用できます。
StaticかDynamicのどちらのフレームワークを利用するか選び、プロジェクトに追加してから[ステップ3](#step3)に進んでください。

### <a id="sdk-get"></a>SDKダウンロード

[リリースページ][releases]から最新バージョンをダウンロードしてください。ダウンロードしたアーカイブを任意のディレクトリに展開してください。

### <a id="sdk-add"></a>プロジェクトへのSDKの追加

Xcodeのプロジェクトナビゲータ上で、`Supporting Files`グループを見つけてください。Finderから`AdjustPurchase`サブディレクトリをドラッグし、
`Supporting Files`グループにドラッグしてください。これは必ずしも`Supporting Files`である必要はありません。任意のグループを設置してください。

![][drag]

`Choose options for adding these files`のダイアログが出たら、`Copy items if needed`にチェックを入れ
`Create groups`を選んでください。

![][add]

### <a id="sdk-integrate"></a>アプリへのSDKの連携

#### <a id="sdk-import"></a>インポートの記述

ソースからadjust SDKを追加した場合、以下のインポートの記述を加えてください。

```objc
#import "AdjustPurchase.h"
```

Carthageを使ってSDKをフレームワークとして追加した場合、以下のインポートの記述を加えてください。

```objc
#import <AdjustPurchaseSdk/AdjustPurchase.h>
```

iOS Purchase SDKの設定をします。

#### <a id="basic-setup"></a>基本設定

プロジェクトナビゲータ上で、アプリケーションデリゲートのソースファイルを開いてください。ファイルの最上部に`import`の記述を加え、
`didFinishLaunching`か`didFinishLaunchingWithOptions`のメソッド中に以下の`AdjustPurchase`コールを追加してください。

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

`{YourAppToken}`にアプリのトークンを記入してください。トークンは[dashboard]で確認できます。

`environment`に以下のどちらかを設定してください。これはテスト用アプリか本番用アプリかによって異なります。

```objc
NSString *environment = ADJPEnvironmentSandbox;
NSString *environment = ADJPEnvironmentProduction;
```

**重要** この値はアプリのテスト中のみ`ADJPEnvironmentSandbox`に設定してください。
アプリを提出する前に`ADJPEnvironmentProduction`になっていることを必ず確認してください。
再度開発やテストをする際は`ADJPEnvironmentSandbox`に戻してください。

この変数は実際のトラフィックとテスト端末からのテストのトラフィックを区別するために利用されます。
正しく計測するために、この値の設定には常に注意してください。

#### <a id="sdk-logging"></a>Adjust Purchaseログ

`ADJPConfig`インスタンスの`setLogLevel:`に設定するパラメータを変更することによって記録するログのレベルを調節できます。
パラメータは以下の種類があります。

```objc
[config setLogLevel:ADJPLogLevelVerbose]; // すべてのログを有効にする
[config setLogLevel:ADJPLogLevelDebug];   // より詳細なログを記録する
[config setLogLevel:ADJPLogLevelInfo];    // デフォルト
[config setLogLevel:ADJPLogLevelWarn];    // infoのログを無効にする
[config setLogLevel:ADJPLogLevelError];   // warningsを無効にする
[config setLogLevel:ADJPLogLevelAssert];  // errorsも無効にする
```

### <a id="verify-purchases"></a>課金の検証

#### <a id="verification-request"></a>検証リクエスト

アプリ内課金を検証するには、`AdjustPurchase`インスタンスで`verifyPurchase:forTransaction:productId:withResponseBlock`メソッドを
コールしてください。`SKPaymentTransactionStatePurchased`に変わった時のみ、`paymentQueue:updatedTransaction`の
`finishTransaction`の後でこのメソッドをコールしてください。

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

検証リクエストに使われるadjust Purchase SDKのメソッドには以下のパラメータを渡す必要があります。

```objc
receipt         // NSData型のアプリのレシート
transaction     // SKPaymentTransaction型の終了したトランザクションのオブジェクト
productId       // NSString型の課金されたプロダクトID
responseBlock   // 検証のレスポンスを処理するコールバックメソッド
```

#### <a id="verification-response"></a>検証のレスポンス

上記のコードに示したように、検証のレスポンスを処理するブロックを
`verifyPurchase:forTransaction:productId:withResponseBlock`メソッドに渡す必要があります。

上記の例では、レスポンスの受信後に`adjustVerificationUpdate`メソッドが呼ばれるようになっています。
課金検証へのレスポンスは`ADJPVerificationInfo`オブジェクトで表され、以下の情報を含みます。

```objc
[info verificationState];   // 課金検証のステータス
[info statusCode];          // バックエンドでのレスポンスステータスコードを示す整数値
[info message];             // 課金検証のステータスに関するメッセージ
```

課金検証のステータスは以下のいずれかの値を持ち得ます。

```
ADJPVerificationStatePassed         - 課金検証が成功
ADJPVerificationStateFailed         - 課金検証が失敗
ADJPVerificationStateUnknown        - 課金検証のステータスが不明
ADJPVerificationStateNotVerified    - 課金が検証されなかった
```

* 課金がAppleのサーバーで正しく検証された場合、`ADJPVerificationStatePassed`はステータスコード`200`を返します。
* Appleのサーバーが課金を無効として識別した場合、`ADJPVerificationStateFailed`はステータスコード`406`を返します。
* Appleのサーバーが課金の検証リクエストに対して返答を返さなかった場合、`ADJPVerificationStateUnknown`はステータスコード`204`を返します。
これは課金の正当性についてadjustはAppleから何の情報も得ていないことを示します。課金の状態には関係ありません。有効、無効のどちらも有り得ます。
何らかの状況で正しいステータスの送信を阻まれた場合にもこれは起こりえます。これらのエラーに関する詳細は`ADJPVerificationInfo`オブジェクトの
`message`欄でご確認いただけます。
* `ADJPVerificationStateNotVerified`が受信されたら、それは`verifyPurchase:forTransaction:productId:withResponseBlock`メソッド
へのコールが不正なパラメータで行われたことを意味します。

### <a id="track-purchases"></a>検証された課金のトラッキング

課金が正しく検証された後、公式adjust SDKを使ってそれをトラッキングしダッシュボード上で収益として反映させることができます。
重複した課金のトラッキングを防ぐために、イベントで生成されるトランザクションIDを追加することもできます。
最新の10のトランザクションIDが記憶され、重複したトランザクションIDの課金イベントは除外されます。

上記の例を用いて以下に例を挙げます。

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

## <a id="best-practices"></a>利用例

`ADJPVerificationStatePassed`もしくは`ADJPVerificationStateFailed`を受け取れば、この決定はAppleのサーバーによって行われ、
課金の収益としてトラッキングすべきか信用できるものであるという事が保証されます。
`ADJPVerificationStateUnknown`が受信された場合、この課金に対しての挙動を決めることができます。

統計的な目的の場合、adjustダッシュボード上でそれぞれの状況に対して明確なイベントをひとつ用意することが有効かもしれません。
この方法だと、課金のうちいくつが有効、無効、または検証不可能で不明ステータスとして帰ってきたかが分かります。
ご希望であれば検証されなかった課金に対してもトラッキングすることができます。

これを行う場合、レスポンスを処理するメソッドは一例として以下のようになります。

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

課金検証は販売されたアイテムの納入に対して承認または拒否することが目的ではありません。課金検証はレポートされるトランザクションデータを
実際のトランザクションデータと合わせることが目的です。

[dashboard]:        http://adjust.com
[adjust.com]:       http://adjust.com

[carthage]:         https://github.com/Carthage/Carthage
[releases]:         https://github.com/adjust/ios_purchase_sdk/releases
[cocoapods]:        http://cocoapods.org
[fraud-prevention]: https://docs.adjust.com/ja/fraud-prevention/

[add]:              https://raw.github.com/adjust/sdks/master/Resources/ios_purchase/add.png
[drag]:             https://raw.github.com/adjust/sdks/master/Resources/ios_purchase/drag.png
[integration]:      https://raw.github.com/adjust/sdks/master/Resources/ios_purchase/integration.png

## <a id="license"></a>ライセンス

adjust purchase SDKはMITライセンスを適用しています。

Copyright (c) 2016 adjust GmbH,
http://www.adjust.com

以下に定める条件に従い、本ソフトウェアおよび関連文書のファイル（以下「ソフトウェア」）の複製を取得するすべての人に対し、
ソフトウェアを無制限に扱うことを無償で許可します。これには、ソフトウェアの複製を使用、複写、変更、結合、掲載、頒布、サブライセンス、
および/または販売する権利、およびソフトウェアを提供する相手に同じことを許可する権利も無制限に含まれます。

上記の著作権表示および本許諾表示を、ソフトウェアのすべての複製または重要な部分に記載するものとします。

ソフトウェアは「現状のまま」で、明示であるか暗黙であるかを問わず、何らの保証もなく提供されます。
ここでいう保証とは、商品性、特定の目的への適合性、および権利非侵害についての保証も含みますが、それに限定されるものではありません。
作者または著作権者は、契約行為、不法行為、またはそれ以外であろうと、ソフトウェアに起因または関連し、
あるいはソフトウェアの使用またはその他の扱いによって生じる一切の請求、損害、その他の義務について何らの責任も負わないものとします。
