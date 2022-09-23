//
//  PersonTableViewController.swift
//  CoreDataDemo
//
//  Created by David Jabech on 8/1/22.
//

import UIKit

class PersonTableViewController: UIViewController {
    
    // MARK: - Properties
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private lazy var viewModel = PersonTableViewModel(delegate: self)
    
    private var selectedTextField: UITextField?
    
    private var groupBarButton: UIBarButtonItem?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Person Data"
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        viewModel.fetchData()
        
        configureNavBarItems()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: - Methods
    
    private func configureNavBarItems() {
        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"),
                                        style: .plain,
                                        target: self,
                                        action: #selector(addButtonWasPressed))
        
        let editButton = UIBarButtonItem(title: "Edit",
                                         style: .plain,
                                         target: self,
                                         action: #selector(editButtonWasPressed(_:)))
        
        groupBarButton = UIBarButtonItem(title: "Create Group...",
                                         style: .plain,
                                         target: self,
                                         action: #selector(groupBarButtonWasPressed(_:)))
        
        navigationItem.setLeftBarButton(groupBarButton!, animated: true)
        navigationItem.setRightBarButtonItems([addButton, editButton], animated: true)
    }
    
    @objc private func addButtonWasPressed() {
        let alert = UIAlertController(title: "Add Person",
                                      message: "Type name & address below",
                                      preferredStyle: .alert)
        
        alert.addTextField(placeholder: "Name...")
        alert.addTextField(placeholder: "Address...")
        
        alert.addTextFieldWithPickerView(delegateDataSource: self,
                                         placeholder: "Select Group...") { [weak self] textField in
            self?.selectedTextField = textField
        }
        
        let save = UIAlertAction(title: "Save",
                                 style: .default,
                                 handler: { [weak self] _ in
            
            let name = alert.textFields?.first?.text ?? ""
            let address = alert.textFields?[1].text ?? ""
            
            self?.viewModel.addItem(name: name, address: address)
        })
        
        alert.addAction(save)
        alert.addCancel()
        
        present(alert, animated: true)
        
    }
    
    @objc private func editButtonWasPressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            tableView.isEditing = false
            sender.title = "Edit"
            groupBarButton?.title = "Create Group..."
        }
        else {
            tableView.isEditing = true
            sender.title = "Done"
            groupBarButton?.title = "Delete Group..."
        }
    }
    
    @objc private func groupBarButtonWasPressed(_ sender: UIBarButtonItem) {
        
        var alert: UIAlertController
        
        if !tableView.isEditing {
            alert = UIAlertController(title: "Create Group",
                                      message: "Type group name below",
                                      preferredStyle: .alert)
            alert.addTextField(placeholder: "Name...")
            
            let save = UIAlertAction(title: "Save",
                                     style: .default,
                                     handler: { [weak self] _ in
                let name = alert.textFields?.first?.text ?? ""
                
                self?.viewModel.createGroup(name: name)
            })
            alert.addAction(save)
        }
        
        else {
            alert = UIAlertController(title: "Delete Group",
                                      message: "Select group to delete",
                                      preferredStyle: .alert)
            
            alert.addTextFieldWithPickerView(delegateDataSource: self,
                                             placeholder: "Delete...") { [weak self] textField in
                self?.selectedTextField = textField
            }
            
            let delete = UIAlertAction(title: "Delete",
                                       style: .default,
                                       handler: { [weak self] _ in
                self?.viewModel.deleteGroup()
            })
            alert.addAction(delete)
        }

        alert.addCancel()
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource Methods

extension PersonTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: DataSource methods
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.getTitleForSection(section: section)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.getGroupCount()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getPeopleCount(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = viewModel.getTitleFor(itemAt: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteItem(at: indexPath)
        }
    }
    
    // MARK: Delegate methods
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let alert = UIAlertController(title: "Update Person",
                                      message: "Update fields below",
                                      preferredStyle: .alert)
        
        alert.addTextField(text: viewModel.getTitleFor(itemAt: indexPath))
        alert.addTextField(text: viewModel.getAddressFor(itemAt: indexPath))
        
        let update = UIAlertAction(title: "Update",
                                   style: .default) { [weak self] _ in
            
            let name = alert.textFields?.first?.text ?? ""
            let address = alert.textFields?[1].text ?? ""
            
            self?.viewModel.updateItem(at: indexPath, name: name, address: address)
        }
        
        alert.addAction(update)
        alert.addCancel()
        
        present(alert, animated: true)
    }
}

// MARK: - UIPickerViewDelegate & UIPickerViewDataSource Methods

extension PersonTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.getGroupCount()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.getTitleForSection(section: row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.selectGroup(index: row)
        
        guard let textField = selectedTextField else {
            return
        }
        textField.text = viewModel.getTitleForSection(section: row)
        textField.resignFirstResponder()
    }
}


// MARK: - ViewModel Delegate

extension PersonTableViewController: PersonTableViewModelDelegate {
    func didGetData(error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            presentSimpleAlert(title: "Error fetching people")
        }
        else {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    func presentEmptyFieldAlert() {
        presentSimpleAlert(title: "Empty field(s)",
                           message: "Please ensure no fields are empty")
    }
}
