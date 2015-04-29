//
//  findTextSize.swift
//  AutoLayoutTest
//
//  Created by Nicholas Harrigan on 26/04/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

//TODO:

//BE ABLE TO DEAL WITH EITHER HAVING UITEXTVIEW OF UIBUTTON ALL THE WAY THROUGH THE FLOW

//ADD BOOL OPTION IN FUNCTION CALL THAT CLONES VIEW TO ONLY RETURN NEW FONT SIZE AND NOT
//IMPLEMENT CHANGE AS WELL

//TIDY UP


import UIKit

class findTextSize {
    
    //Dictionary for storing any calculations on rotation
    var fontSizeDic = [UIView: [Double]]()
    //Local array for storing passed views
    var viewArray = [UIView]()
    
    //At init receives an array containing the views that we want to be able to auto
    //size the text in.
    init(vArray:[UIView]) {
        
        self.viewArray = vArray
        
        //Loop over passed views and assign them an entry in the dictionary for storing sizes
        for ii in viewArray {
            fontSizeDic[ii] = [0.0,0.0]
        }
    }
    
    //Function that checks what type of view we have at a given element of viewArray
    func checkViewType() {
        if let checkType = viewArray[0] as? UITextView {
            println("It was a textview!")
        } else if let checkType = viewArray[0] as? UIButton {
            println("It was a button")
        } else {
            println("It was something else")
        }
    }
    
    //Function that is called in order to return the font size of the view
    //ADD ANOTHER OPTIONAL BOOL VARIABLE THAT CAN BE PASSED IN ORDER TO SPECIFY WHETHER
    //A CALL WILL ALSO ACTUALLY CHANGE THE FONT SIZE IN THE VIEW, OR JUST RETURN A VALUE
    //(IN SECOND CASE DO THIS BY CREATING A LOCAL CLONE VIEW AND WORKING WITH THAT)
    func updateViewFont(currentOrientation: String) -> [UIView: Double] {
        
        //Dictionary of doubles for returning font sizes of all views need to calc for
        var newSizes = [UIView: Double]()
        
        //Set subscript index for fontsize dictionary according to whether we 
        //are working with portrait or landscape
        var jj = 0
        
        if currentOrientation == "Portrait" {
             jj = 0
        } else if currentOrientation == "Landscape" {
             jj = 1
        }
        
        //Go through dictionary and check whether already have a calculated value or not for
        //each view for current orientation
        for currentView in viewArray {
        
            //Initialise an element of current view in view array (doing that here ensures that 
            //we at least have valid dictionary elements for each view that could be requested
            //on return of call)
            
            newSizes[currentView] = 0.0
            
            //First double check that the UIView actually has an element in the dictionary!
            if var ttt = fontSizeDic[currentView] {
                
                println("Checking what's there, and it's: \(ttt[jj])")
                
                //Check whether there is already a value in the dictionary for this view in
                //this orientation (specified by ii)
                if ttt[jj] != 0 {
                
                    println("Already had a value there - AWESOME!")
                    
                    //Return the font size that we already have
                    newSizes[currentView] = ttt[jj]
                } else {
                    //No font size already calculated, so need to calculate it, set the dictionary
                    //for next time, and return the newly calculated value
                    

                    //Note that dictionary elements always return optional, so need to unwrap
                    fontSizeDic[currentView]![0] = Double(sizeFontToViewBinary(currentView as! UITextView, maxFontSize:500.0, minFontSize: 5.0))
                    
                    println("JUST ASSIGNED A VALUE TO \(jj) ELEMENT OF DIC")
                    
                    newSizes[currentView] = fontSizeDic[currentView]![0]
                    
                    //return ttt[ii]
                }
                
            } else {
                //Nothing defined for that UIView! Something has gone wrong!
                //IN CASE OF FAIL, ELEMENT OF RETURN DICTIONARY WILL BE LEFT AS INITIAL ZERO
            }
        
        }
        
        return newSizes
            
    }
    
    
    //Function that performs binary search for best fit font size - only called from above
    //if dictionary does not already contain an entry for the current orientation from a 
    //previous calculation
    private func sizeFontToViewBinary(tView:UITextView,maxFontSize:Double = 500,minFontSize:Double = 5) -> CGFloat {
        
        println("Called the intesive function")
        
        
        //Max size for tallerSize (just needs to be very large)
        let kMaxFieldHeight = 9999
        //String that we want to try and get to fit
        var fitString:NSString = tView.text
        //Fudge factor due to padding in UIView
        var fudgeFactor = 16.0
        //Font size we start with
        
        //Start font off at largest size that we would allow
        var fontSize = maxFontSize
        
        
        
        tView.font = UIFont(name: tView.font.fontName, size: CGFloat(fontSize))
        
        
        
        //Make holder size that is width of the view but very tall - so we can see what height
        //text has when we try and force it into it
        var tallerSize = CGSizeMake(tView.frame.size.width - CGFloat(fudgeFactor), CGFloat(kMaxFieldHeight))
        //Dictionary with font attributes in that we use to get size of text (of this font type/size) when pushed into tallerSize
        var attrs = [NSFontAttributeName: UIFont(name: tView.font.fontName,size: CGFloat(fontSize)) as! AnyObject]
        //Get first run of stringSize for current fontSize when try to push into tallerSize
        var stringSize = fitString.boundingRectWithSize(tallerSize,
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: attrs,
            context: nil).size
        
        //Loop reducing font until will fit by removing or adding a half of it's current
        //value until either get within 20 pixels of desired height, or more than 15 iterations
        //are used
        var ii = 0
        while (abs(stringSize.height - tView.frame.size.height)>20 && ii<=15) {
            ii++
            //If current fontsize gives a stringsize that is too large then halve
            //else add a half (i.e. multiply by 1.5)
            if (stringSize.height >= tView.frame.size.height) {
                fontSize = ceil(fontSize/2)
            } else {
                fontSize = ceil(1.5*fontSize)
            }
            //Update view with new altered font size, and update corresponding stringSize
            tView.font = UIFont(name: tView.font.fontName,size: CGFloat(fontSize))
            //Update the attributes dictionary with the new font size
            var attrs = [NSFontAttributeName: UIFont.systemFontOfSize(CGFloat(fontSize))]
            //Generate a new stringSize trying to fit this new sized font into tallerSize
            stringSize = fitString.boundingRectWithSize(tallerSize,
                options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                attributes: attrs,
                context: nil).size
        }
        
       
        
        //Now have gotten pretty close with above binary search, linearly increase or decrease
        //font size from this point as necessary until we get as close as possible.
        if stringSize.height >= tView.frame.size.height {
            
            
            //If end up with string too big for view try decreasing font size one point at
            //a time
            

            while (stringSize.height > tView.frame.size.height) {
                fontSize -= 1.0
                tView.font = UIFont(name: tView.font.fontName,size: CGFloat(fontSize))
                //Update the attributes dictionary with the new font size
                var attrs = [NSFontAttributeName: UIFont.systemFontOfSize(CGFloat(fontSize))]
                //Generate a new stringSize trying to fit this new sized font into tallerSize
                stringSize = fitString.boundingRectWithSize(tallerSize,
                    options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                    attributes: attrs,
                    context: nil).size
            }
            
        
            
            return tView.font.pointSize
        } else {
            
            //If end up with string too small for view try increasing font size one point at
            //a time
            while (stringSize.height <= tView.frame.size.height) {
                fontSize += 1.0
                tView.font = UIFont(name: tView.font.fontName,size: CGFloat(fontSize))
                //Update the attributes dictionary with the new font size
                var attrs = [NSFontAttributeName: UIFont.systemFontOfSize(CGFloat(fontSize))]
                //Generate a new stringSize trying to fit this new sized font into tallerSize
                stringSize = fitString.boundingRectWithSize(tallerSize,
                    options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                    attributes: attrs,
                    context: nil).size
            }
            //Above loop will have stopped when we arrive just *above* what fits, so go back
            //down one point in font size
            fontSize -= 1.0
            tView.font = UIFont(name: tView.font.fontName,size: CGFloat(fontSize))
            
            
            return tView.font.pointSize
        }
    }
    
    
}
