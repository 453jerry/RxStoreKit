# RxStoreKit

Reactive extensions of StoreKit

## How to use

### Request SKProduct

Create observable sequence of responses for SKProductRequest and subscribe it

``` swift
SKProduct.rx.request(with: ["xxxxx"])
    .subscribe(onNext: { response in
        let products = response.products
    })
    .dispose()
```

### Subscribe update payment transactons

```swift
 SKPaymentQueue.default().rx.updatedTransaction
    .subscribe(onNext: { transaction in
        // Do what you want
    })
    .dispose()
```