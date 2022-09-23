//
//  ToDo+CoreDataClass.swift
//  CoreDataDemo
//
//  Created by David Jabech on 8/2/22.
//
//

import Foundation
import CoreData

@objc(ToDo)
public class ToDo: NSManagedObject, Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case userId, id, title, completed
    }

    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else {
            fatalError()
        }
        let entity = NSEntityDescription.entity(forEntityName: "ToDo", in: context)!
        self.init(entity: entity, insertInto: context)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        userId = try values.decode(Int16.self, forKey: .userId)
        id = try values.decode(Int16.self, forKey: .id)
        title = try values.decode(String.self, forKey: .title)
        completed = try values.decode(Bool.self, forKey: .completed)
    }
}
