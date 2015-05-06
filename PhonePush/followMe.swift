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
    var graph1:graphPlotter = graphPlotter()
    var gD:UIView = UIView()
    
    //THIS WILL BE THE VC FOR MANAGING THE RUNNING OF THIS ACTIVITY
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        var lala = qstnGraph.getXGraph(30.0, yLimit: 10.0, timeRes: 0.5)
        
        var timeArray = lala.0
        //var timeArray:[Double] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
        var accelArray = lala.1
        //var accelArray:[Double] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
        
        graph1 = graphPlotter(vSize: self.view.frame, xArray: timeArray, yArray: accelArray)
        graph1.loadgraph()
        
        gD = graph1.hostView as UIView
        
        self.view.addSubview(graph1)
    }
    
    
    
}
