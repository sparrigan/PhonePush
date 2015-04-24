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
    let button   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    

        
        

    

        view1.setTranslatesAutoresizingMaskIntoConstraints(false)
        view1.backgroundColor = UIColor.redColor()
    
        
                view.addSubview(view1)
        
        
        //addConstrationsFunc()
        
    
    }
    
    override func viewDidAppear(animated: Bool) {
        testWithText()
    }
    
    func addConstrationsFunc() {
        
        let viewsDictionary = ["view1":view1,"MainView":self.view]
        
        
        
        
        
        //Can do constraints using 'constraintsWithVisualFormat' method of NSLayoutConstraint that allows you to use Visual Formatting Language (VFL) to enter constraints.
        let view1_constraint_H:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:[view1(viewWidth)]", options: NSLayoutFormatOptions(0), metrics: metricsDictionary, views: viewsDictionary)
        let view1_constraint_V:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:[view1(view1Height)]", options: NSLayoutFormatOptions(0), metrics: metricsDictionary, views: viewsDictionary)
        

        //Or can do constraints using a stadnard base call to NSLayoutConstraint, where pass specific details of constraint (init by specifying relation to another view)
        
        //self.view.addConstraint(NSLayoutConstraint(item: view1, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 0.75, constant: 0))
       //Try and do width with VFL
        let viewTest:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:[view1(==MainView)]", options: NSLayoutFormatOptions(0), metrics: metricsDictionary, views: viewsDictionary)
        
        self.view.addConstraint(NSLayoutConstraint(item: view1, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0))
        
        self.view.addConstraint(NSLayoutConstraint(item: view1, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: 50))
        
        //In either case, we could either addConstraint directly to the view that is superview to the two we are specifying a relation between. Or we could assign the constraint to a variable and then add it this way.
        
        self.view.addSubview(view1)
        
        //view1.addConstraints(view1_constraint_H)
        self.view.addConstraints(viewTest)
        self.view.addConstraints(view1_constraint_V)
        //view1.addConstraint(leftConstraint)
        
        println("first check width: \(view1.frame.size.width)")
        println("first check height: \(view1.frame.size.height)")
        
    }
    
    
    override func viewDidLayoutSubviews() {
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        //Old stuff
        /*
        
        //println("first check width!: \(titleText.frame.size.width)")
        //println("first check height!: \(titleText.frame.size.height)")
        //println("Font size: \(titleText.font.pointSize)")
        println("Contentsize height: \(titleText.intrinsicContentSize().height)")
        println("Frame height: \(titleText.frame.size.height)")
        println("")
        while (titleText.intrinsicContentSize().height > titleText.frame.size.height && titleText.font.pointSize > 5)
        {

            titleText.font = UIFont(name: titleText.font.fontName, size: titleText.font.pointSize-1)
//                [self.font fontWithSize:self.font.pointSize -1];
            println("Font size: \(titleText.font.pointSize)")
            println("Contentsize height: \(titleText.contentSize.height)")
            println("Frame height: \(titleText.frame.size.height)")
            println("")
        }
         //titleText.layoutSubviews()
        /*
        var fontSize:CGFloat = 500
        titleText.font = UIFont(name: "Arial", size: fontSize)
        var minSize:CGFloat = 5
        var ii: Int = 0
        while (fontSize > minSize && titleText.sizeThatFits(CGSizeMake(titleText.frame.size.width,200000)).height >= titleText.frame.size.height) {
            println("in loop: \(ii)")
            ii++
            fontSize -= 1
            titleText.font = UIFont(name: "Arial", size: fontSize)
        }
*/
        */
  
        
        
    }


    
    func testWithText() {
        

        //Textfield
        titleText.setTranslatesAutoresizingMaskIntoConstraints(false)
        titleText.text = "Ready, steady, teddy beddy ready breaky"
        titleText.font = UIFont(name: "Arial", size: 200)
        UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        titleText.editable = false
        titleText.backgroundColor = UIColor.redColor()
        
        //titleText.contentOffset = CGPointZero
        
        
        //Add views to main view
        self.view.addSubview(button)
        self.view.addSubview(titleText)
        
        titleText.sizeToFit()
        titleText.layoutIfNeeded()
       
        

        
        //Dictionary of views to give constraints
        let viewsDictionary = ["titleText":titleText,"MainView":self.view]
        
        //Constraint on width of text field
        let wConstraint = NSLayoutConstraint(item: titleText, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 0.75, constant: 0)
        //Constraint on height and y position of text field
        let vConstraints:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:|-50-[titleText(100)]", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
        //Center the textfield
        
        let centConstraint = NSLayoutConstraint(item: titleText, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)

        //Seems to work if I MANUALLY SET THE SIZE OF THE TEXTBOX HERE
        //titleText.frame = CGRectMake(0, 0, 20, 20)
        
        
        //Add constraints to superviews
        //(Note that .addConstraint and .addConstraints are different!)
        //self.view.addConstraint(wConstraint)
        
        self.view.addConstraints([wConstraint,centConstraint]+vConstraints)
//self.view.addConstraint(wConstraint)
        
        
        

        /*
        while (fontSize > minSize &&  [newView sizeThatFits:(CGSizeMake(newView.frame.size.width, FLT_MAX))].height >= newView.frame.size.height ) {
            fontSize -= 1.0;
            newView.font = [tv.font fontWithSize:fontSize];
        }
        */
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

