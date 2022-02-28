//
//  MasterViewController.swift
//  Note Taker
//
//  Created by Nathan Pavlovsky on 7/25/17.
//  Copyright © 2017 NathanPavlovsky. All rights reserved.
//
//  This is the view controller that has presents all the notes that were created and runs the program entirely

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate
{
    
    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    
    @IBOutlet var deleteALLButton : UIButton!
    
    //MARK: - References to information about the most recently selected cell for deletion
    var indexPathMostRecentlySelectedCell : IndexPath? = nil
    var detailVCOfMostRecentlySelected : DetailViewController? = nil
    
    //MARK: - Private static utility variables
    private static let DATE_FORMATTER = DateFormatter()
    private static let TIME_FORMATTER = DateFormatter()
    
    //MARK: - Private non-static utility variable
    private var indexPathOfGlasses : IndexPath? = nil
    private var addingRow : Bool = false
    
    //MARK: - Variables concerning the possibility that there may be no notes at all
    private var collectionEmptyLabel : UILabel!
    
    //MARK: - View Controller Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(goToNewNoteVC))
        navigationItem.rightBarButtonItem = addButton
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        self.title = "All Notes"
        
        //we configure the tableview in here also        
        self.tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.initCollectionEmptyLabel()
        if self.tableView.numberOfRows(inSection: 0) == 0
        {
            self.deleteALLButton.isHidden = true
            self.activateCollectionEmptyLabel(newState: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        
        //we configure the private static variables in the class
        MasterViewController.DATE_FORMATTER.locale = Locale(identifier: "en_US")
        MasterViewController.DATE_FORMATTER.dateStyle = .full
        
        MasterViewController.TIME_FORMATTER.dateFormat = "h:mm a"
    }

    func initCollectionEmptyLabel()
    {
        //this function initializes the label that is supposed to overlay the
        //table and tell the user if the collection is empty (instead of
        //having white space in the area that is the table)
        self.collectionEmptyLabel = UILabel()
        self.collectionEmptyLabel.frame = CGRect(x: 0,
                                                 y: (self.view.frame.height/3)-(200/2),
                                                 width: self.view.frame.width, height: 200)
        self.collectionEmptyLabel.backgroundColor = UIColor.clear
        self.collectionEmptyLabel.textColor = UIColor.blue
        
        //we adjust the font size for the type of device that the user is using...
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            self.collectionEmptyLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 24)
        }
        else    //the app is running on an ipad...
        {
            self.collectionEmptyLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 40)
        }
        
        self.collectionEmptyLabel.textAlignment = NSTextAlignment.center
        self.collectionEmptyLabel.numberOfLines = 3
        self.collectionEmptyLabel.lineBreakMode = .byWordWrapping
        self.collectionEmptyLabel.textAlignment = .center
        self.collectionEmptyLabel.text = "You Have No Notes.\nGet Started and Create a New Note!"
        
        //if the device is rotated, we want the label to resize accordingly in all directions
        self.collectionEmptyLabel.autoresizingMask = [.flexibleHeight, .flexibleWidth, .flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin]
        
        //add it to the view...
        self.view.addSubview(self.collectionEmptyLabel)
        
        //when we initialize the label, we want to keep
        //it hidden from the user until we need to activate it...
        activateCollectionEmptyLabel(newState: false)
    }
    
    func activateCollectionEmptyLabel(newState : Bool)
    {
        if newState == true
        {
            self.collectionEmptyLabel.alpha = 1
            self.navigationItem.setLeftBarButton(nil, animated: true)
        }
        else
        {
            self.collectionEmptyLabel.alpha = 0
            self.navigationItem.setLeftBarButton(self.editButtonItem, animated: true)
        }
    }
    
    func goToNewNoteVC()
    {
        performSegue(withIdentifier: "ShowNewNoteVC", sender: self)
    }

    func insertNewObject(theNoteText : String)
    {
        let context = self.fetchedResultsController.managedObjectContext
        let newEvent = Note(context: context)
             
        // If appropriate, configure the new managed object.
        newEvent.noteText = theNoteText
        newEvent.creationDate = NSDate()
        newEvent.modifiedDate = NSDate()

        // Save the context.
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func deleteAllNotes()
    {
        
        let context = fetchedResultsController.managedObjectContext
        
        for i in 0..<tableView.numberOfRows(inSection: 0)
        {
            context.delete(fetchedResultsController.object(at: IndexPath(row: i, section: 0)))
        }
        
        do
        {
            try context.save()
        }
        catch
        {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        self.deleteALLButton.isHidden = true
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow
            {
                let object = fetchedResultsController.object(at: indexPath)
                
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                
                //we save the IndexPath of the most recently selected cell to be used in case we are going to delete the most recently selected note
                indexPathMostRecentlySelectedCell = indexPath
                detailVCOfMostRecentlySelected = controller
            }
        }
        
        else if segue.identifier == "ShowNewNoteVC"
        {
            let destinationVC = segue.destination as! NewNoteViewController
            destinationVC.heightConstraintConstant = (self.navigationController!.navigationBar.frame.height)
            destinationVC.masterViewController = self
        }
    }

    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MasterViewControllerCell
        
        let event : Note =  fetchedResultsController.object(at: indexPath)
        
        configureCell(cell, withNote: event, indexPath: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func setEditing(_ editing: Bool, animated: Bool)
    {
        super.setEditing(editing, animated: animated)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
            
                //if the index path of the deleted cell is equal to the index path of the last selected cell, it means taht the detail view controller has the note's information displayed there
                if indexPath == indexPathMostRecentlySelectedCell
                {
                    //we remove the information from the detail view controller if we are deleting the last selected note whose information is being displayed...
                    resetDetailVC()
                }
                
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
           }
        }
    }

    func configureCell(_ cell: MasterViewControllerCell, withNote note: Note, indexPath : IndexPath)
    {
        cell.titleText.text = note.noteText
        cell.dateText.text = "Last modified "+MasterViewController.getDateAndTimeFromString(date: note.creationDate! as Date)
        
        if indexPathOfGlasses != nil && indexPath == indexPathOfGlasses! && self.addingRow == false
        {
            cell.accessoryImageView.alpha = 0
            cell.accessoryImageView.image = #imageLiteral(resourceName: "glasses")
            cell.accessoryImageView.isHidden = false
            
            //we animate the addition of the glasses
            UIView.animate(withDuration: 0.4, animations: {
                cell.accessoryImageView.alpha = 1
            })
        }
        else
        {
            if cell.accessoryImageView.image != nil
            {
                //we animate the removal of the image
                UIView.animate(withDuration: 0.4, animations: {
                cell.accessoryImageView.alpha = 0
                })
                cell.accessoryImageView.image = nil
                cell.accessoryImageView.isHidden = true
                cell.accessoryImageView.alpha = 1
            }
            else
            {
                cell.accessoryImageView.image = nil
                cell.accessoryImageView.isHidden = true
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        if indexPathOfGlasses == nil
        {
            //meaning that we have not previously selected a row, that means that we can display the glasses here NO PROBLEM
            self.indexPathOfGlasses = indexPath
            tableView.reloadRows(at: [indexPath], with: .none)
        }
        else
        {
            //meaning that we have previously selected a row and that it has glasses displayed
            //we need to remove the glasses from the previous row and then add them to the new row
            let oldIndexOfGlasses = IndexPath(row: self.indexPathOfGlasses!.row, section: self.indexPathOfGlasses!.section)
            self.indexPathOfGlasses = indexPath
            
            tableView.reloadRows(at: [oldIndexOfGlasses,self.indexPathOfGlasses!], with: .none)
        }
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<Note> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        
        // Set the batch size to a suitable number.
        //fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        
        //we present the various notes from the most recently created one to the newest one
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<Note>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                self.addingRow = true
                tableView.insertRows(at: [newIndexPath!], with: .fade)
                self.addingRow = false
            
                if self.tableView.numberOfRows(inSection: 0) == 0
                {
                    //we have added the very first row...
                    //and thus we can unhide the delete all button
                    self.deleteALLButton.isHidden = false
                    self.activateCollectionEmptyLabel(newState: false)
                }
            
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            
                if self.tableView.numberOfRows(inSection: 0) == 1
                {
                    self.activateCollectionEmptyLabel(newState: true)
                    self.deleteALLButton.isHidden = true
                }
            case .update:
                configureCell(tableView.cellForRow(at: indexPath!)! as! MasterViewControllerCell, withNote: anObject as! Note, indexPath: indexPath!)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!)! as! MasterViewControllerCell, withNote: anObject as! Note, indexPath: indexPath!)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         tableView.reloadData()
     }
     */
    
    // MARK: - Public Utility Functions
    func resetDetailVC()
    {
        resetDetailVC(isDeletingAllRows: false)
    }
    
    func resetDetailVC(isDeletingAllRows : Bool)
    {
        if detailVCOfMostRecentlySelected != nil
        {
            detailVCOfMostRecentlySelected!.reset()
            
            //and we also unhighlight the row in the tableView
          
            detailVCOfMostRecentlySelected = nil
            indexPathMostRecentlySelectedCell
                = nil
        }
        
        //we deselect the glasses
        if indexPathOfGlasses != nil
        {
            let oldIndexOfGlasses = IndexPath(row: indexPathOfGlasses!.row, section: indexPathOfGlasses!.section)
            indexPathOfGlasses = nil
            
            if isDeletingAllRows == false
            {
                self.tableView.reloadRows(at: [oldIndexOfGlasses], with: .none)
            }
        }
    }
    
    @IBAction func askIfDeleteAllAndDoIfYes()
    {
        //first we get confirmation from the user that they really want to delete all the notes
        let confirmationController = UIAlertController(title: "Confirmation Required", message: "Are you sure you want to delete all your notes?", preferredStyle: .alert)
        confirmationController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (UIAlertAction) in
        
            //we are going to delete all the notes
            self.deleteAllNotes()
            
            self.resetDetailVC(isDeletingAllRows: true)
            self.activateCollectionEmptyLabel(newState: true)
        }))
        confirmationController.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        
        present(confirmationController, animated: true, completion: nil)
    }
    
    // MARK: - Dates
    static func getDateFromString(date: Date) -> String
    {
        return MasterViewController.DATE_FORMATTER.string(from: date)
    }
    
    static func getDateAndTimeFromString(date: Date) -> String
    {
        return MasterViewController.DATE_FORMATTER.string(from: date) + " at " + MasterViewController.TIME_FORMATTER.string(from: date)
    }
}

