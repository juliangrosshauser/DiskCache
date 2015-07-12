//
//  RetrievingCachedDataTests.swift
//  DiskCacheTests
//
//  Created by Julian Grosshauser on 05/07/15.
//  Copyright © 2015 Julian Grosshauser. All rights reserved.
//

import XCTest
import DiskCache

class RetrievingDataTests: XCTestCase {

    override func setUp() {
        super.setUp()

        clearAllCachedData()
    }

    func testRetrievingDataCallsCompletionHandlerWithSuccessAndExpectedData() {
        let key = "TestCachingData"
        let expectedData = key.dataUsingEncoding(NSUTF8StringEncoding)!

        createCacheData(expectedData, forKey: key)

        let completionExpectation = expectationWithDescription("completionHandler called")

        let completionHandler: Result<NSData> -> Void = { result in
            switch result {
            case .Success(let data):
                XCTAssertEqual(expectedData, data, "Retrieved data isn't equal to expected data")

                completionExpectation.fulfill()
            case .Failure(let error):
                XCTFail("Retrieving data failed: \(error)")
            }
        }

        do {
            try diskCache.retrieveDataForKey(key, completionHandler: completionHandler)
        } catch {
            XCTFail("Retrieving data failed: \(error)")
        }

        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
}
