//
//  followMe.swift
//  PhonePush
//
//  Created by Nicholas Harrigan on 04/05/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

import UIKit


class followMe: UIViewController  {
    
    var qstnGraph:calcQstnGraph = calcQstnGraph()
    
    //THIS WILL BE THE VC FOR MANAGING THE RUNNING OF THIS ACTIVITY
 
    override func viewDidLoad() {
        
        self.view.backgroundColor = UIColor.blueColor()
        
        var lala = qstnGraph.getXGraph(30.0, yLimit: 20.0, timeRes: 0.5)
        
        println(lala)
    }
    
    
}
