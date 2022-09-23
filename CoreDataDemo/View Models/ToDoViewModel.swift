//
//  ToDoViewModel.swift
//  CoreDataDemo
//
//  Created by David Jabech on 8/2/22.
//

import Foundation

protocol ToDoViewModelDelegate: AnyObject {
    func didGetData(error: Error?)
    func presentEmptyFieldAlert()
}

class ToDoViewModel {
    
    private var toDos: [ToDo]?
    
    private var error: Error?
    
    private var newCompletionStatus: Bool?
    
    private weak var delegate: ToDoViewModelDelegate?
    
    private let manager: CoreDataManager = .shared
    
    init(delegate: ToDoViewModelDelegate) {
        self.delegate = delegate
        
        manager.toDosWereFetched = { [weak self] (result: Result<[ToDo], Error>) in
            switch result {
            case .success(let toDos):
                self?.toDos = toDos
            case .failure(let error):
                self?.error = error
            }
            self?.delegate?.didGetData(error: self?.error)
            self?.error = nil // resetting error to nil
        }
    }
    
    func fetchData() {
        manager.fetchToDoData()
    }
    
    func fetchFromAPI() {
        manager.fetchToDoDataFromAPI { [weak self] error in
            if let error = error {
                print(error)
            }
            else {
                self?.fetchData()
            }
        }
    }
    
    func deleteAllToDos() {
        manager.deleteAllToDoData { [weak self] error in
            if let error = error {
                print(error)
            }
            else {
                self?.fetchData()
            }
        }
    }
    
    private func validEntries(entries: String...) -> Bool {
        for entry in entries {
            if entry.isEmpty {
                return false
            }
        }
        return true
    }
    
    func getToDoCount() -> Int {
        return toDos?.count ?? 0
    }
    
    func updateCompletionStatus(completed: Bool?) {
        newCompletionStatus = completed
    }
    
    func updateCompletionStatus(fromItemAt index: Int) {
        newCompletionStatus = toDos?[index].completed
    }
    
    func getTitleForItem(at index: Int) -> String {
        guard let title = toDos?[index].title else {
            return ""
        }
        return title
    }
    
    func getIDForItem(at index: Int) -> Int16 {
        guard let id = toDos?[index].id else {
            return 0
        }
        return id
    }
    
    func getCompletionStatusForItem(at index: Int) -> String {
        guard let completed = toDos?[index].completed else {
            return ""
        }
        return completed ? "Completed" : "Incomplete"
    }
    
    func getCellTitleForRow(index: Int) -> String {
        return "\(getIDForItem(at: index)): \(getTitleForItem(at: index))"
    }
    
    func deleteToDo(at index: Int) {
        guard let itemToDelete = toDos?.remove(at: index) else {
            return
        }
        manager.removeToDoItem(itemToDelete)
        delegate?.didGetData(error: nil)
    }
    
    func updateToDoItem(at index: Int, newTitle: String) {
        guard let toDo = toDos?[index], let newCompletionStatus = newCompletionStatus else {
            self.newCompletionStatus = nil
            return
        }
        
        if validEntries(entries: newTitle) {
            manager.updateToDoItem(toDo, newTitle: newTitle, newCompletionStatus: newCompletionStatus)
            delegate?.didGetData(error: nil)
        }
        else {
            delegate?.presentEmptyFieldAlert()
        }
        self.newCompletionStatus = nil
    }
}
