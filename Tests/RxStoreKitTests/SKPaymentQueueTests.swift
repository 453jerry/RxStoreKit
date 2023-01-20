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
    
    func testSubscribeUpdatedTransaction_AddObserver() {
        let mockPaymentQueue = MockPaymentQueue.init()
        mockPaymentQueue.addObserverExpection = expectation(
            description: "Add Observer"
        )
        mockPaymentQueue.addObserverExpection?.assertForOverFulfill = true
        mockPaymentQueue.addObserverExpection?.expectedFulfillmentCount = 1
        let paymentQueue: SKPaymentQueue = mockPaymentQueue
        
        let disposable = paymentQueue.rx.updatedTransactions
            .subscribe()
        
        waitForExpectations(timeout: 1)
        disposable.dispose()
    }
    
    func testDisposeUpdatedTransaction_RemoveObserver() {
        let mockPaymentQueue = MockPaymentQueue.init()
        mockPaymentQueue.removeObserverExpection = expectation(
            description: "Remove Observer"
        )
        mockPaymentQueue.removeObserverExpection?.assertForOverFulfill = true
        mockPaymentQueue.removeObserverExpection?.expectedFulfillmentCount = 1
        let paymentQueue: SKPaymentQueue = mockPaymentQueue
        
        let disposable = paymentQueue.rx.updatedTransactions
            .subscribe()
        disposable.dispose()
        waitForExpectations(timeout: 1)
    }
    
    func testSubscribeUpdatedTransaction_OnNext() {
        let stubPaymentQueue = StubPaymentQueue.init()
        let paymentQueue: SKPaymentQueue = stubPaymentQueue
        
        let fakeTransactions = [SKPaymentTransaction.init(), SKPaymentTransaction.init()]
        var fakeTransactionsIterator = fakeTransactions.makeIterator()
        let onNextExpectation = expectation(description: "OnNext")
        onNextExpectation.expectedFulfillmentCount = fakeTransactions.count
        let disposable = paymentQueue.rx.updatedTransactions
            .subscribe { transaction in
                XCTAssertIdentical(transaction, fakeTransactionsIterator.next())
                onNextExpectation.fulfill()

            }
        stubPaymentQueue.updateTransaction(updatedTransactions: fakeTransactions)
        
        waitForExpectations(timeout: 1)
        disposable.dispose()
    }
    
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    func testSubscribeProductIdentifiersWithRevokedEntitlements_AddObserver() {
        let mockPaymentQueue = MockPaymentQueue.init()
        mockPaymentQueue.addObserverExpection = expectation(
            description: "Add Observer"
        )
        mockPaymentQueue.addObserverExpection?.assertForOverFulfill = true
        mockPaymentQueue.addObserverExpection?.expectedFulfillmentCount = 1
        let paymentQueue: SKPaymentQueue = mockPaymentQueue
        
        let disposable = paymentQueue.rx.productIdentifiersWithRevokedEntitlements
            .subscribe()
        
        waitForExpectations(timeout: 1)
        disposable.dispose()
    }
    
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    func testDisposeProductIdentifiersWithRevokedEntitlements_RemoveObserver() {
        let mockPaymentQueue = MockPaymentQueue.init()
        mockPaymentQueue.removeObserverExpection = expectation(
            description: "Remove Observer"
        )
        mockPaymentQueue.removeObserverExpection?.assertForOverFulfill = true
        mockPaymentQueue.removeObserverExpection?.expectedFulfillmentCount = 1
        let paymentQueue: SKPaymentQueue = mockPaymentQueue
        
        let disposable = paymentQueue.rx.productIdentifiersWithRevokedEntitlements
            .subscribe()
        disposable.dispose()
        waitForExpectations(timeout: 1)
    }
        
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    func testSubscribeProductIdentifiersWithRevokedEntitlements_OnNext() {
        let stubPaymentQueue = StubPaymentQueue.init()
        let paymentQueue: SKPaymentQueue = stubPaymentQueue
        
        let fakeProductIdentifiers = ["test1", "test2"]
        var fakeProductIdentifiersIterator = fakeProductIdentifiers.makeIterator()
        let onNextExpectation = expectation(description: "OnNext")
        onNextExpectation.expectedFulfillmentCount = fakeProductIdentifiers.count
        let disposable = paymentQueue.rx.productIdentifiersWithRevokedEntitlements
            .subscribe { productIdentifier in
                XCTAssertEqual(
                    productIdentifier,
                    fakeProductIdentifiersIterator.next()
                )
                onNextExpectation.fulfill()
            }
        
        stubPaymentQueue.revokeEntitlements(
            productIdentifiers: fakeProductIdentifiers
        )
        
        waitForExpectations(timeout: 1)
        disposable.dispose()
    }
    
    private class StubPaymentQueue: SKPaymentQueue {
        
        weak var testObserve: SKPaymentTransactionObserver?
        
        override func add(_ observer: SKPaymentTransactionObserver) {
            self.testObserve = observer
        }
        
        func updateTransaction(updatedTransactions: [SKPaymentTransaction]) {
            testObserve?.paymentQueue(self, updatedTransactions: updatedTransactions)
        }
        
        @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
        func revokeEntitlements(productIdentifiers: [String]) {
            testObserve?.paymentQueue?(
                self,
                didRevokeEntitlementsForProductIdentifiers: productIdentifiers
            )
        }
    }
    
    private class MockPaymentQueue: SKPaymentQueue {
        
        var addObserverExpection: XCTestExpectation?
        
        override func add(_ observer: SKPaymentTransactionObserver) {
            addObserverExpection?.fulfill()
        }
        
        var removeObserverExpection: XCTestExpectation?
        
        override func remove(_ observer: SKPaymentTransactionObserver) {
            removeObserverExpection?.fulfill()
        }
    }
}
