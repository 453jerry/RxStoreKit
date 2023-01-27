//
//  SKProductRequestTests..swift
//  
//
//  Created by Jerry on 2023/1/20.
//

import StoreKit
import XCTest

@testable import RxStoreKit

@available(watchOS 6.2, *)
class SKProductRequestTests: XCTestCase {
    
    func testDisposeRequest_CancelRequest() {
        let mockRequest = MockProductsRequest(productIdentifiers: ["com.temporary.test1"])
        mockRequest.cancelExpection = expectation(description: "Invoke cancel")

        mockRequest.rx.response.subscribe().dispose()

        waitForExpectations(timeout: 1)
    }

    func testSubscribeRequest_StartRequest() {
        let mockRequest = MockProductsRequest(productIdentifiers: ["com.temporary.test1"])
        mockRequest.startExpection = expectation(description: "Invoke start")

        mockRequest.rx.response.subscribe().dispose()

        waitForExpectations(timeout: 1)
    }
    
    func testSubscribeRequest_OnNextWithResponse() {
        let stubRequest = StubProductsRequest.init(productIdentifiers: [])
        let fakeResponse = SKProductsResponse.init()

        let expectation = expectation(description: "Response element")
        expectation.assertForOverFulfill = true
        expectation.expectedFulfillmentCount = 1

        let disposable = stubRequest.rx.response.subscribe { event in
            switch event {
            case .next(let response):
                XCTAssertEqual(fakeResponse, response)
                expectation.fulfill()
            default:
                return
            }
        }
        stubRequest.onRespose(fakeResponse: fakeResponse)

        waitForExpectations(timeout: 1)
        disposable.dispose()
    }

    func testSubscribeRequest_OnComplete() {
        let stubRequest = StubProductsRequest.init(productIdentifiers: [])

        let expectation = expectation(description: "On Completed")
        expectation.assertForOverFulfill = true
        expectation.expectedFulfillmentCount = 1

        let disposable = stubRequest.rx.response.subscribe { event in
            switch event {
            case .completed:
                expectation.fulfill()
            default:
                return
            }
        }
        stubRequest.onFinished()

        waitForExpectations(timeout: 1)
        disposable.dispose()
    }

    func testSubscribeRequest_OnError() {
        let stubRequest = StubProductsRequest.init(productIdentifiers: [])
        let fakeError = NSError(domain: "Test", code: 0)

        let expectation = expectation(description: "On Error")
        expectation.assertForOverFulfill = true
        expectation.expectedFulfillmentCount = 1

        let disposable = stubRequest.rx.response.subscribe { event in
            switch event {
            case .error(let error):
                XCTAssertEqual(fakeError, error as NSError)
                expectation.fulfill()
            default:
                return
            }
        }
        stubRequest.onError(error: fakeError)

        waitForExpectations(timeout: 1)
        disposable.dispose()
    }

    func testSubscribeReqeust_Share() {
        let mockRequest = MockProductsRequest.init(productIdentifiers: [])
        
        mockRequest.startExpection = expectation(description: "Invoke start onece")
        mockRequest.startExpection?.expectedFulfillmentCount = 1
        
        let observerable = mockRequest.rx.response
        
        let disposable1 = observerable.subscribe()
        let disposable2 = observerable.subscribe()
        
        waitForExpectations(timeout: 1)
        disposable1.dispose()
        disposable2.dispose()
    }
    
    func testSubscribeReqeust_ForwardDelegate() {
        let stubRequest = StubProductsRequest.init(productIdentifiers: [])
        let fakeResponse = SKProductsResponse.init()

        let expectation = expectation(description: "Response element")
        expectation.assertForOverFulfill = true
        expectation.expectedFulfillmentCount = 2
        
        let delegate = RequestDelegate.init(expectation: expectation)
        stubRequest.delegate = delegate
        let disposable = stubRequest.rx.response.subscribe { event in
            switch event {
            case .next(let response):
                XCTAssertEqual(fakeResponse, response)
                expectation.fulfill()
            default:
                return
            }
        }
        stubRequest.onRespose(fakeResponse: fakeResponse)

        waitForExpectations(timeout: 1)
        disposable.dispose()
        
        class RequestDelegate: NSObject, SKProductsRequestDelegate {
            
            let expectation: XCTestExpectation
            
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            
            func productsRequest(
                _ request: SKProductsRequest,
                didReceive response: SKProductsResponse
            ) {
                expectation.fulfill()
            }
        }
    }

    @available(watchOS 6.2, *)
    private class MockProductsRequest: SKProductsRequest {
        override init(productIdentifiers: Set<String>) {
            super.init()
        }
        
        var startExpection: XCTestExpectation?
        
        override func start() {
            startExpection?.fulfill()
        }
        
        var cancelExpection: XCTestExpectation?
        
        override func cancel() {
            cancelExpection?.fulfill()
        }
    }
       
    @available(watchOS 6.2, *)
    private class StubProductsRequest: SKProductsRequest {
        override init(productIdentifiers: Set<String>) {
            super.init()
        }
        
        override func start() {}
        
        override func cancel() {}
        
        func onError(error: Error) {
            self.delegate?.request?(self, didFailWithError: error)
        }
        
        func onFinished() {
            self.delegate?.requestDidFinish?(self)
        }
        
        func onRespose(fakeResponse: SKProductsResponse) {
            self.delegate?.productsRequest(self, didReceive: fakeResponse)
        }
    }
}
