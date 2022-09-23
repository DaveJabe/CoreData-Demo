//
//  Group+CoreDataProperties.swift
//  CoreDataDemo
//
//  Created by David Jabech on 8/1/22.
//
//

import Foundation
import CoreData


extension Group {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Group> {
        let fetchRequest = NSFetchRequest<Group>(entityName: "Group")
        fetchRequest.sortDescriptors = []
        return fetchRequest
    }

    @NSManaged public var name: String?
    @NSManaged public var people: NSSet?
    
    var peopleArray: [Person]? {
        return people?.allObjects as? [Person]
    }
}

// MARK: Generated accessors for people
extension Group {

    @objc(addPeopleObject:)
    @NSManaged public func addToPeople(_ value: Person)

    @objc(removePeopleObject:)
    @NSManaged public func removeFromPeople(_ value: Person)

    @objc(addPeople:)
    @NSManaged public func addToPeople(_ values: NSSet)

    @objc(removePeople:)
    @NSManaged public func removeFromPeople(_ values: NSSet)

}

extension Group : Identifiable {

}
