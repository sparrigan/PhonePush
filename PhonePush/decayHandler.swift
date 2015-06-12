//
//  decayHandler.swift
//  PhonePush
//
//  Created by Nicholas Harrigan on 09/06/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

import UIKit

class decayHandler: NSObject, UITableViewDataSource {
    
    //Stores references to all nuclei
    var nucleiArray:[UIImageView]
    //Stores integer values used to refer to active elements of nucleiArray
    var activeNuclei:[Int] = []
    //Stores which nuclei decayed at each time-step
    var timeDic = Dictionary<Int, [Int]?>()
    var decayProb:Double
    var numberCount:[Int] = []
    
    //Initialise with reference to array of nuclei UIImageViews that are in UICollectionView
    init(nucleiArray:[UIImageView],decayProb:Double) {
        self.nucleiArray = nucleiArray
        //Initialise activeNuclei array with all nuclei to begin with
        for ii in 0...(nucleiArray.count-1) {activeNuclei.append(ii)}
        self.decayProb = decayProb
        //Add the total number active at time zero
        numberCount.append(nucleiArray.count)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Method for updating nuclei for next time-step - pass time in smallest unit used
    func forwardTimeStep(currentTime:Int) {
        //Check whether already have a dictionary element for the time we want to move to
        if timeDic[currentTime+1] == nil {
            //No data for the next time so randomly decay some nuclei
            //Note that is important to still store a nil value in timeDic and deal with that
            //so know difference between a new time that needs calculating and just one that had no decays
            
            //Get the numbers for nuclei that will decay in next time step
            var decayThisTime = decayWithProb()
            
            //Change images of these nuclei to show they have decayed - first check if there are 
            //any to decay
            if decayThisTime != nil {
                for jj in decayThisTime! {
                    nucleiArray[jj].image = UIImage(named: "nucleus_fade")
                }
            }
            //Write to timeDic which nuclei we decayed at the next time-step
            timeDic[currentTime+1] = decayThisTime
            //Append to array this new number of active nuclei (N(t)) for the next time-step
            numberCount.append(activeNuclei.count)
            
        } else {
            println("GOT A TIMEDIC VALUE GOING FORWARDS")
            //DECAY THE NUCLEI SPECIFIED IN THE TIMEDIC HERE - CHECK WHETHER LIST IS NIL OR NOT - IF NIL THEN NO DECAYS HAPPENED AT THAT TIME-STEP
            if let deadNuclei = timeDic[currentTime+1]!  {
                println("Got a list of nuclei to decay as well")
                for ii in deadNuclei {
                    //Kill the nuclei for next time-step
                    nucleiArray[ii].image = UIImage(named: "nucleus_fade")
                    //Remove these indicies from activeNuclei array
                    activeNuclei = activeNuclei.filter {$0 != ii}
                }
                
            }
        }
    }
    
    //Method for updating nuclei for previous time-step - pass time in smallest unit used
    func backwardTimeStep(currentTime:Int) {
        //Only deal with nuclei if the dic entry for the time-step that erased them is non-nil
        if let deadNuclei = timeDic[currentTime]!  {
            for ii in deadNuclei {
                //Bring nuclei back that were erased in current time-step.
                nucleiArray[ii].image = UIImage(named:"nucleus")
                //Update the active array to include these as now being active again
                activeNuclei.append(ii)
            }
            
        }
    }
    
    //Returns a list of currently active nuclei that should decay given currently active nuclei
    //and decay probability for this element. Returns nil if no nuclei decayed.
    func decayWithProb() -> [Int]? {
        var returnArray:[Int]?
        //Go through all currently active nuclei and roll the dice to see if they should decay
        //Loop downwards so that can remove nuclei indicies as they are made inactive
        for var index = activeNuclei.count-1; index >= 0; --index {
            var ii = activeNuclei[index]
            if randomNum() <= decayProb {
                //Have had a decay at this nuclei, add integer index to return array
                if (returnArray?.append(ii)) == nil {
                    returnArray = [ii]
                }
                //And now remove this element from the array since it is no longer active
                activeNuclei.removeAtIndex(index)
            }
        }
        return returnArray
    }
    
    func randomNum() -> Double {
        return Double(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func randomNum(min: Double, max: Double) -> Double {
        return randomNum() * (max-min) + min
    }
    
    
    
    //Delegate methods for tableView that displays N(t) data
    //Tells the tableview how many sections we have in table (should default to one anyway)
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //Tells the tableview how many rows we have in a given section (only 1 section here)
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if timeDic.count != 0 {
            return timeDic.count
        } else {
            //If haven't decayed any yet then still include the time = 0 full count
            return 1
        }
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
        cell!.isotopeName.text = String(indexPath.row)
        cell!.isotopeName.font = UIFont(name: "Arial", size: 50)
        cell!.isotopeData.text = String(numberCount[indexPath.row])
        cell!.isotopeData.font = UIFont(name: "Arial", size: 30)
        //cell!.textLabel!.text = self.tableData[indexPath.row]
        //cell!.textLabel!.font = UIFont(name: "Arial", size: 50)
        //cell!.detailTextLabel!.text = "Look at this subtitle text"
        //cell!.detailTextLabel!.textAlignment = NSTextAlignment.Left
        //cell!.imageView!.image = UIImage(named: "electronbg")
        //cell!.accessoryType = UITableViewCellAccessoryType.DetailDisclosureButton
        
        //var cell = tableView.dequeueReusableCellWithIdentifier("testCell") as! UITableViewCell
        //Edit text of UITableViewCell that we will return, getting info from tableData.
        //Note that indexPath has .row and .section indicies.
        //cell.textLabel!.text = self.tableData[indexPath.row]
        //cell.detailTextLabel!.text = "Look at all this information"
        return cell!
    }
    
}
