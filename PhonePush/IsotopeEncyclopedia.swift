//
//  resultsTable.swift
//  PhonePush
//
//  Created by Nicholas Harrigan on 19/05/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

import UIKit

class  IsotopeEncyclopedia: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
    var titleView = UIView()
    var hlTitle = UILabel()
    var isotopeTitle = UILabel()
    var tView = UITableView(frame: CGRectMake(0,0,500,500), style: UITableViewStyle.Plain)
    var tableData:[String] = ["4 years","235 seconds","23 months","2.5 years"]
    var tableData2:[String] = ["Uranium-235","Polonium-82","Helium-4","Nitrogen-2","Lalalal-23"]
    
    init() {
        
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = UIColor.whiteColor()
        
    }
   
    /*
    convenience init() {
        self.init()
    }
    */
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated);
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Show navigation bar for going back to main activity view
        //navigationController?.setNavigationBarHidden(false, animated: true)
        
        //var tempCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "ss")
        
        //self.tView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "testCell")
        self.tView.registerClass(MyCell.self, forCellReuseIdentifier: "testCell")
        tView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.tView.delegate = self
        self.tView.dataSource = self
        self.tView.tableFooterView = UIView(frame: CGRectZero)
        self.view.addSubview(tView)
        self.tView.rowHeight = UITableViewAutomaticDimension
        self.tView.estimatedRowHeight = 44.0
        var viewsDic = Dictionary<String,UITableView>()
        viewsDic["tView"] = tView
        
        //Autolayout constraint for tableview
        var tableFSH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[tView(10@100)]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDic)
        var tableFSV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[tView(10@100)]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDic)
        
        self.view.addConstraints(tableFSH+tableFSV)
        
        
        var titleviewsDic = Dictionary<String,UIView>()
        titleviewsDic["hlTitle"] = hlTitle
        titleviewsDic["isotopeTitle"] = isotopeTitle
        var metricDic = Dictionary<String,Double>()
        metricDic["fudge"] = 220.0
        
        
        titleView.backgroundColor = UIColor.lightGrayColor()
        hlTitle.text = "Half-life"
        hlTitle.font = UIFont(name: "Arial", size: 40)
        isotopeTitle.text = "Isotope"
        isotopeTitle.font = UIFont(name: "Arial", size: 40)
        hlTitle.setTranslatesAutoresizingMaskIntoConstraints(false)
        isotopeTitle.setTranslatesAutoresizingMaskIntoConstraints(false)
        titleView.addSubview(hlTitle)
        titleView.addSubview(isotopeTitle)
        var titleH = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(50)-[hlTitle]-(>=50)-[isotopeTitle]-(fudge@200)-|", options: NSLayoutFormatOptions(0), metrics: metricDic, views: titleviewsDic)
        var titleV1 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[hlTitle]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: titleviewsDic)
        var titleV2 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[isotopeTitle]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: titleviewsDic)
        
        titleView.addConstraints(titleH+titleV1+titleV2)
        
        
    }
    
    //TABLEVIEW DELEGATE METHODS
    
    //Tells the tableview how many sections we have in table (should default to one anyway)
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //Tells the tableview how many rows we have in a given section (only 1 section here)
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        println(tableData.count)
        return tableData.count
    }
    
    //Method called to pass tavbleview data for requested index
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:MyCell? =
        tableView.dequeueReusableCellWithIdentifier("testCell") as? MyCell
        /*
        if (cell != nil)
        {
        //cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "testCell")
        cell = MyCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "testCell")
        }
        */
        // At this point, we definitely have a cell -- either dequeued or newly created,
        // so let's force unwrap the optional into a UITableViewCell
        cell!.isotopeName.text = self.tableData[indexPath.row]
        cell!.isotopeName.font = UIFont(name: "Arial", size: 50)
        cell!.isotopeData.text = self.tableData2[indexPath.row]
        cell!.isotopeData.font = UIFont(name: "Arial", size: 30)
        //cell!.textLabel!.text = self.tableData[indexPath.row]
        //cell!.textLabel!.font = UIFont(name: "Arial", size: 50)
        //cell!.detailTextLabel!.text = "Look at this subtitle text"
        //cell!.detailTextLabel!.textAlignment = NSTextAlignment.Left
        //cell!.imageView!.image = UIImage(named: "electronbg")
        cell!.accessoryType = UITableViewCellAccessoryType.DetailDisclosureButton
        
        //var cell = tableView.dequeueReusableCellWithIdentifier("testCell") as! UITableViewCell
        //Edit text of UITableViewCell that we will return, getting info from tableData.
        //Note that indexPath has .row and .section indicies.
        //cell.textLabel!.text = self.tableData[indexPath.row]
        //cell.detailTextLabel!.text = "Look at all this information"
        return cell!
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return titleView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return titleView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
    }
    
}




//Custom UITableViewCell class
/*
class MyCell: UITableViewCell {
    
    var isotopeName = UILabel()
    var isotopeImage = UIImageView()
    var isotopeData = UILabel()
    var viewsDic = Dictionary<String, UIView>()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    func configureView() {
        // add and configure subviews here
        
        viewsDic["isotopeName"] = isotopeName as UIView
        viewsDic["isotopeData"] = isotopeData as UIView
        viewsDic["isotopeImage"] = isotopeImage as UIView
        
        isotopeName.setTranslatesAutoresizingMaskIntoConstraints(false)
        isotopeData.setTranslatesAutoresizingMaskIntoConstraints(false)
        isotopeImage.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        contentView.addSubview(isotopeName)
        contentView.addSubview(isotopeData)
        //contentView.addSubview(isotopeImage)
        
        
        var hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[isotopeName]-(>=50)-[isotopeData]-(150@200)-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDic)
        //var hConstraints2 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(100@100)-[isotopeData]-(300@200)-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDic)
        //var hConstraints3 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[isotopeName]-(50@900)-[isotopeData]-(300@200)-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDic)
        
        
        var vConstraint1 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[isotopeName]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDic)
        var vConstraint2 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[isotopeData]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDic)
        
        contentView.addConstraints(hConstraints+vConstraint1+vConstraint2)
        
    }
}
*/








//Works with pre-existing cell layouts:
/*
class tViewTest: UIViewController, UITableViewDataSource, UITableViewDelegate {


var tView = UITableView(frame: CGRectMake(0,0,500,500), style: UITableViewStyle.Plain)
var tableData:[String] = ["One","Two","three","Four"]


init() {

super.init(nibName: nil, bundle: nil)
self.view.backgroundColor = UIColor.whiteColor()

}
//DON'T NEED THIS CONVENIENCE INIT ANYMORE, AS DEAL WITH
//INCREMENTING QUESTION NUMBER IN NEXTQSTN CLASS
convenience init(cQstn: Int) {
self.init()
}
required init(coder aDecoder: NSCoder) {
fatalError("init(coder:) has not been implemented")
}


override func viewDidLoad() {
super.viewDidLoad()

var tempCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "ss")

self.tView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "testCell")
tView.setTranslatesAutoresizingMaskIntoConstraints(false)
self.tView.delegate = self
self.tView.dataSource = self
self.tView.tableFooterView = UIView(frame: CGRectZero)
self.view.addSubview(tView)
self.tView.rowHeight = UITableViewAutomaticDimension
self.tView.estimatedRowHeight = 44.0
var viewsDic = Dictionary<String,UITableView>()
viewsDic["tView"] = tView

//Autolayout constraint for tableview
var tableFSH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[tView(10@100)]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDic)
var tableFSV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[tView(10@100)]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDic)

self.view.addConstraints(tableFSH+tableFSV)

}

//TABLEVIEW DELEGATE METHODS

//Tells the tableview how many sections we have in table (should default to one anyway)
func numberOfSectionsInTableView(tableView: UITableView) -> Int {
return 1
}

//Tells the tableview how many rows we have in a given section (only 1 section here)
func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

println(tableData.count)
return tableData.count
}

//Method called to pass tavbleview data for requested index
func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

var cell:UITableViewCell? =
tableView.dequeueReusableCellWithIdentifier("testCell") as? UITableViewCell
if (cell != nil)
{
cell = UITableViewCell(style: UITableViewCellStyle.Subtitle,
reuseIdentifier: "testCell")
}
// At this point, we definitely have a cell -- either dequeued or newly created,
// so let's force unwrap the optional into a UITableViewCell
cell!.textLabel!.text = self.tableData[indexPath.row]
cell!.textLabel!.font = UIFont(name: "Arial", size: 50)
cell!.detailTextLabel!.text = "Look at this subtitle text"
cell!.detailTextLabel!.textAlignment = NSTextAlignment.Left
cell!.imageView!.image = UIImage(named: "electronbg")
cell!.accessoryType = UITableViewCellAccessoryType.DetailDisclosureButton

//var cell = tableView.dequeueReusableCellWithIdentifier("testCell") as! UITableViewCell
//Edit text of UITableViewCell that we will return, getting info from tableData.
//Note that indexPath has .row and .section indicies.
//cell.textLabel!.text = self.tableData[indexPath.row]
//cell.detailTextLabel!.text = "Look at all this information"
return cell!
}

}
*/
