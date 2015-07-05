//
//  CachingDataTests.swift
//  DiskCacheTests
//
//  Created by Julian Grosshauser on 04/07/15.
//  Copyright © 2015 Julian Grosshauser. All rights reserved.
//

import XCTest
import DiskCache

class CachingDataTests: XCTestCase {

    override func setUp() {
        super.setUp()

        clearAllCachedData()
    }

    func testCachingDataCallsCompletionHandlerWithSuccess() {
        let key = "TestCachingData"
        let data = key.dataUsingEncoding(NSUTF8StringEncoding)!

        let completionExpectation = expectationWithDescription("completionHandler called")

        let completionHandler: Result<Void> -> Void = { result in
            if case .Failure(let error) = result {
                XCTFail("Caching data failed: \(error)")
            }

            completionExpectation.fulfill()
        }

        do {
            try diskCache.cacheData(data, forKey: key, completionHandler: completionHandler)
        } catch {
            XCTFail("Caching data failed: \(error)")
        }

        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }

    func testCachingDataOverwritesExistingCachedDataWithSameKey() {
        let key = "TestCachingData"
        let dataToBeOverwritten = "Data to be overwritten".dataUsingEncoding(NSUTF8StringEncoding)!
        let expectedData = "Expected data".dataUsingEncoding(NSUTF8StringEncoding)!

        createCacheData(dataToBeOverwritten, forKey: key)

        let completionExpectation = expectationWithDescription("completionHandler called")

        let completionHandler: Result<Void> -> Void = { result in
            if case .Failure(let error) = result {
                XCTFail("Caching data failed: \(error)")
            }

            completionExpectation.fulfill()
        }

        do {
            try diskCache.cacheData(expectedData, forKey: key, completionHandler: completionHandler)
        } catch {
            XCTFail("Caching data failed: \(error)")
        }

        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)

        do {
            let cachedData = try cachedDataForKey(key)
            XCTAssertEqual(cachedData, expectedData, "Retrieved data isn't equal to expected data")
        } catch {
            XCTFail("Retrieving data failed: \(error)")
        }
    }
}
