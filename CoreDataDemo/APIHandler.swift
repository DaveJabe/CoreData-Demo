//
//  APIHandler.swift
//  CoreDataDemo
//
//  Created by David Jabech on 8/2/22.
//

import Foundation

enum URLString {
    static let toDoUrl = "https://jsonplaceholder.typicode.com/todos"
}

class APIHandler {
    
    typealias Completion = ((Result<Data, Error>) -> Void)?
    
    static let shared = APIHandler()
    
    func fetchData(urlString: String, completion: Completion) {
        guard let url = URL(string: urlString) else {
            print("Could not create URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, (response as? HTTPURLResponse)?.statusCode == 200 else {
                completion?(.failure("Error getting data from URL"))
                return
            }
            completion?(.success(data))
        }
        task.resume()
    }
}
