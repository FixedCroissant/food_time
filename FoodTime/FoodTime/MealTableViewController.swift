//
//  MealTableViewController.swift
//  FoodTime
//
//  Created by Joshua Williams on 3/28/18.
//  Copyright © 2018 Joshua Williams. All rights reserved.
//

import UIKit
import os.log

class MealTableViewController: UITableViewController {
    
    //MARK: Properties
    var meals = [Meal]()
    
    
    //MARK: Actions
    @IBAction func unwindToMealList(sender: UIStoryboardSegue){
    
        if let sourceViewController = sender.source as? MealViewController, let meal = sourceViewController.meal {
        
        //Handle the situation if we are editing a food item and
        //do not need to just add it to the list.
        if let selectedIndexPath = tableView.indexPathForSelectedRow{
        
            //Update an existing meal.
            meals[selectedIndexPath.row] = meal
            tableView.reloadRows(at:[selectedIndexPath],with:.none)
        }
        //Add new item/meal
        else{
        
            //Add a new meal.
            let newIndexPath = IndexPath(row: meals.count, section:0)
            
            //Add new meal to the current list of meals
            //in the array (under the properties)
            meals.append(meal)
            
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        
            }
        
            //Save Meals to disk.
            saveMeals()
        }
    }
    
    
    
    //MARK: Private Methods
    private func saveMeals(){
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(meals, toFile: Meal.ArchiveURL.path)
    
    
    
        if isSuccessfulSave{
            os_log("Meals successfully saved.", log: OSLog.default,type:.debug)
        }
        else
        {
            os_log("Meals did not successfully save. Error.", log: OSLog.default,type:.debug)
        }
    
    }
    
    
    private func loadSampleMeals(){
        let photo1 = UIImage(named: "avacado")
        let photo2 = UIImage(named: "blueberry")
        let photo3 = UIImage(named: "peach")
    
        // Meal 1
        guard let meal1 = Meal(name:"Tasty Avacados", photo: photo1, rating: 1 ) else {
            fatalError("Unable to instantiate meal1")
        }        
        // Meal 2
        guard let meal2 = Meal(name:"Fantastic Blueberries", photo: photo2, rating: 3 ) else {
            fatalError("Unable to instantiate meal2")
        }
        // Meal 3
        guard let meal3 = Meal(name:"Lovely Peaches", photo: photo3, rating: 4 ) else {
            fatalError("Unable to instantiate meal3")
        }
        
        //Add to the array created at the top.
        meals += [meal1, meal2, meal3]
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem

        //Load any sample meals (if they exist), else load the standard sample
        //meals.
        if let savedMeals = loadMeals(){
                meals += savedMeals
        }
        else
        {
        
            //Load the sample meals created above.
            loadSampleMeals()
        
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MealTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MealTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let meal = meals[indexPath.row]

        //Set properties
        
        cell.nameLabel.text = meal.name
        cell.photoImageView.image = meal.photo
        cell.ratingControl.rating = meal.rating
        
        return cell
        
    }
 

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
                // Delete the row from the data source
                //This removes the meal from the meal array.
                meals.remove(at: indexPath.row)
                //Save data to the disk, when a new meal is deleted.
                saveMeals()
                tableView.deleteRows(at: [indexPath], with: .fade)
                //This removes the meal from the table view that is
                //shown on the screen.
               tableView.deleteRows(at: [indexPath], with: .fade)
              }
        else if editingStyle == .insert
        {
            // Create a new instance of the appropriate class, 
            //insert it into the array, and add a new row to the table view
        }    
    }
 

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue,sender: sender)
        
        switch(segue.identifier ?? "")
        {
                case "AddItem":
                        os_log("Adding a new meal.",log: OSLog.default, type: .debug)
        
                case "ShowDetail":
                        guard let mealDetailViewController = segue.destination as? MealViewController
                            else{
                                fatalError("Unexpected destination: \(segue.destination)")
                                }
                        guard let selectedMealCell = sender as? MealTableViewCell else {
        
                                fatalError("Unexpected sender: \(sender)")
                                }
        
                        guard let indexPath = tableView.indexPath(for: selectedMealCell) else{
        
                                fatalError("The selected cell is not being displayed by the table.")
                        }
        
                        //Integer.
                        let selectedMeal = meals[indexPath.row]
                        mealDetailViewController.meal = selectedMeal
    
            //Add standard default clause.
                default:
                    fatalError("Unexpected Segue Identifer; \(segue.identifier)")
        
        }//close switch
    }//close function
 


    /*
    * Load all the meals from file storage.
    */
    private func loadMeals() -> [Meal]? {
        
        return NSKeyedUnarchiver.unarchiveObject(withFile:Meal.ArchiveURL.path) as? [Meal]
    
    }



}
