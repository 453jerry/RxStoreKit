//
//  SKPaymentQueue+Rx.swift
//  
//
//  Created by Jerry on 2023/1/14.
//

import RxSwift
import StoreKit

// swiftlint: disable file_types_order
@available(watchOS 6.2, *)
extension Reactive where Base: SKPaymentQueue {
    /**
    Observable sequence of updated transactions
    
    - returns: Observable sequence of updated transactions.
    */
    public var updatedTransactions: Observable<SKPaymentTransaction> {
        Observable<SKPaymentTransaction>.create { observer in
            let transactionObserver = TransactionObserver.init(
                updatedTransactionObserver: observer
            )
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
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    public var productIdentifiersWithRevokedEntitlements: Observable<String> {
        Observable<String>.create { observer in
            let observer = TransactionObserver.init(
                revokEntitlementsObserver: observer
            )
            base.add(observer)
            return Disposables.create {
                base.remove(observer)
            }
        }
    }
}

@available(watchOS 6.2, *)
class TransactionObserver: NSObject, SKPaymentTransactionObserver {
    
    var revokEntitlementsObserver: AnyObserver<String>?
    var updatedTransactionObserver: AnyObserver<SKPaymentTransaction>?
    
    init(
        revokEntitlementsObserver: AnyObserver<String>? = nil,
        updatedTransactionObserver: AnyObserver<SKPaymentTransaction>? = nil
    ) {
        self.revokEntitlementsObserver = revokEntitlementsObserver
        self.updatedTransactionObserver = updatedTransactionObserver
    }

    func paymentQueue(
        _ queue: SKPaymentQueue,
        didRevokeEntitlementsForProductIdentifiers productIdentifiers: [String]
    ) {
        productIdentifiers.forEach { self.revokEntitlementsObserver?.onNext($0) }
    }
    
    func paymentQueue(
        _ queue: SKPaymentQueue,
        updatedTransactions transactions: [SKPaymentTransaction]
    ) {
        transactions.forEach { transaction in
            self.updatedTransactionObserver?.onNext(transaction)
        }
    }
}
