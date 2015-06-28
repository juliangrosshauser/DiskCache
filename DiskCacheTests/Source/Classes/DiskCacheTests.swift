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
    
    override func setUp() {
        super.setUp()
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
        let message = "TestCachingData"
        let data = message.dataUsingEncoding(NSUTF8StringEncoding)!

        let completionExpectation = expectationWithDescription("completionHandler called")

        let completionHandler: Result<Void> -> Void = { result in
            if case .Failure(let error) = result {
                XCTFail("Caching data failed: \(error)")
            }

            completionExpectation.fulfill()
        }

        do {
            try diskCache.cacheData(data, forKey: message, completionHandler: completionHandler)
        } catch {
            XCTFail("Caching data failed: \(error)")
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }
}
