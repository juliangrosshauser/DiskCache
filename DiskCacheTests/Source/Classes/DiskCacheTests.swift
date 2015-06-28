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
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testPathGetsCorrectlySet() {
        let identifier = "TestDiskCache"
        let diskCache = DiskCache(identifier: identifier)

        let bundleIdentifier = NSBundle.mainBundle().bundleIdentifier ?? "DiskCache"

        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        let diskCachePath = paths.first!.stringByAppendingPathComponent("\(bundleIdentifier).\(identifier)")

        XCTAssertEqual(diskCachePath, diskCache.path, "Path wasn't correctly set")
    }
}
