//
//  TestHelpers.swift
//  DiskCacheTests
//
//  Created by Julian Grosshauser on 05/07/15.
//  Copyright © 2015 Julian Grosshauser. All rights reserved.
//

import XCTest
import DiskCache

func clearAllCachedData() {
    do {
        if diskCacheFileManager.fileExistsAtPath(diskCache.path) {
            try diskCacheFileManager.removeItemAtPath(diskCache.path)
        }
    } catch {
        XCTFail("Error clearing cache data: \(error)")
    }
}

func createCacheData(data: NSData, forKey key: String) {
    if key.isEmpty {
        XCTFail("Can't create cache data with empty key")
    }

    if !diskCacheFileManager.fileExistsAtPath(diskCache.path) {
        do {
            try diskCacheFileManager.createDirectoryAtPath(diskCache.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            XCTFail("Creating cache directory failed: \(error)")
        }
    }

    let filePath = diskCache.path.stringByAppendingPathComponent(key)

    XCTAssertTrue(diskCacheFileManager.createFileAtPath(filePath, contents: data, attributes: nil), "Creating cache data failed")
}

func cachedDataExistsForKey(key: String) -> Bool {
    let filePath = diskCache.path.stringByAppendingPathComponent(key)

    return diskCacheFileManager.fileExistsAtPath(filePath)
}

func cachedDataForKey(key: String) throws -> NSData {
    let filePath = diskCache.path.stringByAppendingPathComponent(key)

    if let data = NSData(contentsOfFile: filePath) {
        return data
    } else {
        throw DiskCacheError.CacheMiss
    }
}
