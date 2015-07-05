//
//  RemovingDataTests.swift
//  DiskCacheTests
//
//  Created by Julian Grosshauser on 05/07/15.
//  Copyright © 2015 Julian Grosshauser. All rights reserved.
//

import XCTest
import DiskCache

class RemovingDataTests: XCTestCase {

    override func setUp() {
        super.setUp()

        clearAllCachedData()
    }

    func testRemoveAllDataRemovesCacheDirectory() {
        let key = "TestCachingData"
        let data = key.dataUsingEncoding(NSUTF8StringEncoding)!

        createCacheData(data, forKey: key)

        let completionExpectation = expectationWithDescription("completionHandler called")

        let completionHandler: Result<Void> -> Void = { result in
            if case .Failure(let error) = result {
                XCTFail("Removing all data failed: \(error)")
            }

            completionExpectation.fulfill()
        }

        diskCache.removeAllData(completionHandler: completionHandler)

        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)

        XCTAssertFalse(diskCacheFileManager.fileExistsAtPath(diskCache.path), "Cache directory shouldn't exist anymore")
    }

    func testRemoveDataForKeyRemovesCachedData() {
        let key = "TestCachingData"
        let data = key.dataUsingEncoding(NSUTF8StringEncoding)!

        createCacheData(data, forKey: key)

        let completionExpectation = expectationWithDescription("completionHandler called")

        let completionHandler: Result<Void> -> Void = { result in
            if case .Failure(let error) = result {
                XCTFail("Removing cached data failed: \(error)")
            }

            completionExpectation.fulfill()
        }

        do {
            try diskCache.removeDataForKey(key, completionHandler: completionHandler)
        } catch {
            XCTFail("Removing cached data failed: \(error)")
        }

        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)

        XCTAssertFalse(cachedDataExistsForKey(key), "Cached data shouldn't exist anymore")
    }

    func testRemoveDataForKeyRemovesOnlyCachedDataForKey() {
        let keyThatShouldBeRemoved = "DataShouldBeRemoved"
        let dataThatShouldBeRemoved = keyThatShouldBeRemoved.dataUsingEncoding(NSUTF8StringEncoding)!

        let keyThatShouldntBeRemoved = "DataShouldntBeRemoved"
        let dataThatShouldntBeRemoved = keyThatShouldntBeRemoved.dataUsingEncoding(NSUTF8StringEncoding)!

        createCacheData(dataThatShouldBeRemoved, forKey: keyThatShouldBeRemoved)
        createCacheData(dataThatShouldntBeRemoved, forKey: keyThatShouldntBeRemoved)

        let completionExpectation = expectationWithDescription("completionHandler called")

        let completionHandler: Result<Void> -> Void = { result in
            if case .Failure(let error) = result {
                XCTFail("Removing cached data failed: \(error)")
            }

            completionExpectation.fulfill()
        }

        do {
            try diskCache.removeDataForKey(keyThatShouldBeRemoved, completionHandler: completionHandler)
        } catch {
            XCTFail("Removing cached data failed: \(error)")
        }

        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)

        XCTAssertFalse(cachedDataExistsForKey(keyThatShouldBeRemoved), "Cached data shouldn't exist anymore")
        XCTAssertTrue(cachedDataExistsForKey(keyThatShouldntBeRemoved), "Cached data shouldn't be removed")
    }
}
