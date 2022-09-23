//
//  Person+CoreDataProperties.swift
//  CoreDataDemo
//
//  Created by David Jabech on 8/1/22.
//
//

import Foundation
import CoreData


extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged public var name: String?
    @NSManaged public var address: String?
    @NSManaged public var group: Group?

}

extension Person : Identifiable {

}
