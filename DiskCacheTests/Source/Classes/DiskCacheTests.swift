//
//  DiskCacheTests.swift
//  DiskCacheTests
//
//  Created by Julian Grosshauser on 28/06/15.
//  Copyright © 2015 Julian Grosshauser. All rights reserved.
//

import XCTest
import DiskCache

class DiskCacheTests: XCTestCase {

    private static let diskCacheIdentifier = "TestDiskCache"
    private let diskCache = DiskCache(identifier: DiskCacheTests.diskCacheIdentifier)
    private let fileManager = NSFileManager()
    private let expectationTimeout = 0.05
    
    override func setUp() {
        super.setUp()

        clearAllCachedData()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testPathGetsCorrectlySet() {
        let bundleIdentifier = NSBundle.mainBundle().bundleIdentifier ?? "DiskCache"

        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        let diskCachePath = paths.first!.stringByAppendingPathComponent("\(bundleIdentifier).\(DiskCacheTests.diskCacheIdentifier)")

        XCTAssertEqual(diskCachePath, diskCache.path, "Path wasn't correctly set")
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

    func testRetrievingDataCallsCompletionHandlerWithSuccessAndData() {
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

        XCTAssertFalse(fileManager.fileExistsAtPath(diskCache.path), "Cache directory shouldn't exist anymore")
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

//MARK: Test Helpers

extension DiskCacheTests {

    private func clearAllCachedData() {
        do {
            if fileManager.fileExistsAtPath(diskCache.path) {
                try fileManager.removeItemAtPath(diskCache.path)
            }
        } catch {
            XCTFail("Error clearing cache data: \(error)")
        }
    }

    private func createCacheData(data: NSData, forKey key: String) {
        if key.isEmpty {
            XCTFail("Can't create cache data with empty key")
        }

        if !fileManager.fileExistsAtPath(diskCache.path) {
            do {
                try fileManager.createDirectoryAtPath(diskCache.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                XCTFail("Creating cache directory failed: \(error)")
            }
        }

        let filePath = diskCache.path.stringByAppendingPathComponent(key)

        XCTAssertTrue(fileManager.createFileAtPath(filePath, contents: data, attributes: nil), "Creating cache data failed")
    }

    private func cachedDataExistsForKey(key: String) -> Bool {
        let filePath = diskCache.path.stringByAppendingPathComponent(key)

        return fileManager.fileExistsAtPath(filePath)
    }

    private func cachedDataForKey(key: String) throws -> NSData {
        let filePath = diskCache.path.stringByAppendingPathComponent(key)

        if let data = NSData(contentsOfFile: filePath) {
            return data
        } else {
            throw DiskCacheError.CacheMiss
        }
    }
}
