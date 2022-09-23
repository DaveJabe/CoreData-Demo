#  CoreData Demo

### This application features different uses and implementation strategies for Core Data:
1. Fetching API data and inserting it directly into object context as NSManagedObject (using a convenience init)
2. Inserting items from background thread using private concurrent context
3. Using parent/child relationship between contexts to automatically merge background changes to main context
4. NSFetchedResultsController
5. Use of NSSortDescriptors
6. Entity relationships with different delete rules (i.e. nullify, cascade)
- Person to one Group -- Group to many Persons

### This application also has some UI features, like UIAlertControllers with UITextFields that have UIPickerViews as the inputView. It also utilizes a UIMenu on the ToDo tab.

### This app was built using MVVM architecture and Singleton and Delegate design patterns.

