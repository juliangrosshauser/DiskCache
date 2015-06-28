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
    private let ioQueue: dispatch_queue_t

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

        let cacheIdentifier = "\(bundleIdentifier).\(identifier)"
        path = cachePath.stringByAppendingPathComponent(cacheIdentifier)

        let ioQueueLabel = "\(cacheIdentifier).queue"
        ioQueue = dispatch_queue_create(ioQueueLabel, DISPATCH_QUEUE_SERIAL)
    }

    public convenience init() {
        self.init(identifier: "DiskCache")
    }
}
