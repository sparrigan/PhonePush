//
//  graphPlotter.swift
//  PhonePush
//
//  Created by Nicholas Harrigan on 11/04/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

import UIKit
//import CorePlot

class graphPlotter: UIView, CPTPlotDataSource, CPTScatterPlotDelegate {
    
    
    var yArray:[Double] = []
    var xArray:[Double] = []
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
    }
    
    
    //Setup own init parameters here...
    convenience init(vSize:CGRect, xArray:[Double], yArray: [Double]) {
        
        self.init(frame: vSize)
        
        self.yArray = yArray
        self.xArray = xArray
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var hostView: CPTGraphHostingView!
    var graph:CPTGraph!
    
    func loadgraph() {
        
        
        // We need a hostview, you can create one in IB (and create an outlet) or just do this:
        //CPTGraphHostingView* hostView = [[CPTGraphHostingView alloc] initWithFrame:self.view.frame];
        //[self.view addSubview: hostView];
        
        
        //Here have made hostview the same size as the current view that it is in.
        hostView = CPTGraphHostingView(frame: self.bounds)
        hostView.layer.cornerRadius = 10
        hostView.layer.borderColor = UIColor.grayColor().CGColor
        hostView.layer.borderWidth = 2.0
        
        
        //Make as large as screen:
        //hostView = CPTGraphHostingView(frame: self.view.frame)
        addSubview(hostView)
        
        // Create a CPTGraph object and add to hostView
        //CPTGraph* graph = [[CPTXYGraph alloc] initWithFrame:hostView.bounds];
        //hostView.hostedGraph = graph;
        
        graph = CPTXYGraph(frame: hostView.bounds)
        hostView.hostedGraph = graph
        
        // Get the (default) plotspace from the graph so we can set its x/y ranges
        //CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
        
        var plotSpace = graph.defaultPlotSpace
        
        // Note that these CPTPlotRange are defined by START and LENGTH (not START and END) !!
        //[plotSpace setYRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( 0 ) length:CPTDecimalFromFloat( 16 )]];
        //[plotSpace setXRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( -4 ) length:CPTDecimalFromFloat( 8 )]];
        
        var maxY = yArray.reduce(-Double.infinity, combine: { max($0, $1) })
        var minY = yArray.reduce(Double.infinity, combine: { min($0, $1) })
        
        var maxX = xArray.reduce(-Double.infinity, combine: { max($0, $1) })
        var minX = xArray.reduce(Double.infinity, combine: { min($0, $1) })
        
        
        
        plotSpace.setPlotRange(CPTPlotRange(location: minX, length: maxX-minX), forCoordinate: CPTCoordinate.X)
        //plotSpace.setPlotRange(CPTPlotRange(location: 0, length: timeDbl[timeDbl.count-1]), forCoordinate: CPTCoordinate.X)
        plotSpace.setPlotRange(CPTPlotRange(location: minY, length: maxY-minY), forCoordinate: CPTCoordinate.Y)
        plotSpace.allowsUserInteraction = false
        
        
        
        // Create the plot (we do not define actual x/y values yet, these will be supplied by the datasource...)
        //CPTScatterPlot* plot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
        
        
        var plot:CPTScatterPlot = CPTScatterPlot(frame: CGRectZero)
        
        // Let's keep it simple and let this class act as datasource (therefore we implemtn <CPTPlotDataSource>)
        plot.dataSource = self
        
        //In order to change dataLineStyle you have to create a
        //CPTMutableLineStyle object and change the properties of *that*
        //and then assign that to the plots dataLineStyle property.
        var myLineStyle:CPTMutableLineStyle = CPTMutableLineStyle()
        myLineStyle.lineColor = CPTColor.redColor()
        myLineStyle.lineWidth = 2.0
        plot.dataLineStyle = myLineStyle
        
        // Finally, add the created plot to the default plot space of the CPTGraph object we created before
        //[graph addPlot:plot toPlotSpace:graph.defaultPlotSpace];
        
        graph.addPlot(plot, toPlotSpace: graph.defaultPlotSpace)
        
        
        //Call initPlot function that then calls various functions to set up plot
        
        self.initPlot()
        
    }
    
    func initPlot() {
        
        configureGraph()
        configureAxes()
        
    }
    
    
    func configureGraph(){
        
        //Apply a theme
        graph.applyTheme(CPTTheme(named: kCPTPlainWhiteTheme))
        graph.plotAreaFrame.borderLineStyle = nil
        graph.plotAreaFrame.paddingLeft = 50
        graph.plotAreaFrame.paddingRight = 10
        graph.plotAreaFrame.paddingTop = 30
        graph.plotAreaFrame.paddingBottom = 30
        
        
    }
    
    func configureAxes() {
        
        //Create styles:
        var axisTitleStyle:CPTMutableTextStyle  = CPTMutableTextStyle()
        axisTitleStyle.color = CPTColor.blackColor()
        axisTitleStyle.fontName = "Helvetica-Bold"
        axisTitleStyle.fontSize = 12.0
        var axisLineStyle:CPTMutableLineStyle = CPTMutableLineStyle()
        axisLineStyle.lineWidth = 2.0
        axisLineStyle.lineColor = CPTColor.blackColor()
        var axisTextStyle:CPTMutableTextStyle = CPTMutableTextStyle()
        axisTextStyle.color = CPTColor.blackColor()
        axisTextStyle.fontName = "Helvetica-Bold"
        axisTextStyle.fontSize = 11.0
        var tickLineStyle:CPTMutableLineStyle  = CPTMutableLineStyle()
        tickLineStyle.lineColor = CPTColor.blackColor()
        tickLineStyle.lineWidth = 2.0
        var gridLineStyle:CPTMutableLineStyle = CPTMutableLineStyle()
        tickLineStyle.lineColor = CPTColor.blackColor()
        tickLineStyle.lineWidth = 1.0
        
        
        
        //Here we get the axisSet property from the hostView for our graphs. The hostview
        //is where we set all the options like axes formatting etc...
        
        var axisSet:CPTXYAxisSet  = CPTXYAxisSet(layer: hostView.hostedGraph.axisSet);
        // 3 - Configure the x-axis
        
        //Get the x-axis configuration object
        var x:CPTAxis = axisSet.xAxis
        //Setup x axis formating
        x.labelingPolicy = CPTAxisLabelingPolicy.None
        x.title = "time"
        x.titleTextStyle = axisTitleStyle
        x.titleOffset = 5.0
        x.axisLineStyle = axisLineStyle
        x.labelTextStyle = axisTextStyle
        x.majorTickLineStyle = axisLineStyle
        x.majorTickLength = 4.0
        x.tickDirection = CPTSign.Negative
        
        
        
        //NOTE THAT THE BELOW METHOD OF GENERATING LABELS ONLY WORKS WHEN WE HAVE
        //AN ARRAY OF ORDERED POSITIVE VALUES IN WHICH WE WISH TO START PLOTTING FROM ZERO
        //(EG: TIME) MORE LOGIC IS NEEDED TO DEAL WITH NEGATIVE VALUES ETC...
        
        //Generate labels (these two variables store labels, like an array)
        var biggestXVal = Int(ceil(xArray[xArray.count-1]))
        //var biggestXVal = xArray.count
        var xLabels:NSMutableSet = NSMutableSet(capacity: biggestXVal)
        var xLocations:NSMutableSet = NSMutableSet(capacity: biggestXVal)
        //Generate labels to use and specify their location (this could be automated in a loop)
        //tickLocation appears to specify the actual location (x-value) along the x-axes that
        //the label appears
        
        for i in 1...biggestXVal {
            
            var label:CPTAxisLabel = CPTAxisLabel(text: String(i), textStyle: x.labelTextStyle)
            label.tickLocation = i
            label.offset = x.majorTickLength
            
            xLabels.addObject(label)
            xLocations.addObject(i)
        }
        
        
        
        //Use the 'arrays' to populate the labels and CHECKMARKS for the x axis.
        x.axisLabels = xLabels as Set<NSObject>
        x.majorTickLocations = xLocations as Set<NSObject>
        
        //Getting chart to automatically set y values:
        var y:CPTAxis = axisSet.yAxis
        
        axisSet.yAxis.axisConstraints = CPTConstraints.constraintWithLowerOffset(0.0)
        //y.title = "Energy"
        y.titleTextStyle = axisTitleStyle;
        y.titleDirection = CPTSign.Negative
        y.titleOffset = 30
        y.axisLineStyle = axisLineStyle;
        y.labelingPolicy = CPTAxisLabelingPolicy.Automatic
        y.labelTextStyle = axisTextStyle;
        y.labelOffset = 2.0
        y.majorTickLineStyle = axisLineStyle;
        y.majorTickLength = 4.0
        y.minorTickLength = 2.0
        y.tickDirection = CPTSign.Negative
        y.preferredNumberOfMajorTicks = 8
        
        
    }
    
    
    //Required by CorPlot delegate: Returns the number of points to be plotted
    func numberOfRecordsForPlot(plot: CPTPlot!) -> UInt {
        return UInt(xArray.count)
    }
    

    
    //Required by CorePlot delegate: Returns the x and y values for given index
    //(fieldEnum parameter determines whether coreplot is asking for x or y)
    func numberForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex idx: UInt) -> AnyObject! {
        
        println("CALLED IT")
        //var x:Int = index - 4
        
        if fieldEnum.hashValue == CPTScatterPlotField.X.hashValue {
            //println("Looking for X value and got \(xArray[Int(idx)])")
            return xArray[Int(idx)]
            
        } else {
            //println("Looking for Y value and got \(yArray[Int(idx)])")
            return yArray[Int(idx)]
            
        }
        
    }
}