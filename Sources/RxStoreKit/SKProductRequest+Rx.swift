//
//  SKProductRequest+Rx.swift
//  
//
//  Created by Jerry on 2023/1/14.
//

import RxCocoa
import RxSwift
import StoreKit

// swiftlint: disable file_types_order
@available(watchOS 6.2, *)
extension Reactive where Base: SKProductsRequest {
    public var delegate: DelegateProxy<SKProductsRequest, SKProductsRequestDelegate> {
        SKProductsRequestDelegateProxy.proxy(for: base)
    }

    public var response: Observable<SKProductsResponse> {
        Observable<SKProductsResponse>.create { observer in
            SKProductsRequestDelegateProxy.proxy(for: base).observer = observer
            base.start()
            return Disposables.create {
                SKProductsRequestDelegateProxy.proxy(for: base).observer = nil
                base.cancel()
            }
        }
        .share()
    }
}

@available(watchOS 6.2, *)
class SKProductsRequestDelegateProxy:
    DelegateProxy<SKProductsRequest, SKProductsRequestDelegate>,
    DelegateProxyType,
    SKProductsRequestDelegate {
    
    var observer: AnyObserver<SKProductsResponse>?
    
    static func registerKnownImplementations() {
        self.register { parent in
            SKProductsRequestDelegateProxy.init(
                parentObject: parent,
                delegateProxy: SKProductsRequestDelegateProxy.self
            )
        }
    }
    
    static func currentDelegate(for object: SKProductsRequest) -> SKProductsRequestDelegate? {
        object.delegate
    }
    
    static func setCurrentDelegate(
        _ delegate: SKProductsRequestDelegate?,
        to object: SKProductsRequest
    ) {
        let originDelegate = object.delegate
        object.delegate = delegate
        if let delegate = originDelegate {
            if delegate is SKProductsRequestDelegateProxy == false {
                object.rx.delegate.setForwardToDelegate(delegate, retainDelegate: false)
            }
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.observer?.onNext(response)
        self.forwardToDelegate()?.productsRequest(request, didReceive: response)
    }

    func requestDidFinish(_ request: SKRequest) {
        observer?.onCompleted()
        self.forwardToDelegate()?.requestDidFinish?(request)
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        observer?.onError(error)
        self.forwardToDelegate()?.request?(request, didFailWithError: error)
    }
}
