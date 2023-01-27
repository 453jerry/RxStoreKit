# RxStoreKit

[![swift](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2F453jerry%2FRxStoreKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/453jerry/RxStoreKit)
[![platform](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2F453jerry%2FRxStoreKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/453jerry/RxStoreKit)  
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

or

```swift
let request = SKProductsRequest.init(productIdentifiers: ["product_id"])
request.rx.response.subscribe { event in
    switch event {
    case .next(let response): 
        let products = response.products
    default:
        return
    }
}
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

### Subscribe product identifiers with revoked entitlements

```swift
paymentQueue.rx.productIdentifiersWithRevokedEntitlements
    .subscribe { productIdentifier in
        // Do what you want
    }
```
