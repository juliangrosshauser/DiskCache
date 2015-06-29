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

    //MARK: Cache data

    /**
    Cache data asynchronously

    - Parameter data: Data to cache
    - Parameter forKey: Key for data
    - Parameter completionHandler: Called on main thread after data is cached
    
    - Warning: Doesn't throw when error happens asynchronously. Check `.Success` or `.Failure` in `Result` parameter of `completionHandler` instead.
    */
    public func cacheData(data: NSData, forKey key: String, completionHandler: (Result<Void> -> Void)?) throws {
        if key.isEmpty {
            throw DiskCacheError.EmptyKey
        }

        dispatch_async(ioQueue) {
            if !self.fileManager.fileExistsAtPath(self.path) {
                do {
                    try self.fileManager.createDirectoryAtPath(self.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler?(.Failure(error))
                        return
                    }
                }
            }

            let filePath = self.path.stringByAppendingPathComponent(key)

            if self.fileManager.createFileAtPath(filePath, contents: data, attributes: nil) {
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler?(.Success())
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler?(.Failure(DiskCacheError.WriteError))
                }
            }
        }
    }

    //MARK: Retrieve data

    /**
    Retrieve data asynchronously

    - Parameter key: Key for data
    - Parameter completionHandler: Called on main thread with retrieved data or error as parameter

    - Warning: Doesn't throw when error happens asynchronously. Check `.Success` or `.Failure` in `Result` parameter of `completionHandler` instead.
    */
    public func retrieveDataForKey(key: String, completionHandler: Result<NSData> -> Void) throws {
        if key.isEmpty {
            throw DiskCacheError.EmptyKey
        }

        dispatch_async(ioQueue) {
            let filePath = self.path.stringByAppendingPathComponent(key)

            if !self.fileManager.fileExistsAtPath(filePath) {
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(.Failure(DiskCacheError.CacheMiss))
                }
            } else {
                if let data = NSData(contentsOfFile: filePath) {
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler(.Success(data))
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler(.Failure(DiskCacheError.ReadError))
                    }
                }
            }
        }
    }

    //MARK: Remove data

    /**
    Remove all cached data asynchronously

    - Parameter completionHandler: Called on main thread after all cached data got removed

    - Note: `Result` parameter of `completionHandler` contains `.Success` or `.Failure`
    */
    public func removeAllData(completionHandler completionHandler: (Result<Void> -> Void)?) {
        dispatch_async(ioQueue) {
            // if path doesn't exist we can exit early with success
            if !self.fileManager.fileExistsAtPath(self.path) {
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler?(.Success())
                }
            } else {
                do {
                    try self.fileManager.removeItemAtPath(self.path)

                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler?(.Success())
                    }
                } catch {
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler?(.Failure(error))
                    }
                }
            }
        }
    }

    /**
    Remove cached data with key asynchronously

    - Parameter key: Key for data
    - Parameter completionHandler: Called on main thread after cached data got removed

    - Warning: Doesn't throw when error happens asynchronously. Check `.Success` or `.Failure` in `Result` parameter of `completionHandler` instead.
    */
    public func removeDataForKey(key: String, completionHandler: (Result<Void> -> Void)?) throws {
        if key.isEmpty {
            throw DiskCacheError.EmptyKey
        }

        dispatch_async(ioQueue) {
            let filePath = self.path.stringByAppendingPathComponent(key)

            // if file doesn't exist we can exit early with success
            if !self.fileManager.fileExistsAtPath(filePath) {
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler?(.Success())
                }
            } else {
                do {
                    try self.fileManager.removeItemAtPath(filePath)

                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler?(.Success())
                    }
                } catch {
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler?(.Failure(error))
                    }
                }
            }
        }
    }
}
