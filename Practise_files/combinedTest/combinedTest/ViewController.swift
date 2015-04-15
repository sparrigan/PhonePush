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
        
        
        
        serverCall.getFromServer("http://tinyteacher.ngrok.com/teachers", success: {(iTunesData) -> Void in
            
                
                let json = JSON(data: iTunesData)
                
                if let teacherNames = json["teachers"].array {
                    
                    println(teacherNames.count)
                    
                    for ii in teacherNames {
                        println(ii)
                    }
                    
                } else {
                    println("RAAA")
                }

            
                    })
    }
}
