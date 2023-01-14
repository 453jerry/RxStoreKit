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
    public var updatedTransaction: Observable<SKPaymentTransaction> {
        Observable<SKPaymentTransaction>.create { observer in
            let transactionObserver = RxPaymentTransactionObserver.init(observer: observer)
            base.add(transactionObserver)
            return Disposables.create {
                base.remove(transactionObserver)
            }
        }
    }
}

class RxPaymentTransactionObserver: NSObject, SKPaymentTransactionObserver {

    var observer: AnyObserver<SKPaymentTransaction>?
    
    init(observer: AnyObserver<SKPaymentTransaction>) {
        self.observer = observer
        super.init()
        print("TransOb init")
    }
    
    func paymentQueue(
        _ queue: SKPaymentQueue,
        updatedTransactions transactions: [SKPaymentTransaction]
    ) {
        transactions.forEach { transaction in
            self.observer?.onNext(transaction)
        }
    }
    
    deinit {
        print("TransOb deini")
    }
}
