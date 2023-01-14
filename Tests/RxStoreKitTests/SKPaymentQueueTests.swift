//
//  SKPaymentQueueTests.swift\
//  
//
//  Created by Jerry on 2023/1/14.
//

import RxSwift
import StoreKit
import XCTest

@testable import RxStoreKit

class SKPaymentQueueTests: XCTestCase {
    func testSubscribeUpdatedTransaction_OnNext() {
        let stubPaymentQueue = StubPaymentQueue.init()
        let paymentQueue: SKPaymentQueue = stubPaymentQueue
        
        let fakeTransactions = [SKPaymentTransaction.init(), SKPaymentTransaction.init()]
        var fakeTransactionsIterator = fakeTransactions.makeIterator()
        let onNextExpectation = expectation(description: "OnNext")
        onNextExpectation.expectedFulfillmentCount = fakeTransactions.count
        let disposable = paymentQueue.rx.updatedTransaction
            .subscribe { transaction in
                XCTAssertIdentical(transaction, fakeTransactionsIterator.next())
                onNextExpectation.fulfill()

            }
        stubPaymentQueue.updateTransaction(updatedTransactions: fakeTransactions)
        
        waitForExpectations(timeout: 1)
        disposable.dispose()
    }
    
    func testSubscribeUpdatedTransaction_RemoveObserverAfterDispose() {
        let stubPaymentQueue = StubPaymentQueue.init()
        let paymentQueue: SKPaymentQueue = stubPaymentQueue
        
        let disposable = paymentQueue.rx.updatedTransaction
            .subscribe()
        XCTAssertEqual(paymentQueue.transactionObservers.count, 1)
        disposable.dispose()
        XCTAssertEqual(paymentQueue.transactionObservers.count, 0)
        
    }
    
    private class StubPaymentQueue: SKPaymentQueue {
        func updateTransaction(updatedTransactions: [SKPaymentTransaction]) {
            self.transactionObservers.forEach { observer in
                observer.paymentQueue(self, updatedTransactions: updatedTransactions)
            }
        }
    }
}
