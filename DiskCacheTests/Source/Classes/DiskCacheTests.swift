//
//  DiskCacheTests.swift
//  DiskCacheTests
//
//  Created by Julian Grosshauser on 28/06/15.
//  Copyright © 2015 Julian Grosshauser. All rights reserved.
//

import XCTest
import DiskCache

let diskCacheIdentifier = "TestDiskCache"
let diskCache = DiskCache(identifier: diskCacheIdentifier)
let diskCacheFileManager = NSFileManager()
let expectationTimeout = 0.05

class DiskCacheTests: XCTestCase {

    override func setUp() {
        super.setUp()

        clearAllCachedData()
    }

    func testPathGetsCorrectlySet() {
        let bundleIdentifier = NSBundle.mainBundle().bundleIdentifier ?? "DiskCache"

        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        let diskCachePath = paths.first!.stringByAppendingPathComponent("\(bundleIdentifier).\(diskCacheIdentifier)")

        XCTAssertEqual(diskCachePath, diskCache.path, "Path wasn't correctly set")
    }
}
