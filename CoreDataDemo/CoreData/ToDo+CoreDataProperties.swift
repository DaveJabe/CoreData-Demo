//
//  ToDo+CoreDataProperties.swift
//  CoreDataDemo
//
//  Created by David Jabech on 8/2/22.
//
//

import Foundation
import CoreData

extension ToDo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDo> {
        
        let request = NSFetchRequest<ToDo>(entityName: "ToDo")
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        return request
    }

    @NSManaged public var completed: Bool
    @NSManaged public var title: String?
    @NSManaged public var id: Int16
    @NSManaged public var userId: Int16

}

extension ToDo : Identifiable {

}
