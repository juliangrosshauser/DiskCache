//
//  DiskCache.swift
//  DiskCache
//
//  Created by Julian Grosshauser on 27/06/15.
//  Copyright © 2015 Julian Grosshauser. All rights reserved.
//

/**
Caches data on disk asynchronously
*/
public class DiskCache {

    //MARK: Properties

    private let fileManager = NSFileManager()

    /**
    Data will be cached at this path, e.g. `Library/Caches/com.domain.App.DiskCache`
    */
    public let path: String

    //MARK: Initialization

    public init(identifier: String) {
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        let cachePath = paths.first!

        // use "DiskCache" as `bundleIdentifier` iff `mainBundle()`s `bundleIdentifier` is `nil`
        let bundleIdentifier = NSBundle.mainBundle().bundleIdentifier ?? "DiskCache"

        path = cachePath.stringByAppendingPathComponent("\(bundleIdentifier).\(identifier)")
    }

    public convenience init() {
        self.init(identifier: "DiskCache")
    }
}
