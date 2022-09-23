//
//  CoreDataErrors.swift
//  CoreDataDemo
//
//  Created by David Jabech on 8/2/22.
//

import Foundation

extension String: Error {}

enum CoreDataError {
    static let loadPersistentStoresError = "Failed to load persistent stores"
    static let fetchObjectsError = "Failed to fetch objects"
    static let saveContextError = "Failed to save context"
    static let invalidObjectID = "Invalid ObjectID"
}
