//
//  resultsGraph.swift
//  PhonePush
//
//  Created by Nicholas Harrigan on 12/06/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

import UIKit

class resultsGraph: UIViewController {
    
    var plotYData:[Double] = []
    var graph:graphPlotter = graphPlotter()
    var graphHostView:UIView = UIView()
    
    init(plotYData: [Int]) {
    
        for ii in 0...plotYData.count-1 { self.plotYData.append(Double(plotYData[ii])) }
        
        super.init(nibName: nil, bundle: nil)
    }
    
   
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated);
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        //Get time values
        var plotXData:[Double] = []
        for ii in 0...plotYData.count-1 { plotXData.append(Double(ii)) }
        println("plotXData is.... \(plotXData)")
        //Convert y values into Double types
        
        
        graph = graphPlotter(vSize: CGRectMake(0,0,300,300), xArray: plotXData, yArray: plotYData)
        graph.loadgraph()
        println(plotXData)
        println("")
        println(plotYData)
        println(plotXData.count)
        println(plotYData.count)
        
        graphHostView = graph.hostView as UIView
        
        graphHostView.backgroundColor = UIColor.redColor()
        
        self.view.addSubview(graphHostView)
        
        
        //Place graph in center using autolayout
        graphHostView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        var viewDic = ["graphHostView": graphHostView]
        
        var graphH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[graphHostView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewDic)
        var graphV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[graphHostView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewDic)
       self.view.addConstraints(graphH+graphV)
        
        

    
        
    }
    
    
}
