//
//  ViewController.swift
//  AutoLayoutTest
//
//  Created by Nicholas Harrigan on 23/04/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

            let view1 = UIView()
    let metricsDictionary = ["view1Height": 50.0, "viewWidth":100.0 ]
    var titleText:UITextView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        //NOTE: Is important to define textview in viewDidLoad so that it exists for the
        //first call to viewDidLayoutSubviews (which is called even before first rotation)
        //otherwise get an error
        titleText.setTranslatesAutoresizingMaskIntoConstraints(false)
        titleText.text = "Ready, steady, teddy beddy ready breaky scooby dooby doo and all that jazz and the like. Who is your favourite piece of lint? Mine too! We were made for each other. Clearly."
        titleText.font = UIFont(name: "Arial", size: 200)
        UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        titleText.editable = false
        titleText.backgroundColor = UIColor.redColor()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        //Function to setup autolayout constraints.
        //NOTE: Is important that this is called from viewDidAppear as opposed to
        //from viewDidLoad, beause otherwise
        testWithText()
    }
    
    
    
    
    override func viewDidLayoutSubviews() {
        //When rotation etc... of ipads, run function that checks text
        //fits into boxes
        sizeFontToView(titleText,maxFontSize: 500,minFontSize: 5)

    }


    
    func testWithText() {
        
        //Add views to main view - important to do this here
        self.view.addSubview(titleText)

        //Dictionary of views to give constraints
        let viewsDictionary = ["titleText":titleText,"MainView":self.view]
        
        //Constraint on width of text field
        let wConstraint = NSLayoutConstraint(item: titleText, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 0.75, constant: 0)
        //Constraint on height and y position of text field
        let vConstraints:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:|-50-[titleText(100)]", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
        
        //Center the textfield constraint
        let centConstraint = NSLayoutConstraint(item: titleText, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)

        //Add constraints to superviews
        //(Note that .addConstraint and .addConstraints are different!)
        //self.view.addConstraint(wConstraint)
        
        self.view.addConstraints([wConstraint,centConstraint]+vConstraints)
    }
    
    
    func sizeFontToView(tView:UITextView,maxFontSize:Double = 500,minFontSize:Double = 5) {
        //maxFontSize is the Maximum font size you would consider allowable (defaults to 500)
        //minFontSize is the Minumum font size you would consider allowable (defaults to 5)
        
        //TO DO: TREAT TVIEW AS AN OPTIONAL AND UNWRAP CAREFULLY (AS MIGHT GET THIS CALLED
        //BEFORE HAS BEEN ADDED TO VIEW ETC... IF IS DONE AFTER VIEWDIDLOAD)
        
        //ALSO: FIRST CHECK WHETHER TEXT ALREADY FITS? TO STOP NEED FOR ITERATIONS IF FUNC
        //IS CALLED ACCIDENTALLY WHEN IT ISN'T NEEDED?
        
        //ALSO: DO BINARY SEARCH INSTEAD OF LINEAR
        
        //ALSO: NEED TO FIGURE OUT HOW TO DO WHEN HAVE TEXT CENTERED (I.E. HOW DO WE SET
        //THIS OPTION IN boundingRectWithSize?
        
        //Max size for tallerSize (just needs to be very large)
        let kMaxFieldHeight = 9999
        //String that we want to try and get to fit
        var fitString:NSString = tView.text
        //Fudge factor due to padding in UIView
        var fudgeFactor = 16.0
        //Font size we start with
        
        //Start font off at largest size that we would allow
        var fontSize = maxFontSize
        
        //println(tView.text)
 
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
        
        //Loop reducing font until will fit
        while (stringSize.height >= tView.frame.size.height) {
            
            if (fontSize <= minFontSize) {
                println("too small!!")
                return
            } else {
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
            
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
