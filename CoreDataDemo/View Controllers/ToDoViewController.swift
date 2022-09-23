//
//  ToDoViewController.swift
//  CoreDataDemo
//
//  Created by David Jabech on 8/2/22.
//

import UIKit

class ToDoViewController: UIViewController {

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "toDoCell")
        return tableView
    }()
    
    private lazy var viewModel = ToDoViewModel(delegate: self)
    
    private var selectedTextField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "To Do Data [0]"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        configureNavBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func configureNavBar() {
        let manageDataButton = UIBarButtonItem(image: UIImage(systemName: "folder.badge.gearshape"),
                                               style: .plain,
                                               target: self,
                                               action: nil)
        
        let menu = UIMenu(title: "Manage Data",
                          children: [UIAction(title: "Fetch ToDos",
                                              handler: { [weak self] _ in self?.viewModel.fetchData() }),
                                     UIAction(title: "Fetch ToDos From API",
                                              handler: { [weak self] _ in self?.viewModel.fetchFromAPI() }),
                                     UIAction(title: "Delete All",
                                              attributes: [.destructive],
                                              handler: { [weak self] _ in self?.viewModel.deleteAllToDos() })
                                    ])
        manageDataButton.menu = menu
        
        navigationItem.setRightBarButton(manageDataButton, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource Methods

extension ToDoViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Datasource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getToDoCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "toDoCell", for: indexPath)
        cell.textLabel?.text = viewModel.getCellTitleForRow(index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        viewModel.deleteToDo(at: indexPath.row)
    }
    
    // MARK: Delegate methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        viewModel.updateCompletionStatus(fromItemAt: indexPath.row)
        
        let alert = UIAlertController(title: "Update To Do",
                                      message: "Update fields below",
                                      preferredStyle: .alert)
        alert.addTextField(text: viewModel.getTitleForItem(at: indexPath.row))
        alert.addTextFieldWithPickerView(delegateDataSource: self,
                                         text: viewModel.getCompletionStatusForItem(at: indexPath.row)) { [weak self] textField in
            self?.selectedTextField = textField
        }
        
        let update = UIAlertAction(title: "Update",
                                   style: .default) { [weak self] _ in
            self?.viewModel.updateToDoItem(at: indexPath.row, newTitle: alert.textFields?.first?.text ?? "")
        }
        
        let cancel = UIAlertAction(title: "Cancel",
                                   style: .cancel) { [weak self] _ in
            self?.viewModel.updateCompletionStatus(completed: nil)
        }
        
        alert.addActions(update, cancel)
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
}

// MARK: - UIPickerViewDelegate & UIPickerViewDataSource Methods

extension ToDoViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row {
        case 0: return "Completed"
        case 1: return "Incomplete"
        default: return "error"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row {
        case 0:
            selectedTextField?.text = "Completed"
            viewModel.updateCompletionStatus(completed: true)
        case 1: selectedTextField?.text = "Incomplete"
            viewModel.updateCompletionStatus(completed: false)
        default: selectedTextField?.text = "error"
        }
        
        selectedTextField?.resignFirstResponder()
    }
}


// MARK: - ToDoViewModelDelegate

extension ToDoViewController: ToDoViewModelDelegate {
    func didGetData(error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            presentSimpleAlert(title: "Error getting ToDo data")
        }
        else {
            DispatchQueue.main.async { [weak self] in
                self?.title = "To Do Data [\(self?.viewModel.getToDoCount() ?? 0)]"
                self?.tableView.reloadData()
            }
        }
    }
    
    func presentEmptyFieldAlert() {
        presentSimpleAlert(title: "Empty field(s)",
                           message: "Please ensure no fields are empty")
    }
}
