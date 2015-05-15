//
//  attomArrayScene.swift
//  PhonePush
//
//  Created by Nicholas Harrigan on 13/05/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//




import UIKit

class atomArrayScene: UIView {
    
    var initialSize: CGRect = CGRectZero
    
    init(sizeinput: CGRect) {
        initialSize = sizeinput
        super.init(frame: sizeinput)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        
        self.backgroundColor = UIColor.blueColor()
        
        //Fraction of image size to use as the padding spacing
        var R = 0.25
        
        //Get a test instance of atomNode to find its size
        var imageName = "electronbg"
        var image = UIImage(named: imageName)
        var tempAtomNode = UIImageView(image: image)
        
        var tempAtomNode2 = UIImageView(image: image)
        
        var atomActualSize = (width: Double(tempAtomNode.bounds.width), height: Double(tempAtomNode.bounds.height))
        
        
        //Figure out the number of atoms we should aim to use in a row and number of rows to use
        //in order to fit within requested size for this view.
        var scalingData = calcNums(Double(initialSize.height), W: Double(initialSize.width), ha: atomActualSize.height, wa: atomActualSize.width, R: R)
    
        //[PUT ALL BELOW IN NESTED LOOP - FOR ROWS, AND FOR ELEMENTS OF ROW]
        //create view for storing one row
    
        //Initialise view dictionary
        var viewsDictionary = Dictionary<String, UIImageView>()
        
        //Array for holding row views
        var rowArray = [UIView]()
        
        for ii in 1...scalingData.Nh {
        
            //View for holding a single row of atoms
            var rowView = UIView(frame: CGRectMake(0,0,500,200))
            rowView.backgroundColor = UIColor.redColor()
            //Add new row view to array
            rowArray.append(rowView)
            
            //Dear autoformat: I'll handle these constraints, thank you very much.
            rowView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
            //Generate Nw atomNodes and add to viewDic for autolayout and sub to current row view
            for ii in 1...scalingData.Nw {
                var tempAtomNode = UIImageView(image: image)
                tempAtomNode.setTranslatesAutoresizingMaskIntoConstraints(false)
                viewsDictionary["Atom"+String(ii)] = tempAtomNode
                rowView.addSubview(tempAtomNode)
            }
            
            //Sub current row view to main view (think we need to do before some of 
            //below constraining)
            self.addSubview(rowView)
            
            //var newSize = row1View.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
            
            //CONSTRAINTS BETWEEN ATOMS AND ROW VIEW
            //*Horizontal* constraints for atoms within one row:
            //Build string for horizontal constraints on atoms within this row. Make atoms all same
            //width and give standard spacing (could include custom spacing with metricsDictionary)
            var constraintString = "H:|-[Atom1]"
            for ii in 2...scalingData.Nw {
                constraintString += "-[Atom\(ii)(==Atom1)]"
            }
            constraintString += "-|"
            let constraintsH:Array = NSLayoutConstraint.constraintsWithVisualFormat(constraintString, options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)

            //*Vertical* constraints for atoms within one row:
            //Single constraints to keep heights of atoms same as widths
            var atomHeightConstraints = Array<NSLayoutConstraint>()
            for ii in 1...scalingData.Nw {
                atomHeightConstraints.append(NSLayoutConstraint(item: viewsDictionary["Atom\(ii)"]!, attribute: .Height, relatedBy: .Equal, toItem: viewsDictionary["Atom\(ii)"]!, attribute: .Width, multiplier: 1.0, constant: 0))
            }
            //Vertical centering constraints for each atom in the row view
            var atomVCentConstraints:[[AnyObject]] = []
            for ii in 1...scalingData.Nw {
                atomVCentConstraints.append(NSLayoutConstraint.constraintsWithVisualFormat("V:|[Atom\(ii)]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary))
            }
            //Add all constraints on atoms within roview
            for ii in 1...scalingData.Nw {
                rowView.addConstraints(atomVCentConstraints[ii-1])
            }
            rowView.addConstraints(atomHeightConstraints)
            rowView.addConstraints(constraintsH)
       
        }
        
        var viewsDictionary2 = Dictionary<String, UIView>()
        
        //CONSTRAINTS BETWEEN ROW VIEWS AND HOLDING SUPERVIEW
        //Loop through views
        for ii in 0...rowArray.count-1 {
            //Add row view(s) to view dictionary
            //!!!!! MAKE SINGLE DICTIONARY WORK WITH BOTH UIVIEW AND UIIMAGEVIEWS (DOWNCAST)
            viewsDictionary2["rowView\(ii+1)"] = rowArray[ii]
            //*Vertical* constraints for row views:
            //Allow row view's height to vary up to screen size, so that it can fit down to size of
            //atom contents, due to vertical VFL constraint that atoms are flush with the rowview
            //!!!!!SET THE MAXIMUM HEIGHT OF A ROWVIEW TO BE SCREENSIZE? (OR SCREENSIZE DIVIDED BY NH)
            let rowViewHeight = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(>=5)-[rowView\(ii+1)(<=999)]-(>=5)-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary2)
            //Center the row view vertically (!!!!REPLACE THIS WITH VFL FOR ALIGNING ALL ROWS 
            //VERTICALLY)
            
            
            
            //let rowConstraintY =  NSLayoutConstraint(item: rowArray[ii], attribute: .CenterY, relatedBy: .Equal, toItem: rowArray[ii].superview, attribute: .CenterY, multiplier: 1, constant: 0)
            //*Horizontal* constraints for row views:
            //Set width of row views to be equal to desired width of parent view
            //!!! SET THIS WIDTH TO BE PROGRAMATICALLY EQUAL TO PARENT VIEW WIDTH
            let rowViewWidth = NSLayoutConstraint.constraintsWithVisualFormat("H:|[rowView\(ii+1)(==500)]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary2)
            //Add all constraints on row views
            self.addConstraints(rowViewHeight)
            self.addConstraints(rowViewWidth)
        
        }
        
        //Generate constraints for all row views vertical alignment
        //Note that use spacer view (spView) to make sure sacrifice top and bottom padding equally
        //to fit all row views
        var spViewTop:UIView = UIView(frame: CGRectZero)
        var spViewBottom:UIView = UIView(frame: CGRectZero)
        self.addSubview(spViewTop)
        self.addSubview(spViewBottom)
        spViewTop.setTranslatesAutoresizingMaskIntoConstraints(false)
        spViewBottom.setTranslatesAutoresizingMaskIntoConstraints(false)
        viewsDictionary2["spViewTop"] = spViewTop
        viewsDictionary2["spViewBottom"] = spViewBottom
        var rowConstraintString = "V:|-[rowView1]"
        for ii in 2...rowArray.count {
            rowConstraintString += "-[rowView\(ii)(==rowView1)]"
        }
        rowConstraintString += "-|"
        let rowConstraintsH:Array = NSLayoutConstraint.constraintsWithVisualFormat(rowConstraintString, options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary2)
        self.addConstraints(rowConstraintsH)
        
    }
    

    
    //Finds the parameters for spacing out sprites
    func calcNums(H: Double, W: Double, ha: Double, wa: Double, R: Double) -> (Nw: Int, Nh: Int, rscale: Double) {
        
        
        var T1 = -R*(H*wa+W*ha)
        var T2 = pow(R,2.0)*pow(H*wa+W*ha,2.0)
        var T3 = 4*ha*wa*(9*R+10)*(11*R+10)*W*H
        var T4 = (2*ha*wa*(9*R+10)*(11*R+10))
        var rscale = (T1 + pow(T2+T3,0.5))/T4
        var Nw = ceil(100*rscale*ha*(R+1)/(H-R*rscale*ha))
        var Nh = ceil(100/Nw)
        
        //Don't think we need to check if we can get better as anything better than NwNh (for solutions) would imply Nw(Nh-1) = NwNh - Nw is still above 100. i.e. that if we take off Nw (so one row) we still get above 100 - but if this was possible then we would have gotten this in our original solution as it would have given us a lower number of rows to begin with (same argument is symmetric with respect to trying to reduce the number of columns).
        
        //Recalibrate rscale value to account for having had to ceil the Nw and Nh values
        rscale = W/(Nw*wa+(Nw+1)*R*wa)
        
        return(Int(Nw), Int(Nh), rscale)
    }
    
    
    //Returns a CGPoint for the position of sprite at location i,j
 
    
    //Update decays
    
    
}
