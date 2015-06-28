//
//  DiskCacheError.swift
//  DiskCache
//
//  Created by Julian Grosshauser on 28/06/15.
//  Copyright © 2015 Julian Grosshauser. All rights reserved.
//

/**
Contains all `ErrorType`s `DiskCache` can throw
*/
public enum DiskCacheError: ErrorType {

    case EmptyKey
    case WriteError
}
