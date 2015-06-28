//
//  Result.swift
//  DiskCache
//
//  Created by Julian Grosshauser on 28/06/15.
//  Copyright © 2015 Julian Grosshauser. All rights reserved.
//

/**
Encapsulates success or failure
*/
public enum Result<T> {

    case Success(T)
    case Failure(ErrorType)
}
