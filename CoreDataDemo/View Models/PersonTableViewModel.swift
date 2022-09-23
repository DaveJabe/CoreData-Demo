//
//  PersonTableViewModel.swift
//  CoreDataDemo
//
//  Created by David Jabech on 8/1/22.
//

import UIKit
import CoreData

// MARK: - ViewModel Delegate

protocol PersonTableViewModelDelegate: AnyObject {
    func didGetData(error: Error?)
    func presentEmptyFieldAlert()
}


// MARK: - ViewModel Class

class PersonTableViewModel {
    
    // MARK: - Properties
    
    private var groups: [Group]?
    
    private var error: Error?
    
    private var selectedGroup: Int?
    
    private weak var delegate: PersonTableViewModelDelegate?
    
    private let manager: CoreDataManager = .shared
    
    // MARK: - Init
    
    init(delegate: PersonTableViewModelDelegate) {
        self.delegate = delegate
        
        manager.dataWasFetched = { [weak self] (result: Result<[Group], Error>) in
            switch result {
            case .success(let groups):
                self?.groups = groups
            case .failure(let error):
                self?.error = error
            }
            self?.delegate?.didGetData(error: self?.error)
            self?.error = nil // resetting error to nil
        }
    }
    
    // MARK: - Methods
    
    func fetchData() {
        manager.fetchData()
    }
    
    func selectGroup(index: Int) {
        selectedGroup = index
    }
    
    private func validEntries(entries: String...) -> Bool {
        for entry in entries {
            if entry.isEmpty {
                return false
            }
        }
        return true
    }
    
    // MARK: Group methods
    
    func getGroupCount() -> Int {
        return groups?.count ?? 0
    }
    
    func createGroup(name: String) {
        if validEntries(entries: name) {
            manager.insertNewGroup(name: name)
        }
        else {
            delegate?.presentEmptyFieldAlert()
        }
    }
    
    func deleteGroup() {
        guard let selectedGroup = selectedGroup, let groupToDelete = groups?[selectedGroup] else {
            delegate?.presentEmptyFieldAlert()
            return
        }
        manager.removeEntity(entity: groupToDelete)
        delegate?.didGetData(error: nil)
        self.selectedGroup = nil // resetting selectedGroup to nil
    }
    
    func getTitleForSection(section: Int) -> String {
        guard let group = groups?[section], let name = group.name else {
            print("Error getting group title")
            return ""
        }
        return name
    }
    
    // MARK: Person methods
    
    func getPeopleCount(section: Int) -> Int {
        guard let group = groups?[section], let people = group.people else {
            print("Error getting people count")
            return 0
        }
        return people.count
    }
    
    func getTitleFor(itemAt indexPath: IndexPath) -> String {
        guard let group = groups?[indexPath.section], let people = group.peopleArray else {
            print("Error getting person title")
            return ""
        }
        return people[indexPath.row].name ?? ""
    }
    
    func getAddressFor(itemAt indexPath: IndexPath) -> String {
        guard let group = groups?[indexPath.section], let people = group.peopleArray else {
            print("Error getting address")
            return ""
        }
        return people[indexPath.row].address ?? ""
    }
    
    func addItem(name: String, address: String) {
        if validEntries(entries: name, address) && selectedGroup != nil {
            guard let selectedGroup = selectedGroup, let group = groups?[selectedGroup] else {
                print("Could not find selected group")
                return
            }
            manager.insertNewPerson2(name: name,
                                    address: address,
                                    groupID: group.objectID)
            
            self.selectedGroup = nil // resetting selectedGroup to nil
        }
        else {
            delegate?.presentEmptyFieldAlert()
        }
    }
    
    func deleteItem(at indexPath: IndexPath) {
        guard let itemToRemove = groups?[indexPath.section].peopleArray?[indexPath.row] else {
            return
        }
        manager.removeEntity(entity: itemToRemove)
        delegate?.didGetData(error: nil)
    }
    
    func updateItem(at indexPath: IndexPath, name: String, address: String) {
        if validEntries(entries: name, address) {
            guard let itemToUpdate = groups?[indexPath.section].peopleArray?[indexPath.row] else {
                print("Could not find item to update in groups")
                return
            }
            manager.updatePerson(itemToUpdate,
                                 name: name,
                                 address: address)
            
            delegate?.didGetData(error: nil)
        }
        else {
            delegate?.presentEmptyFieldAlert()
        }
    }
}
