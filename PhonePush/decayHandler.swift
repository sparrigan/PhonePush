//
//  decayHandler.swift
//  PhonePush
//
//  Created by Nicholas Harrigan on 09/06/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

//PROB IS THAT ARE NOT UPDATING UP UNTIL ALL CALCULATED TIMES IN TABLE ALWAYS ONE SEOND BELOW CURRENT (AS DISPLAYED BY IMAGES)

import UIKit

class decayHandler: NSObject, UITableViewDataSource {
    
    //Stores references to all nuclei
    var nucleiArray:[UIImageView]
    //Stores integer values used to refer to active elements of nucleiArray
    var activeNuclei:[Int] = []
    //Stores which nuclei decayed at each time-step
    var timeDic = Dictionary<Int, [Int]>()
    var numberCount:[Int] = []
    var highestCalculatedTime = 0
    var lambda:Double
    var orderedDecayTimes:[Int] = []
    var plotDataArray:[Int]
    
    //Initialise with reference to array of nuclei UIImageViews that are in UICollectionView
    init(nucleiArray:[UIImageView], lambda: Double) {
        self.nucleiArray = nucleiArray
        //Initialise activeNuclei array with all nuclei to begin with
        for ii in 0...(nucleiArray.count-1) {activeNuclei.append(ii)}
        //Add the total number active at time zero
        numberCount.append(nucleiArray.count)
        self.lambda = lambda
        //Initialise plotDataArray (contains number of nuclei at each timestep
        plotDataArray = [nucleiArray.count]
        //plotDataArray = []
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    //PROBLEM!!!! GET CORRECT STATISTICS WHEN JUMP FORWARDS IN SECONDS, BUT NOT WHEN JUMP
    //FORWARDS IN MINUTES (HALF LIFE COMES OUT ABOUT 1 SECOND TOO LONG!
    
    func forwardTime(currentTime:Int, timeForward:Int) -> Int {
        //First will check whether we have any existing entries that we should go ahead to between currentTime and finalTime
        var finalTime = currentTime+timeForward
        
        //println("finalTime = \(finalTime)")
        //println("highestCalculatedTime = \(highestCalculatedTime)")
        //Check whether highestTime is above start of this currenTime before try and look for any entries
        
        if highestCalculatedTime > currentTime {
            //There has been a calc above this - check for entries in timeDic
            for (time,entry) in timeDic {
                if time > currentTime && time <= finalTime {
                    //Kill the nuclei at specified locations
                    killNuclei(entry)
                }
            }
        }
        

        //Only carry on if there are any nuclei left after updating for previously stored timeDic values
        if activeNuclei.count > 0 {
            
            //Now check that highestTime is not beyond our current range - if so then any remaining timesteps must be blanks.
            if highestCalculatedTime < finalTime {
    
                //There are some elements that need to be calculated (don't need to worry about highestTime < currentTime - can't happen as we start at currentTime)
                //Remaining time
                var remainingTimeSpan = finalTime - highestCalculatedTime
                
                //Calculate decayProb over time period (lambda should be in /s)
                var decayProbSec = 1 - exp(-lambda)
                var decayProbRemainingTimeSpan = 1 - exp(-lambda*Double(remainingTimeSpan))
                
                //Find number that need to decay in remaining time interval via poisson
                var numberToDecay = poissonRandomNum(Double(activeNuclei.count)*decayProbRemainingTimeSpan)
                
                //Make sure that number to decay does not exceed the number of nuclei remaining
                if numberToDecay > activeNuclei.count { numberToDecay = activeNuclei.count }
                
                //Temporary array to store decaying times before ordering them
                var tempDecayTimes:[Int] = []
                
                //Loop through and choose this many nuclei to decay over the time interval
                if numberToDecay > 0 {
                    for ii in 1...numberToDecay {
                        //Choose which nuclei to decay from activeNuclei array (uniform dist.)
                        var nucleiToDecayActiveNucleiIndex = Int(round(randomNum(0.0,Double(activeNuclei.count-1))))
                        var nucleiToDecay = activeNuclei[nucleiToDecayActiveNucleiIndex]
                        
                        //Choose time at which time they will decay by sampling from geom. dist. (normalised by Bayes over interval)
                        var timeNucleiDecays = geomRandomNum(decayProbSec, Double(remainingTimeSpan))+highestCalculatedTime
                        //println("Time of decay is: \(timeNucleiDecays)")
                        
                        //Safety check - shouldn't ever be called:
                        if timeNucleiDecays > finalTime { timeNucleiDecays = finalTime }
                        //Update timeDic key for this time (checking whether it already exists first and if so then appending)
                        
                        if timeDic[timeNucleiDecays] != nil {
                            timeDic[timeNucleiDecays]!.append(nucleiToDecay)
                        } else {
                            timeDic[timeNucleiDecays] = [nucleiToDecay]
                            //Only add decay time if it hasn't been added before
                            tempDecayTimes.append(timeNucleiDecays)
                            
                        }
                        
                        //Kill this nuclei
                        killNuclei([nucleiToDecay],listofActiveNucleiIndiciesToKill: [nucleiToDecayActiveNucleiIndex])
                    }
                }
            
                //Sort the new decay times and add to main orderedDecayTimes array
                if tempDecayTimes.count > 0 {
                    tempDecayTimes.sort() {$0<$1}
                    orderedDecayTimes += tempDecayTimes
                }
                
                //Update highestTime to either finalTime - or if all decay, last decay time
                if activeNuclei.count > 0 {
                    highestCalculatedTime = finalTime
                } else {
                    //Unwrap optional 'last' value of array - nil if array is empty
                    if let highestTimeAllDecayed = orderedDecayTimes.last {
                        //Note that +1 since will also be a 'zero' value following
                        //orderDecayTimes.last and want results table to loop to this high
                        highestCalculatedTime = highestTimeAllDecayed + 1
                    } else {
                        highestCalculatedTime = 0
                    }

                }
                
            }
                
        }
        //Return the amount of time we actually progressed, to be displayed on UI
        return highestCalculatedTime - currentTime
        
    }
    
    
    
    
    
    
    //Function that removes a list of nuclei from activeNuclei and changes their images accordingly
    //Optionally also pass list of activeNuclei indicies in correspondence with listToKill entries. Saves computation
    func killNuclei(listToKill:[Int], listofActiveNucleiIndiciesToKill: [Int] = []) {
       
        
        for ii in listToKill {
            nucleiArray[ii].image = UIImage(named: "nucleus_fade")
        }
        
        if listofActiveNucleiIndiciesToKill.count > 0 {
            for arrayIndex in listofActiveNucleiIndiciesToKill {
                activeNuclei.removeAtIndex(arrayIndex)
            }
        } else {
            for ii in listToKill {
                activeNuclei = activeNuclei.filter {$0 != ii}
            }
        }
    }

    
    
    
    
    
    //OLD FORWARDS TIME STEP FUNCTIONS
/*
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
    
   
    
    //Decay nuclei and update relevant arrays for one large timestep forwards
    func forwardLargeTimeStep(currentTime:Int) -> Int {
        println("FORWARDLARGETIMESTEP")
        //First check whether any of the small timesteps between now and now +largeTimeStep
        //are already filled in, and if so then deal decays from then on by poisson sampling
        
        //Find the highest timeDic entry within the large timestep about to take
        //Note relies on always having up to current value
        var lowestExistingValueInRange = min(60,timeDic.count-currentTime)+currentTime
        
        //Update activeNuclei array to highest currently populated time within timestep
        //Combine all the arrays for each timeDic in the range and then
        //change nuclei images and adapt activeNuclei
        if lowestExistingValueInRange > currentTime {
            var deadNuclei:[Int] = []
            //Collect together all the nuclei that need to decay over range considered
            for jj in currentTime+1...lowestExistingValueInRange {
                if let currentDead = timeDic[jj]! {
                    deadNuclei += currentDead
                }
            }
            //Change images and update activeNuclei array
            for ii in deadNuclei {
                //Kill the nuclei to bring up to date
                nucleiArray[ii].image = UIImage(named: "nucleus_fade")
                //Remove these indicies from activeNuclei array
                activeNuclei = activeNuclei.filter {$0 != ii}
            }
        }
        
        if lowestExistingValueInRange < currentTime+60 {
            for timeToCalcFor in lowestExistingValueInRange+1...currentTime+60 {
                
                if activeNuclei.count > 0 {
                    
                    println("Will run calculation for filling in dic at \(timeToCalcFor)")
                    println("This is \(timeToCalcFor - currentTime - 1) seconds since last calc")
                    println(activeNuclei.count)
                    //Get a random number to decay this timestep according to Poisson distribution
                    var numToDecay = poissonRandomNum(decayProb*Double(activeNuclei.count))
                    //Assign timeDic value for this new (small)timestep.
                    timeDic[timeToCalcFor] = [Int]?()
                    //Randomly (uniformly) choose this many active nuclei to decay this timestep
                    if numToDecay > 0 {
                        timeDic[timeToCalcFor] = []
                        for jj in 1...numToDecay {
                            var decayNucleiWithThisArrayIndex = Int(round(randomNum(0,Double(activeNuclei.count-1))))
                            var nucleusToDecay:Int = activeNuclei[decayNucleiWithThisArrayIndex]
                            nucleiArray[nucleusToDecay].image = UIImage(named: "nucleus_fade")
                            timeDic[timeToCalcFor]!!.append(nucleusToDecay)
                            activeNuclei.removeAtIndex(decayNucleiWithThisArrayIndex)
                            
                        }
                    }
                    //If there is no decays then timeDic entry will remain as [Int]? nil value
                    
                    //Update the numberCount for this new number of decayed nuclei at a timestep
                    numberCount.append(activeNuclei.count)
                    
                    println("New timeDic at \(timeToCalcFor) is \(timeDic[timeToCalcFor])")
                        
                } else {
                    println("Returning \(timeToCalcFor - currentTime - 1)")
                    return timeToCalcFor - currentTime - 1
                }
            }
            return 60
        } else {
            return 60
        }
        
        /*
        for timeConsidered in currentTime+1...currentTime+60 {
            if timeConsidered <= timeDic.count-1 {
                
            } else {
                break
            }
        }
        */

    }
*/


    
    /*
    //Method for updating nuclei for previous time-step - pass time in smallest unit used
    func backwardTimeStep(currentTime:Int) {
        //Only deal with nuclei if the dic entry for the time-step that erased them is non-nil
        if let deadNuclei = timeDic[currentTime]  {
            for ii in deadNuclei {
                //Bring nuclei back that were erased in current time-step.
                nucleiArray[ii].image = UIImage(named:"nucleus")
                //Update the active array to include these as now being active again
                activeNuclei.append(ii)
            }
            
        }
    }
    */
    
    /*
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
    */
    /*
    func randomNum() -> Double {
        return Double(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func randomNum(min: Double, max: Double) -> Double {
        return randomNum() * (max-min) + min
    }
    */
    
    
    
    //Delegate methods for tableView that displays N(t) data
    //Tells the tableview how many sections we have in table (should default to one anyway)
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //Tells the tableview how many rows we have in a given section (only 1 section here)
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //println("!!!!! - \(highestCalculatedTime)")
        //println("PLOTDATARAY SIZE: \(plotDataArray.count)")
        //Determine number of points to plot in chosen unit
        return highestCalculatedTime + 1
        
        /*
        if timeDic.count != 0 {
            return timeDic.count
        } else {
            //If haven't decayed any yet then still include the time = 0 full count
            return 1
        }
        */
    }

    var totalSubtracted:Int = 0
    
    func generatePlottingArray() {
        
        //BETTER WAY TO DO THIS: 
        //FOR TABLE - BUILD ARRAY BY USING PREVIOUS INDEXPATH.ROW VALUES (WHEN NO NEW VALUE) AND POPULATING ARRAY ONLY AS THE CELLS ARE CALLED FOR (I.E. AS USER SCROLLS)
        //FOR GRAPH: STILL NEED A FUNCTION LIKE THIS, BUT IT TAKES THIS FUNCTION GETS PASSED THE SMALLEST UNIT TO USE AND CALCULATES ARRAY RELEVANT FOR THIS.
        

        if highestCalculatedTime > plotDataArray.count-1 {
            for ii in plotDataArray.count...highestCalculatedTime {
                //Check whether this time has a new decay and if so then subtract decayed nuclei from count
                
                if timeDic[ii-1] != nil {
                    //println("plotDataArray[ii-1] = \(plotDataArray[ii-1])")
                    //println("timeDic[ii-1]!.count = \(timeDic[ii]!.count)")
                    plotDataArray.append(plotDataArray[ii-1] - timeDic[ii-1]!.count)
                    
                    totalSubtracted += timeDic[ii-1]!.count
                
                } else {
                    //if no decays then number of nuclei stays the same
                    plotDataArray.append(plotDataArray[ii-1])
                }
            }
        }
        
        /*
        var tempSumTimeDic = 0
        for (iii,data) in enumerate(timeDic) {
            //NEED TO LOOP OVER DICTIONARY HERE
            tempSumTimeDic += data.1.count
            //println("!!At time = \(data.0)")
            //println(data.1)
        }
        println("New plotDataArray count is \(plotDataArray.count)")
        println("plotDataArray = \(plotDataArray)")
        println("TOTAL NUMBER OF DECAYS IN TIMEDIC = \(tempSumTimeDic)")
        */
        
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
        //println("Size of plotDataArray is \(plotDataArray.count)")
        //println("Trying to get ploDataArray contents at \(indexPath.row)")
        //println("Last elementy of plotDataArray is \(plotDataArray.last)")
        cell!.isotopeName.text = String(indexPath.row)
        cell!.isotopeName.font = UIFont(name: "Arial", size: 50)
        cell!.isotopeData.text = String(plotDataArray[indexPath.row])
        cell!.isotopeData.text = String(plotDataArray[indexPath.row])
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
