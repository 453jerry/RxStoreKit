//
//  SKProductTests.swift
//  
//
//  Created by Jerry on 2023/1/13.
//

import StoreKit
import XCTest

@testable import RxStoreKit

class SKProductsTests: XCTestCase {

    override func setUpWithError() throws {
        SKProductsRequestFactory.current = SKProductsRequestFactory.init()
    }
    
    // swiftlint: disable empty_xctest_method
    override func tearDown() {}

    func testDisposeRequest_CancelRequest() {
        let mockRequest = MockProductsRequest.init()
        mockRequest.cancelExpection = expectation(description: "Invoke cancel")
        SKProductsRequestFactory.current = StubProductsRequestFactor.init(
            request: mockRequest
        )

        SKProduct.rx.request(with: ["com.temporary.test1"]).subscribe().dispose()

        waitForExpectations(timeout: 1)
    }
    
    func testSubscribeRequest_StartRequest() {
        let mockRequest = MockProductsRequest.init()
        mockRequest.startExpection = expectation(description: "Invoke start")
        SKProductsRequestFactory.current = StubProductsRequestFactor.init(
            request: mockRequest
        )

        SKProduct.rx.request(with: ["com.temporary.test1"]).subscribe().dispose()

        waitForExpectations(timeout: 1)
    }
    
    // swiftlint: disable trailing_closure
    func testSubscribeRequest_OnNextWithResponse() {
        let stubRequest = StubProductsRequest.init()
        SKProductsRequestFactory.current = StubProductsRequestFactor.init(
            request: stubRequest
        )
        let fakeResponse = SKProductsResponse.init()
        
        let expectation = expectation(description: "Response element")
        
        let disposable = SKProduct.rx.request(with: ["com.temporary.test1"]).subscribe(
            onNext: { response in
                XCTAssertIdentical(response, fakeResponse)
                expectation.fulfill()
            }
        )
        stubRequest.onRespose(fakeResponse: fakeResponse)
        
        waitForExpectations(timeout: 1)
        disposable.dispose()
    }
    
    func testSubscribeRequest_OnComplete() {
        let stubRequest = StubProductsRequest.init()
        SKProductsRequestFactory.current = StubProductsRequestFactor.init(
            request: stubRequest
        )
        
        let expectation = expectation(description: "Complete")
        let disposable = SKProduct.rx.request(with: ["com.temporary.test1"])
            .subscribe(onCompleted: {
                expectation.fulfill()
            })
        stubRequest.onFinished()
        
        waitForExpectations(timeout: 1)
        disposable.dispose()
    }
    
    func testSubscribeRequest_OnError() {
        let stubRequest = StubProductsRequest.init()
        SKProductsRequestFactory.current = StubProductsRequestFactor.init(
            request: stubRequest
        )
        let fakeError = NSError.init(domain: "test", code: 0)
        
        let expectation = expectation(description: "Error")
        
        let disposable = SKProduct.rx.request(with: ["com.temporary.test1"]).subscribe(
            onError: {error in
                XCTAssertIdentical(error as AnyObject, fakeError)
                expectation.fulfill()
            }
        )
        stubRequest.onError(error: fakeError)
        
        waitForExpectations(timeout: 1)
        disposable.dispose()
    }
    
    func testSubscribeReqeust_Share() {
        let mockRequest = MockProductsRequest.init()
        SKProductsRequestFactory.current = StubProductsRequestFactor.init(
            request: mockRequest
        )
        mockRequest.startExpection = expectation(description: "Invoke start onece")
        mockRequest.startExpection?.expectedFulfillmentCount = 1
        
        let observerable = SKProduct.rx.request(with: ["com.temporary.test1"])
        
        let disposable1 = observerable.subscribe()
        let disposable2 = observerable.subscribe()

        waitForExpectations(timeout: 1)
        disposable1.dispose()
        disposable2.dispose()
    }
    
    private class StubProductsRequestFactor: SKProductsRequestFactory {
        
        let request: SKProductsRequestProtocol
        
        init(request: SKProductsRequestProtocol) {
            self.request = request
        }
        
        override func create(with: Set<String>) ->
        SKProductsRequestProtocol {
            self.request
        }
    }
    
    private class MockProductsRequest: SKProductsRequestProtocol {
        
        var startExpection: XCTestExpectation?
        var cancelExpection: XCTestExpectation?
        
        weak var delegate: SKProductsRequestDelegate?
        
        func start() {
            startExpection?.fulfill()
        }
        
        func cancel() {
            cancelExpection?.fulfill()
        }
    }
    
    private class StubProductsRequest: SKProductsRequest {
        
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
