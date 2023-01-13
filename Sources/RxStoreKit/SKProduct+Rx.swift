//
//  SKProduct+Rx.swift
//  
//
//  Created by Jerry on 2023/1/13.
//

import RxSwift
import StoreKit

// swiftlint: disable file_types_order
extension Reactive where Base: SKProduct {
    /**
    Observable sequence of responses for SKProductRequest
    
    - parameter request: Proeuct Identifiers
    - returns: Observable sequence of SKProductsResponse.
    */
    public static func request(with productIdentifiers: Set<String>) ->
    Observable<SKProductsResponse> {
        Observable<SKProductsResponse>.create { observer in
            var request = SKProductsRequestFactory.current.create(
                with: productIdentifiers
            )
            let requestDelegate: SKProductsRequestDelegatePorxy? =
            SKProductsRequestDelegatePorxy.init(observer: observer)
            
            request.delegate = requestDelegate
            request.start()
            return Disposables.create {
                // Let this cloure catputre requestDelegate to
                // prevent the delgate being released early
                _ = requestDelegate
                request.cancel()
            }
        }
        .share()
    }
}

class SKProductsRequestFactory {
    static var current = SKProductsRequestFactory.init()

    func create(with productIdentifiers: Set<String>) -> SKProductsRequestProtocol {
        SKProductsRequest.init(productIdentifiers: productIdentifiers)
    }
}

class SKProductsRequestDelegatePorxy: NSObject, SKProductsRequestDelegate {
    let observer: AnyObserver<SKProductsResponse>
    
    init(observer: AnyObserver<SKProductsResponse>) {
        self.observer = observer
    }
    
    func requestDidFinish(_ request: SKRequest) {
        observer.onCompleted()
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        observer.onError(error)
    }
    
    func productsRequest(
        _ request: SKProductsRequest,
        didReceive response: SKProductsResponse
    ) {
        observer.onNext(response)
    }
}
