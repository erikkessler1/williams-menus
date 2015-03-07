//
//  DataSource.swift
//  Williams Menus
//
//  Created by Erik Kessler on 3/6/15.
//  Copyright (c) 2015 Erik Kessler. All rights reserved.
//

import Foundation

class DataSource{
    var dris: NSDictionary?
    var resk: NSDictionary?
    var mish: NSDictionary?
    
    var contDict: [String: DHTableViewController] = Dictionary()
    
    init() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let refreshDate: NSTimeInterval = defaults.valueForKey("Refresh Date") as? NSTimeInterval {
            let rDate = NSDate(timeIntervalSinceReferenceDate: refreshDate)
            let currentCal = NSCalendar.currentCalendar()

            if (currentCal.isDateInToday(rDate)) {
                println("Load from Storage")
                dris = defaults.valueForKey("Dris Menu") as? NSDictionary
                resk = defaults.valueForKey("Resk Menu") as? NSDictionary
                mish = defaults.valueForKey("Mish Menu") as? NSDictionary
                return
            }
            
        }
        println("Load from internet")
        
        let baseURL = NSURL(string: "https://script.google.com/macros/s/AKfycbySXmsz4YrnduBCLfrvjr8wlSXriVmnrorVMwPw3ncGrt8CjuGZ/exec")
        
        // Create the download task
        let sharedSession = NSURLSession.sharedSession()
        let downloadTask = sharedSession.downloadTaskWithURL(baseURL!, completionHandler: { (location: NSURL!, response, error) -> Void in
            
            // Check if there was an error
            if (error == nil) {
                let dataObject = NSData(contentsOfURL: location)
                
                let responseDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataObject!, options: nil, error: nil) as NSDictionary
                
                self.dris = responseDictionary["Driscoll"] as? NSDictionary
                self.resk = responseDictionary["Paresky"] as? NSDictionary
                self.mish = responseDictionary["Mission"] as? NSDictionary
                
                
                
                defaults.setObject(self.dris, forKey: "Dris Menu")
                defaults.setObject(self.resk, forKey: "Resk Menu")
                defaults.setObject(self.mish, forKey: "Mish Menu")
                
                defaults.setObject(NSDate.timeIntervalSinceReferenceDate(), forKey: "Refresh Date")
                
                if (self.contDict.count != 0) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        for (hall, controller) in self.contDict {
                            self.getMenu(hall, controller: controller)
                        }
                        self.contDict.removeAll(keepCapacity: true)
                    })
                    
                }
                
            } else {
                
                // Display the error - server error
                
            }
        })
        
        // Start the download task
        downloadTask.resume()
    }
    
    func getMenu(index: String, controller: DHTableViewController) {
        if (mish == nil) {
            self.contDict[index] = controller
            return
        } else {
            switch index {
            case "Paresky":
                controller.getData(resk!)
            case "Driscoll":
                controller.getData(dris!)
            case "Mission":
                controller.getData(mish!)
            default:
                println("Index Not Dound")
            }
        }

    }
    
}
