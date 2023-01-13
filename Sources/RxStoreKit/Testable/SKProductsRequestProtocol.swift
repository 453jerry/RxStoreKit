//
//  SKProductsRequestProtocol.swift
//  
//
//  Created by Jerry on 2023/1/13.
//

import StoreKit

internal protocol SKProductsRequestProtocol {
    var delegate: SKProductsRequestDelegate? { get set }
    
    func start()
    
    func cancel()
}

extension SKProductsRequest: SKProductsRequestProtocol {}
