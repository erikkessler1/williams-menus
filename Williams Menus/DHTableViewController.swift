//
//  PareskyTableViewController.swift
//  Williams Menus
//
//  Created by Erik Kessler on 3/6/15.
//  Copyright (c) 2015 Erik Kessler. All rights reserved.
//

import UIKit

class DHTableViewController: UITableViewController {

    
    let mealSort = ["BREAKFAST": 0, "BRUNCH":0, "LUNCH": 1, "DINNER": 2]
    
    var meals: [String]?
    var items: [[String]] = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        

    }
    
    func loadData() {
        let title = self.navigationController?.tabBarItem.title!
        (UIApplication.sharedApplication().delegate as AppDelegate).dataSource?.getMenu(title!, controller: self)
        
    }
    
    func getData(data: NSDictionary) {
        items = Array()
        meals = (data.allKeys as [String])
        
        meals!.sort { (first, second) -> Bool in
            return self.mealSort[first] < self.mealSort[second]
        }
        
        for meal in meals! {
            var iArray = Array<String>()
            let subMenu = data[meal] as NSDictionary
            for subKey in subMenu.allKeys {
                var array = subMenu[subKey as String] as Array<String>
                for item in array {
                    iArray.append(item)
                }
            }
            items.append(iArray)
        }
        
        self.tableView.reloadData()
        
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        if meals != nil {
            return meals!.count
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return meals![section].capitalizedString
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return items[section].count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        cell.textLabel?.text = items[indexPath.section][indexPath.row]

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}