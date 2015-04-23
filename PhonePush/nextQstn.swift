//
//  nextQstn.swift
//  
//
//  Created by Nicholas Harrigan on 17/04/2015.
//
//

import UIKit

//This class gets called when a questions VC is done, and rewrites the navigation
//stack to present the next question - including call to new push if necessary.

public class nextQstn {

    //Stores ordered list of qstns to ask (updated by method below)
    //!!!UNCOMMENT THIS WHEN PASSING QSTNSTRING FROM OUTSIDE!!!!
    //public var qstnString:[String] = []

    public var qstnString = ["calcQstn", "graphQstn"]

    //This index increments with each new question, determining which qstn from
    //qstnString to add to VC stack next
    var qstnIndex = 0
    
    //Local dictionary to store data from accelerometer
    
    var pushData: [String: Any]?
    //= ["aRaw": [], "vRaw": [], "pRaw":[], "tRaw":[], "indexConstAccel":0, "constAccel":0, "timeConstAccel":0, "distConstAccel":0, "velInit":0]
    
    //This is called by initial http teacher call to update qstnString
    public func updateQstns(newStrings:[String]) {
        qstnString = newStrings
    }
    
    //This is the method that is called from a VC to move onto the next qstn
    public func goToNext(navi: UINavigationController) {
        
        //Here we increment qstnIndex, then go through conditionals to determine which VC to assign to nextVC var (with clauses for adding phonepush calib screen if needed but not done already.
        
        var nextVC:UIViewController?
        
        //NEED TO DO A CHECK HERE FOR WHETER OR NOT WE HAVE DATA VALUES FROM A PUSH.
        //Check that we have some data from the accelerometer to work with. If not then 
        //call calibration screen again (should always be *some* data from the last run)
        if let pushData = pushData {
            //Check that we haven't reached the end of the question array
            if qstnIndex < qstnString.count {
                
                if qstnString[qstnIndex] == "calcQstn" {
                    //Increment index for next question
                    qstnIndex++
                    nextVC = calcQstns(pushData: pushData)
                } else if qstnString[qstnIndex] == "graphQstn" {
                    //Increment index for next question
                    qstnIndex++
                    nextVC = graphQstns(pushData: pushData)
                
                    //THIS IS A TEST-CASE JUST FOR SHOWING HOW TO DEAL WITH A QUESTION
                    //THAT WANTS USER TO DO ANOTHER PHONE PUSH BEFORE CONTINUING
                } else if qstnString[qstnIndex] == "testCase" {
                    //This is just a testcase for what to do if question needs user to give
                    //another push
                    //Check whether top of stack is VC2 before changing stack
                    var tempStack = navi.viewControllers
                    if let testForCalib: AnyObject = tempStack?[tempStack.count-1]  {
                        if let testForCalib = testForCalib as? PPcalibVC {
                            //println("Phone was just pushed")
                            //MAKE NEXTVC BE EQUAL TO THE ACTUAL QUESTION VC HERE
                        } else {
                            //println("Need to get data from another push before running this question. Running calib VC...")
                            nextVC = PPcalibVC()
                        }
                    }
                    
                } else {
                    //println("Unknown entry!")
                }
                
            } else {
                println("End of questions!")
            }
        } else {
            //PUT ALERT SCREEN HERE "NEED SOME PUSH DATA FOR THIS ACTIVITY!", FOLLOWED BY CALLING CALIBRATION SCREEN AGAIN
            //println("NO DATA IS PRESENT FOR ASKING QUESTIONS WITH!")
        }
        
        //Then remove top of stack and reorder etc... with chosen nextVC
        //Check that have a nextVC and load it up if so:
        if let nextVC = nextVC {
            var VCstack = navi.viewControllers
            //Remove top VC root is at 0, top is at count
            VCstack.removeLast()
            //Add nextVC to top of stack
            VCstack.append(nextVC)
            //Animate transition from old stack to newly formed one
            navi.setViewControllers(VCstack, animated: true)
        } else {
            //println("No VC to move to!")
        }
    }
    
    //PUBLIC FUNC NEEDS TO GO HERE FOR UPDATING THE DATA VALUES FROM A PUSH
    
    public func passAccelData(accelResults: [String:Any]) {
        pushData = accelResults
    }
    
}

public var nQstn:nextQstn = nextQstn()