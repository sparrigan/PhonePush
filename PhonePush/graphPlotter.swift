//
//  graphPlotter.swift
//  PhonePush
//
//  Created by Nicholas Harrigan on 11/04/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

import UIKit

//Class that actually does scatter plotting. Can be called repeatedly in different subviews
class graphPlotter: UIView, CPTPlotDataSource, CPTScatterPlotDelegate {
    
    //Arrays for graph data
    var yArray:[Double] = []
    var xArray:[Double] = []
    //Dic for storing what values are associated with what plot for when delegate 
    //function is called.
    var plotDic = [CPTPlot:([Double],[Double])]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    //Custom init takes in data to be plotted, as well as the size of the plot
    convenience init(vSize:CGRect, xArray:[Double], yArray: [Double]) {
        //Set frame size and assign variables to local
        self.init(frame: vSize)
        self.yArray = yArray
        self.xArray = xArray
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Instances need for plotting (hostingView holds settings)
    var hostView: CPTGraphHostingView = CPTGraphHostingView()
    var graph:CPTGraph!
    
    func loadgraph() {
        //Setup hostview, make it same size as current view
        //hostView = CPTGraphHostingView(frame: CGRectMake(0,0,0,0))
        hostView = CPTGraphHostingView(frame: self.bounds)
        hostView.layer.cornerRadius = 10
        hostView.layer.borderColor = UIColor.grayColor().CGColor
        hostView.layer.borderWidth = 2.0
        
        //Uncomment this for graph as large as whole screen
        //hostView = CPTGraphHostingView(frame: self.view.frame)
        
        addSubview(hostView)
        
        // Create a CPTGraph object and add to hostView
        graph = CPTXYGraph(frame: hostView.bounds)
        hostView.hostedGraph = graph
        
        // Get the (default) plotspace from the graph so we can set its x/y ranges
        var plotSpace = graph.defaultPlotSpace
        
        //Set the plotting range for the axes
        var maxY = yArray.reduce(-Double.infinity, combine: { max($0, $1) })
        var minY = yArray.reduce(Double.infinity, combine: { min($0, $1) })
        
        var maxX = xArray.reduce(-Double.infinity, combine: { max($0, $1) })
        var minX = xArray.reduce(Double.infinity, combine: { min($0, $1) })
        
        // Note that these CPTPlotRange are defined by START and LENGTH (not START and END) !!
        //So we make the relevant lengths etc... from the min and max values above
        plotSpace.setPlotRange(CPTPlotRange(location: minX, length: maxX-minX), forCoordinate: CPTCoordinate.X)
        //Note that we add a 1% offset to the y-range in order not to crop off lines
        var offsetFix = (maxY-minY)*0.01
        plotSpace.setPlotRange(CPTPlotRange(location: (minY-offsetFix), length: (maxY-minY)+(2*offsetFix)), forCoordinate: CPTCoordinate.Y)
        //Stop user from being able to move graph about by clicking etc...
        plotSpace.allowsUserInteraction = false
        
        //Create plot (note that the x/y values are set by delegate below)
        var plot:CPTScatterPlot = CPTScatterPlot(frame: CGRectZero)
        //Set this as the delegate for getting data etc...
        plot.dataSource = self
        
        //Change line style (note: need to create linestyle object first)
        var myLineStyle:CPTMutableLineStyle = CPTMutableLineStyle()
        myLineStyle.lineColor = CPTColor.redColor()
        myLineStyle.lineWidth = 2.0
        plot.dataLineStyle = myLineStyle
        
        //Add created plot to plotspace of graph we created.
        graph.addPlot(plot, toPlotSpace: graph.defaultPlotSpace)
        //THIS STATEMENT COULD BE PROBLEMATIC...
        //graph.defaultPlotSpace.scaleToFitPlots(graph.allPlots())
        
        //Call initPlot function that then calls various functions to set up plot
        
        plotDic[plot as CPTPlot] = (xArray,yArray)
        
        
        self.initPlot()
        
    }
    
    //Function for adding another plot to the existing graph
    func addGraph(xVals:[Double], yVals: [Double]) {
        
        
        var plot:CPTScatterPlot = CPTScatterPlot(frame: CGRectZero)
        //Set this as the delegate for getting data etc...
        plot.dataSource = self
        
        //Change line style (note: need to create linestyle object first)
        var myLineStyle:CPTMutableLineStyle = CPTMutableLineStyle()
        myLineStyle.lineColor = CPTColor.greenColor()
        myLineStyle.lineWidth = 2.0
        plot.dataLineStyle = myLineStyle
        
        //Add created plot to plotspace of graph we created.
        graph.addPlot(plot, toPlotSpace: graph.defaultPlotSpace)
        //THIS STATEMENT COULD BE PROBLEMATIC...
        //graph.defaultPlotSpace.scaleToFitPlots(graph.allPlots())
        
        //Call initPlot function that then calls various functions to set up plot
        plotDic[plot as CPTPlot] = (xVals,yVals)
        

    }
    
    
    func initPlot() {
        //Ronseal
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
        //y.title = "Acceleration"
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
    
    
    //Required by CorePlot delegate: Returns the number of points to be plotted
    func numberOfRecordsForPlot(plot: CPTPlot!) -> UInt {
        var tempVal = plotDic[plot]!
        
        return UInt(tempVal.0.count)
    }
    
    //Required by CorePlot delegate: Returns the x and y values for given index
    //(fieldEnum parameter determines whether coreplot is asking for x or y)
    func numberForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex idx: UInt) -> AnyObject {
        //removed ! from AnyObject above

        var tempVal = plotDic[plot]!
        
        //Check whether CorePlot wants x or y values and return appropriate value
        //at the index that CorePlot requested
        if fieldEnum.hashValue == CPTScatterPlotField.X.hashValue {
            

            return tempVal.0[Int(idx)]
        } else {
            return tempVal.1[Int(idx)]
        }
    }
    
}