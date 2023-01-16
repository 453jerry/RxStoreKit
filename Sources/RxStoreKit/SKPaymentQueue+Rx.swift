//
//  SKPaymentQueue+Rx.swift
//  
//
//  Created by Jerry on 2023/1/14.
//

import RxSwift
import StoreKit

// swiftlint: disable file_types_order
extension Reactive where Base: SKPaymentQueue {
    /**
    Observable sequence of updated transactions
    
    - returns: Observable sequence of updated transactions.
    */
    public var updatedTransactions: Observable<SKPaymentTransaction> {
        Observable<SKPaymentTransaction>.create { observer in
            let transactionObserver = UpdatedTransactionObserver.init(observer: observer)
            base.add(transactionObserver)
            return Disposables.create {
                base.remove(transactionObserver)
            }
        }
    }
    
    // swiftlint: disable identifier_name
    /**
    Observable sequence of product identifiers with revoked entitlements.
    
    - returns: Observable sequence of product identifiers with revoked entitlements.
    */
    public var productIdentifiersWithRevokedEntitlements: Observable<String> {
        Observable<String>.create { observer in
            let observer = RevokEntitlementsObserver.init(observer: observer)
            base.add(observer)
            return Disposables.create {
                base.remove(observer)
            }
        }
    }
}

class RevokEntitlementsObserver: NSObject, SKPaymentTransactionObserver {
    
    var observer: AnyObserver<String>?
    
    init(observer: AnyObserver<String>) {
        self.observer = observer
        super.init()
    }
    
    func paymentQueue(
        _ queue: SKPaymentQueue,
        didRevokeEntitlementsForProductIdentifiers productIdentifiers: [String]
    ) {
        productIdentifiers.forEach { self.observer?.onNext($0) }
    }
    
    func paymentQueue(
        _ queue: SKPaymentQueue,
        updatedTransactions transactions: [SKPaymentTransaction]
    ) { }
}

class UpdatedTransactionObserver: NSObject, SKPaymentTransactionObserver {

    var observer: AnyObserver<SKPaymentTransaction>?
    
    init(observer: AnyObserver<SKPaymentTransaction>) {
        self.observer = observer
        super.init()
    }
    
    func paymentQueue(
        _ queue: SKPaymentQueue,
        updatedTransactions transactions: [SKPaymentTransaction]
    ) {
        transactions.forEach { transaction in
            self.observer?.onNext(transaction)
        }
    }
}
