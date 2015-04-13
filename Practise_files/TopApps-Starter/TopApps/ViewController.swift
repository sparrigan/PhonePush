//
//  ViewController.swift
//  TopApps
//
//  Created by Dani Arnaout on 9/1/14.
//  Edited by Eric Cerney on 9/27/14.
//  Copyright (c) 2014 Ray Wenderlich All rights reserved.
//

import UIKit

import SwiftyJSON

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
 
    //This is the way of doing it with SwiftyJSON
    
    //DataManager.getTopAppsDataFromFileWithSuccess { (data) -> Void in
        // Get #1 app name using SwiftyJSON
        //Create JSON object using SwiftyJSON class. This automatically does deserialization and all the conditional checks
      //  let json = JSON(data: data)
        //Now we have JSON object (as variable name json) search through the various levels.
        //First we go to feed, then we choose im:name, then we choose
        
        //Note that we need to CHECK THAT THE ENTRY EXISTS. I think that we do this by sending
        //an NSerrorpointer object when calling JSON above, and it will set the value of this
        //according to whether or not the request could be fulfilled (the call itself is no
        //longer optional, as it was in the original RW tutorial
        //ACTUALLY - IT LOOKS LIKE SWIFTYJSON MIGHT JUST RETURN THE EMPTY STRING "" WHEN IT
        //CAN'T FIND ANYTHING AT REQUESTED ENTRY?
        
        //THIS IS THE RIGHT WAY OF WRITING OPTIONAL BINDING AND IT WORKS! - NOTE THAT NEED TO USE STRING AT END, NOT STRINGVALUE. WHY?
        
        DataManager.getTopAppsDataFromItunesWithSuccess { (iTunesData) -> Void in
            
            let json = JSON(data: iTunesData)
        
            if let teacherNames = json["teachers"].array {
        
        println(teacherNames.count)
        
            for ii in teacherNames {
                println(ii)
            }
            
            } else {
                println("RAAA")
            }
        
        
        /*
        
        if let appName:String = json["feedw"]["entry"][0]["im:name"]["label"].string {
            
        println("SwiftyJSON: \(appName)")
        
        } else {
            println("LALALA DIDNT WORK")
        }
        
        
        
        // Get the top ten app names from iTunes and SwiftyJSON
        DataManager.getTopAppsDataFromItunesWithSuccess { (iTunesData) -> Void in
            let json2 = JSON(data: iTunesData)
            //Loop through and print top ten apps.
            println("Top apps!")
            for ii in 0...10 {
            let appName2 = json2["feed"]["entry"][ii]["im:name"]["label"].stringValue
            println("\(ii+1). \(appName2)")
            }
        
            //This is some extra code that assigns each of the top 25 apps to their own AppModel object (see AppModel class), storing all of these objects in an array
            
            //Again, should really check for existence before making this assignment,
            //and since RW tutorial .arrayValue has stopped being optional - use error instead
            let appArray = json["feed"]["entry"].arrayValue
                //2
                var apps = [AppModel]()
                
                //3
                for appDict in appArray {
                    var appName: String? = appDict["im:name"]["label"].stringValue
                    var appURL: String? = appDict["im:image"][0]["label"].stringValue
                    
                    var app = AppModel(name: appName, appStoreURL: appURL)
                    apps.append(app)
                //4
                println(apps)
            }
        }

        
        //This is what the RW tutorial suggests in order to check existence of JSON values
        //before trying to print. However, .stringValue is no longer an options from swiftyJSON
        //objects, instead I think you need to check an error property of the json object...
        
        //if let appName = json["feed"]["entry"][0]["im:name"]["label"].stringValue {
          //  println("SwiftyJSON: \(appName)")
        //}

*/

    }
    
    
    
    
    
    
    //This is the way of doing it with swift optionals
    /*
    
    //Call the getTopApps... method of DataManager, passing it the closure given in curly brackets (note that this is done as a trailing closure, and () not needed after method call as there is only one argument.
    DataManager.getTopAppsDataFromFileWithSuccess { (data) -> Void in
        // Get the number 1 app using optional binding and NSJSONSerialization
        //1
        //Deserialize the json data. This means, taking it from a serial set of strings and turning it into an object (a dictionary?) that is easier to use in swift.
        var parseError: NSError?
        let parsedObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data,
            options: NSJSONReadingOptions.AllowFragments,
            error:&parseError)
        
        //2
        //First check that the deserialized data is a valid dictionary by trying to assign
        //if to a variable topApps (note this is NOT the same as the TopApp.json file!)
        //When this closure is used with the DataManager.getTopApps... method, then it is 
        //passed the TopApps.json file as it's data variable, and so the 'parsedObject' will
        //be the data from the TopApps.json file.
        if let topApps = parsedObject as? NSDictionary {
            //Now check that there is a 'feed' subscript within the data
            if let feed = topApps["feed"] as? NSDictionary {
                //Now check if there is an 'entry' subscript within the feed subscript of the data
                if let apps = feed["entry"] as? NSArray {
                    //Now check that there is at least one app in the feed dictionary (the
                    //first app, at index 0 - which would be the 'top' app.
                    if let firstApp = apps[0] as? NSDictionary {
                        //Now check that there is at least one imname entry
                        if let imname = firstApp["im:name"] as? NSDictionary {
                            //Now check that there is an appName within this dictionary
                            if let appName = imname["label"] as? NSString {
                                //3
                                //Print the name of this first app (if all previous existence
                                //tests have succeeded
                                println("Optional Binding: \(appName)")
                            }
                        }
                    }
                }
            }
        }
    }
    */


  }
}

