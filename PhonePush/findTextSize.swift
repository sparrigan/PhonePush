//
//  findTextSize.swift
//  AutoLayoutTest
//
//  Created by Nicholas Harrigan on 26/04/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//




import UIKit

class findTextSize {
    
    //Dictionary for storing any calculations on rotation
    var fontSizeDic = [UIView: [Double]]()
    //Local array for storing passed views
    var viewArray = [UIView]()
    
    var defaultNoChange:Bool = false
    
    //At init receives an array containing the views that we want to be able to auto
    //size the text in.
    //Optional initialiser parameter is default for whether or not to implement changes
    //directly to view (false) or just return numerical value only (true). Can be overriden
    //within method call
    init(vArray:[UIView],dNoChange:Bool = false) {
        
        self.viewArray = vArray
        
        self.defaultNoChange = dNoChange
        
        //Loop over passed views and assign them an entry in the dictionary for storing sizes
        for ii in viewArray {
            fontSizeDic[ii] = [0.0,0.0]
        }
    }
    

    
    //Function that is called in order to return the font size of the view
    //Optional 'noChange' parameter specifies whether to only return font size without
    //implementing change (true). Over-rides any value specified in initaliser.
    func updateViewFont(currentOrientation: String, noChange:Bool? = nil) -> [UIView: Double] {
        
        //Dictionary of doubles for returning font sizes of all views need to calc for
        var newSizes = [UIView: Double]()
        
        //First check whether we were passed an empty string. If that's the case then 
        //assume orientation info was not available, and so perform calculations without
        //storing or checking for existing stored values
        
        if currentOrientation != "" {
        
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
                
                //println("Checking what's there, and it's: \(ttt[jj])")
                
                //Check whether there is already a value in the dictionary for this view in
                //this orientation (specified by ii)
                if ttt[jj] != 0 {
                
                    //println("Already had a value there - AWESOME!")
                    
                    //Return the font size that we already have
                    newSizes[currentView] = ttt[jj]
                    
                    //Assign it to the currentview we are considering (check whether is button or textfield
                    
                    if let checkType = currentView as? UITextView {
                        //It was a textview
                        checkType.font = UIFont(name: checkType.font.fontName, size: CGFloat(ttt[jj]))
                    } else if let checkType = currentView as? UIButton {
                         //It was a button
                        checkType.titleLabel!.font = UIFont(name: checkType.titleLabel!.font.fontName, size: CGFloat(ttt[jj]))
                    } else {
                        //println("It was something else")
                    }
                    
                    
                } else {
                    //No font size already calculated, so need to calculate it, set the dictionary
                    //for next time, and return the newly calculated value
                    
                    
                    //Determine whether we should actually implement changes or just return
                    //new font size, based on default settings from first class instantiation
                    //and potential over-ridding setting passed in method call
                    var shouldChange:Bool
                    //If parameter passed on method call then use that.
                    if noChange != nil {
                        
                        shouldChange = noChange!
                        //shouldChange = (defaultNoChange&&noChange!)||(!defaultNoChange&&noChange!)
                    //Else use the default parameter passed on initalisation
                    } else {
                         shouldChange = defaultNoChange
                    }
                    
                    //Check whether we are dealing with a UITextView or a UIButton and call
                    //appropriate internal function
                    if let checkType = currentView as? UITextView {
                        //It was a textview
                        
                        fontSizeDic[currentView]![jj] = Double(sizeFontToUITextView(currentView as! UITextView, maxFontSize:500.0, minFontSize: 5.0, noChange: shouldChange))
                    } else if let checkType = currentView as? UIButton {
                        //println("It was a button")
                        //It was a button
                        fontSizeDic[currentView]![jj] = Double(sizeFontToUIButton(currentView as! UIButton, maxFontSize:500.0, minFontSize: 5.0, noChange:shouldChange))
                    } else {
                        //println("It was something else")
                    }
                    
                    //println("JUST ASSIGNED A VALUE TO \(jj) ELEMENT OF DIC")
                    
                    //Add calculated value to return array
                    newSizes[currentView] = fontSizeDic[currentView]![jj]
                    
                }
                
            } else {
                //Nothing defined for that UIView! Something has gone wrong!
                //IN CASE OF FAIL, ELEMENT OF RETURN DICTIONARY WILL BE LEFT AS INITIAL ZERO
            }
        
        }
        
            //This is what we do if passed orientation of ""
        } else {
            for currentView in viewArray {
            
            newSizes[currentView] = 0.0
                
                var shouldChange:Bool
                //If parameter passed on method call then use that.
                if noChange != nil {
                    
                    shouldChange = noChange!
                    //shouldChange = (defaultNoChange&&noChange!)||(!defaultNoChange&&noChange!)
                    //Else use the default parameter passed on initalisation
                } else {
                    shouldChange = defaultNoChange
                }
                
                //Check whether we are dealing with a UITextView or a UIButton and call
                //appropriate internal function
                if let checkType = currentView as? UITextView {
                    //It was a textview
                    
                     newSizes[currentView] = Double(sizeFontToUITextView(currentView as! UITextView, maxFontSize:500.0, minFontSize: 5.0, noChange: shouldChange))
                } else if let checkType = currentView as? UIButton {
                    //println("It was a button")
                    //It was a button
                     newSizes[currentView] = Double(sizeFontToUIButton(currentView as! UIButton, maxFontSize:500.0, minFontSize: 5.0, noChange:shouldChange))
                } else {
                    //println("It was something else")
                }
                
                
            }
            
        }
        
        return newSizes
        
    }
    
    
    //Function that performs binary search for best fit font size - only called from above
    //if dictionary does not already contain an entry for the current orientation from a 
    //previous calculation
    private func sizeFontToUITextView(tempView:UITextView,maxFontSize:Double = 500,minFontSize:Double = 5,noChange:Bool = false) -> CGFloat {
        
        //println("Called the intesive function")
        
        var tView:UITextView
        
        //If passed relevant option then clone UITextView so that only return value without
        //actually implementing change in font on real UITextView
        if noChange == true {
            tView = UITextView(frame: CGRectMake(0, 0, tempView.frame.size.width, tempView.frame.size.height))
            tView.text = tempView.text
        } else {
            tView = tempView
        }
        

        
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
        var attrs = [NSFontAttributeName: UIFont(name: tView.font.fontName,size: CGFloat(fontSize))!]
        //Get first run of stringSize for current fontSize when try to push into tallerSize
        var stringSize = fitString.boundingRectWithSize(tallerSize,
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: attrs,
            context: nil).size
        
            //println("Size of view to match is width:\(tallerSize.width), height:\(tallerSize.height)")
        
        //Loop reducing font until will fit by removing or adding a half of it's current
        //value until either get within 20 pixels of desired height, or more than 15 iterations
        //are used
        var ii = 0
        while (abs(stringSize.height - (tView.frame.size.height-CGFloat(fudgeFactor)))>20 && ii<=15) {
            ii++
            //If current fontsize gives a stringsize that is too large then halve
            //else add a half (i.e. multiply by 1.5)
            if (stringSize.height >= (tView.frame.size.height-CGFloat(fudgeFactor))) {
                fontSize = ceil(fontSize/2)
            } else {
                fontSize = ceil(1.5*fontSize)
            }
            //Update view with new altered font size, and update corresponding stringSize
            tView.font = UIFont(name: tView.font.fontName,size: CGFloat(fontSize))
            //Update the attributes dictionary with the new font size
            var attrs = [NSFontAttributeName: UIFont(name: tView.font.fontName,size: CGFloat(fontSize))!]
           //var attrs = [NSFontAttributeName: UIFont.systemFontOfSize(CGFloat(fontSize))]
            //Generate a new stringSize trying to fit this new sized font into tallerSize
            stringSize = fitString.boundingRectWithSize(tallerSize,
                options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                attributes: attrs,
                context: nil).size
        }
        

        
        //Now have gotten pretty close with above binary search, linearly increase or decrease
        //font size from this point as necessary until we get as close as possible.
        if stringSize.height >= (tView.frame.size.height-CGFloat(fudgeFactor)) {
            
            
            //If end up with string too big for view try decreasing font size one point at
            //a time
            

            while (stringSize.height > (tView.frame.size.height-CGFloat(fudgeFactor))) {
                fontSize -= 1.0
                tView.font = UIFont(name: tView.font.fontName,size: CGFloat(fontSize))
                //Update the attributes dictionary with the new font size
                var attrs = [NSFontAttributeName: UIFont(name: tView.font.fontName,size: CGFloat(fontSize))!]
                //Generate a new stringSize trying to fit this new sized font into tallerSize
                stringSize = fitString.boundingRectWithSize(tallerSize,
                    options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                    attributes: attrs,
                    context: nil).size
            }
            
        
            //println("Returning with stringsize height of \(stringSize.height) and a tView height of \(tView.frame.size.height). Fontsize of \(tView.font.pointSize)")
            return tView.font.pointSize
        } else {
            
            //If end up with string too small for view try increasing font size one point at
            //a time
            while (stringSize.height <= (tView.frame.size.height-CGFloat(fudgeFactor))) {
                fontSize += 1.0
                tView.font = UIFont(name: tView.font.fontName,size: CGFloat(fontSize))
                //Update the attributes dictionary with the new font size
                var attrs = [NSFontAttributeName: UIFont(name: tView.font.fontName,size: CGFloat(fontSize))!]
                //Generate a new stringSize trying to fit this new sized font into tallerSize
                stringSize = fitString.boundingRectWithSize(tallerSize,
                    options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                    attributes: attrs,
                    context: nil).size
                //println("IN LOOP: stringsize:\(stringSize.height) tView:\(tView.frame.size.height) Fontsize:\(tView.font.pointSize)")
            }
            //Above loop will have stopped when we arrive just *above* what fits, so go back
            //down one point in font size
            fontSize -= 1.0
            tView.font = UIFont(name: tView.font.fontName,size: CGFloat(fontSize))
            
            //println("Returning with stringsize height of \(stringSize.height) and a tView height of \(tView.frame.size.height). Fontsize of \(tView.font.pointSize)")
            return tView.font.pointSize
        }
    }
    
    //Function for binary search for font-size for SINLE LINE button text (using binary search)
    private func sizeFontToUIButton(tempView:UIButton,maxFontSize:Double = 500,minFontSize:Double = 5, noChange:Bool = false) -> CGFloat {
        
        //println("Called the intesive function")
        
        var tView:UIButton
        
        if noChange == true {
            tView = UIButton(frame: CGRectMake(0, 0, tempView.frame.size.width, tempView.frame.size.height))
            tView.titleLabel!.text = tempView.titleLabel!.text
        } else {
            tView = tempView
        }
        
        //Create clone view as button
        
        
        
        
        //Max size for tallerSize (just needs to be very large)
        let kMaxFieldHeight = 9999
        //String that we want to try and get to fit
        var fitString:NSString = tView.titleLabel!.text!
        //Fudge factor due to padding in UIView
        var fudgeFactor = 16.0
        //Font size we start with
        
        //Start font off at largest size that we would allow
        var fontSize = maxFontSize
        
        
        //HERE!!!
        
        
        tView.titleLabel!.font = UIFont(name: tView.titleLabel!.font.fontName, size: CGFloat(fontSize))
        
        
        //Make holder size that is width of the view but very tall - so we can see what height
        //text has when we try and force it into it
        //HERE!!!
        var tallerSize = CGSizeMake(tView.frame.size.width - CGFloat(fudgeFactor), CGFloat(kMaxFieldHeight))
        //Dictionary with font attributes in that we use to get size of text (of this font type/size) when pushed into tallerSize
        var attrs = [NSFontAttributeName: UIFont(name: tView.titleLabel!.font.fontName,size: CGFloat(fontSize))!]
        //Get first run of stringSize for current fontSize when try to push into tallerSize
        //var stringSize = fitString.boundingRectWithSize(tallerSize,
        //    options: NSStringDrawingOptions.UsesLineFragmentOrigin,
        //    attributes: attrs,
        //    context: nil).size
        
        var stringSize = fitString.sizeWithAttributes([NSFontAttributeName: tView.titleLabel!.font])
        
        //Loop reducing font until will fit by removing or adding a half of it's current
        //value until either get within 20 pixels of desired height, or more than 15 iterations
        //are used
        
        var ii = 0
        while (abs(stringSize.width - (tView.frame.size.width-CGFloat(fudgeFactor)))>20 && ii<=15) {
            ii++
            //If current fontsize gives a stringsize that is too large then halve
            //else add a half (i.e. multiply by 1.5)
            if (stringSize.width >= (tView.frame.size.width-CGFloat(fudgeFactor))) {
                fontSize = ceil(fontSize/2)
            } else {
                fontSize = ceil(1.5*fontSize)
            }
            //Update view with new altered font size, and update corresponding stringSize
            tView.titleLabel!.font = UIFont(name: tView.titleLabel!.font.fontName,size: CGFloat(fontSize))
            //Update the attributes dictionary with the new font size
            var attrs = [NSFontAttributeName: UIFont(name: tView.titleLabel!.font.fontName,size: CGFloat(fontSize))!]
            //Generate a new stringSize trying to fit this new sized font into width of
            //tallerSize
            stringSize = fitString.sizeWithAttributes([NSFontAttributeName: tView.titleLabel!.font])
        }
        
        
        
        //Now have gotten pretty close with above binary search, linearly increase or decrease
        //font size from this point as necessary until we get as close as possible.
        if stringSize.width >= (tView.frame.size.width-CGFloat(fudgeFactor)) {
            
            //If end up with string too wide for view try decreasing font size one point at
            //a time
            
            
            while (stringSize.width > (tView.frame.size.width-CGFloat(fudgeFactor))) {
                fontSize -= 1.0
                tView.titleLabel!.font = UIFont(name: tView.titleLabel!.font.fontName,size: CGFloat(fontSize))
                //Update the attributes dictionary with the new font size
                var attrs = [NSFontAttributeName: UIFont(name: tView.titleLabel!.font.fontName,size: CGFloat(fontSize))!]
                //Generate a new stringSize trying to fit this new sized font into tallerSize
                stringSize = fitString.sizeWithAttributes([NSFontAttributeName: tView.titleLabel!.font])
            }
            
            //println(tView.titleLabel!.font.pointSize)
            return tView.titleLabel!.font.pointSize
        
        } else {
            
            //If end up with string too small for view try increasing font size one point at
            //a time
            while (stringSize.width <= (tView.frame.size.width-CGFloat(fudgeFactor))) {
                fontSize += 1.0
                tView.titleLabel!.font = UIFont(name: tView.titleLabel!.font.fontName,size: CGFloat(fontSize))
                //Update the attributes dictionary with the new font size
                var attrs = [NSFontAttributeName: UIFont(name: tView.titleLabel!.font.fontName,size: CGFloat(fontSize))!]
                //Generate a new stringSize trying to fit this new sized font into tallerSize
                stringSize = fitString.sizeWithAttributes([NSFontAttributeName: tView.titleLabel!.font])
            }
            //Above loop will have stopped when we arrive just *above* what fits, so go back
            //down one point in font size
            fontSize -= 1.0
            tView.titleLabel!.font = UIFont(name: tView.titleLabel!.font.fontName,size: CGFloat(fontSize))
            
            //println(tView.titleLabel!.font.pointSize)
            return tView.titleLabel!.font.pointSize
        }
    }

    
    
    
}
