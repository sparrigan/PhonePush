//
//  DataManager.swift
//  TopApps
//
//  Created by Dani Arnaout on 9/2/14.
//  Edited by Eric Cerney on 9/27/14.
//  Copyright (c) 2014 Ray Wenderlich All rights reserved.
//

import Foundation
import swiftyJSON

//let TopAppURL = "https://itunes.apple.com/us/rss/topgrossingipadapplications/limit=25/json"

let TopAppURL = "http://tinyteacher.ngrok.com/teachers"


class serverCall {
    
    
    class func loadDataFromURL(url: NSURL, completion:(data: NSData?, error: NSError?) -> Void) {
        
        var session = NSURLSession.sharedSession()
        
        // Use NSURLSession to get data from an NSURL
        let loadDataTask = session.dataTaskWithURL(url, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            //println(error)
            
            if let responseError = error {
                completion(data: nil, error: responseError)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    var statusError = NSError(domain:"com.raywenderlich", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
                    completion(data: nil, error: statusError)
                } else {
                    completion(data: data, error: nil)
                }
            }
        })
        
        loadDataTask.resume()
    }
    
    class func getFromServer(callURL: String, success: ((iTunesData: NSData!) -> Void)) {
        //1
        loadDataFromURL(NSURL(string: callURL)!, completion:{(data, error) -> Void in
            //2
            
            if let urlData = data {
                //3
                success(iTunesData: urlData)
                
            }
        })
    }
    
    
}