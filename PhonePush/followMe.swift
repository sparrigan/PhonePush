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
    let button   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    
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
        
        //Button for retrying for debug
        
        button.frame = CGRectMake(50, 100, 200, 100)
        button.backgroundColor = UIColor(red: 127.0/255.0, green: 220.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        button.setTitle("Reload", forState: UIControlState.Normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.blackColor().CGColor
        button.titleLabel!.font =  UIFont(name: "Arial", size: 30)
        button.addTarget(self, action: "retry:", forControlEvents: .TouchUpInside)
        self.view.addSubview(button)
        
    }
    
    
    func retry(sender: UIButton) {
        if let navi = self.navigationController {
            var VCstack = navi.viewControllers
            //Remove top VC root is at 0, top is at count
            VCstack.removeLast()
            var restartGraph: followMe = followMe()
            //Add nextVC to top of stack
            VCstack.append(restartGraph)
            //Animate transition from old stack to newly formed one
            navi.setViewControllers(VCstack, animated: false)
        }

    }
    
    
}
