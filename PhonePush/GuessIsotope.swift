//
//  GuessIsotope.swift
//  PhonePush
//
//  Created by Nicholas Harrigan on 13/05/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

import UIKit

class guessIsotope: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var questionText = UITextView(frame: CGRect(x: 200, y: 200, width: 400, height: 200))
    var submitButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var checkViewAppearedForFirstTime = 0
    var textResizer:findTextSize?
    var Natoms = 100
    var collectionView:UICollectionView?
    var layout: atomCVLayout = atomCVLayout()
    var nucleusImage = UIImage(named: "nucleus")
    var clockImage = UIImage(named: "alarm_clock")
    var resultsIconImage = UIImage(named: "resultsIcon")
    var graphIconImage = UIImage(named: "graphIcon")
    var isotopeEncyclopediaIconImage = UIImage(named: "isotopeEncyclopediaIcon")
    var navBarView:UIView = UIView()
    var singleArrowRight = UIImage(named: "singleArrowRight")
    var singleArrowLeft = UIImage(named: "singleArrowLeft")
    var doubleArrowLeft = UIImage(named: "doubleArrowLeft")
    var doubleArrowRight = UIImage(named: "doubleArrowRight")
    var resultsIconView = UIButton()
    var isotopeEncyclopediaIconView = UIButton()
    var graphIconView = UIButton()
    var clockImageView = UIImageView(frame: CGRectMake(0,0,20,20))
    var currentTimeView = UILabel(frame: CGRectZero)
    var timeTextView = UILabel(frame:CGRectZero)
    var singleArrowLeftView = UIButton(frame: CGRectZero)
    var singleArrowRightView = UIButton(frame: CGRectZero)
    var doubleArrowLeftView = UIButton(frame: CGRectZero)
    var doubleArrowRightView = UIButton(frame: CGRectZero)
    var questionView = UIView(frame: CGRectMake(10,80,350,50))
    var timerView = UIView(frame: CGRectMake(10,80,350,50))
    var pickerView = UIPickerView(frame: CGRectMake(0,0,100,100))
    var isotopesDic:Array<[AnyObject]> = [["Carbon-15",2.45], ["Carbon-10",19.29], ["Nobelium-253",97], ["Fluorine-18", 6.586E3], ["Erbium-165", 37.3E3]]
    var nucleiArray:[UIImageView] = []
    //Instance of decayHandler
    var decayNuclei:decayHandler?
    var decayProb:Double = 0.03
    //Counts current time in smallest unit used
    var currentTime:Int = 0
    var currentIsotope: [AnyObject]?
    var unusedAnswerIsotopes:[Int] = []
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated);
        super.viewWillDisappear(animated)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.automaticallyAdjustsScrollViewInsets = false
        //Setup array of indicies for all isotopes that haven't yet been used as an answer
        for ii in 0...isotopesDic.count-1 {unusedAnswerIsotopes.append(ii)}
        
        //Randomly choose an isotope for the first question and set probabilities etc...
        chooseAnswerIsotope()
        
        //navigationController?.setNavigationBarHidden(false, animated: true)
        
        setupViews()
    
        setupConstraints()
        
        
    }
    
    func chooseAnswerIsotope() {
        //Randomly choose an isotope as corect asnwer this time
        var currentUnusedIsotopeIndex = Int(arc4random_uniform(UInt32(unusedAnswerIsotopes.count)))
        var currentIsotopeDicIndex = unusedAnswerIsotopes[currentUnusedIsotopeIndex]
        //Remove isotope from unusedanswerIsotopes as it is now 'used'
        unusedAnswerIsotopes.removeAtIndex(currentUnusedIsotopeIndex)
        //Set decay probability according to currentIsotope
        decayProb = halfLifeToProb(isotopesDic[currentIsotopeDicIndex][1] as! Double)
        //Set small and big units according to half-life of isotope
        
        
        println("currentUnusedIsotopeIndex \(currentUnusedIsotopeIndex)")
        println("currentIsotopeDicIndex \(currentIsotopeDicIndex)")
        println("decayProb \(decayProb)")
        println("Current isotope info: \(isotopesDic[currentIsotopeDicIndex])")
    }
    
    /*
    override func viewDidLayoutSubviews() {
        
    aas = atomArrayScene()
    
    }
*/
    
    
    override func viewDidAppear(animated: Bool) {
       
        
        questionText.editable = true
        var newSize = textResizer!.updateViewFont("")
        questionText.editable = false

        //questionText.editable = true
        //questionText.font = UIFont(name: questionText.font.fontName, size: CGFloat(newSize[questionText]!))
        //questionText.editable = false
        checkViewAppearedForFirstTime = 1
        
    }
    
    override func viewDidLayoutSubviews() {
        
        //Initialise decayHandler only when collectionView has laid out all nuclei
        //and only once.
        if collectionView != nil && nucleiArray.count == Natoms && decayNuclei == nil {
            println("==FOR COLLECTION VIEW: \(collectionView!.numberOfItemsInSection(0))")
            println(nucleiArray.count)
            decayNuclei = decayHandler(nucleiArray: nucleiArray,decayProb: decayProb)
        }
        
        //Need this first check to prevent crashes (orientation doesn't exist at start?)
        if checkViewAppearedForFirstTime == 1 {
            
            
            
            //Now check for device orientation
            if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation))
            {
                //Check whether there is already a value for that view set in dictionary?
                //println("landscape")
                questionText.editable = true
                textResizer!.updateViewFont("Landscape")
                questionText.editable = false
            }
            if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation))
            {
                //println("Portrait")
                questionText.editable = true
                textResizer!.updateViewFont("Portrait")
                questionText.editable = false
            }
        }
        
    }
    
    func setupViews() {
        
        //Setting up navigationBar view for activity
        navBarView.backgroundColor = UIColor.lightGrayColor()
        navBarView.alpha = 0.5
        
        
        //Setup buttons for navigationBar view
        resultsIconView.contentMode = UIViewContentMode.ScaleAspectFit
        resultsIconView.setImage(resultsIconImage, forState: UIControlState.Normal)
        resultsIconView.addTarget(self, action: "goToResultsTable:", forControlEvents: UIControlEvents.TouchUpInside)
        graphIconView.contentMode = UIViewContentMode.ScaleAspectFit
        graphIconView.setImage(graphIconImage, forState: UIControlState.Normal)
        graphIconView.addTarget(self, action: "goToResultsGraph:", forControlEvents: UIControlEvents.TouchUpInside)
        isotopeEncyclopediaIconView.contentMode = UIViewContentMode.ScaleAspectFit
        isotopeEncyclopediaIconView.setImage(isotopeEncyclopediaIconImage, forState: UIControlState.Normal)
        isotopeEncyclopediaIconView.addTarget(self, action: "goToIsotopeEncyclopedia:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
       
        //Setup collection view for atoms
        layout = atomCVLayout(atomSize: CGSizeMake(10,10), numAtoms:Natoms)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        collectionView = UICollectionView(frame: CGRectMake(0,0,500,600), collectionViewLayout: layout)
        collectionView!.delegate = self
        collectionView!.dataSource = self
        collectionView!.backgroundColor = UIColor.clearColor()
        collectionView!.scrollEnabled = false
        collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "myCell")

        
        //View for containing title and picker
        questionView.clipsToBounds = true
        
        //View for containing timer control
        timerView.clipsToBounds = true
        //timerView.backgroundColor = UIColor.blueColor()
        
        //Setup pickerview
        pickerView.delegate = self
        pickerView.dataSource = self
        
        
        
        //Ask question
        questionText = UITextView(frame: CGRect(x: 50, y: 100, width: 300, height: 50));
        questionText.font = UIFont(name: "Arial", size: 10)
        questionText.backgroundColor = UIColor.clearColor()
        questionText.editable = false
        questionText.text = "This Isotope is...."
        //questionText.backgroundColor = UIColor.greenColor()
        
        
        //Answer submit button
        submitButton.frame = CGRectMake(screenSize.width-275, screenSize.height-140, 250, 125)
        submitButton.backgroundColor = UIColor(red: 245.0/255.0, green: 121.0/255.0, blue: 121.0/255.0, alpha: 1.0)
        submitButton.setTitle("Submit", forState: UIControlState.Normal)
        submitButton.layer.cornerRadius = 20
        submitButton.layer.borderWidth = 5
        submitButton.layer.borderColor = UIColor.blackColor().CGColor
        submitButton.titleLabel!.font =  UIFont(name: "Arial", size: 60)
        submitButton.addTarget(self, action: "submitAnswer:", forControlEvents: .TouchUpInside)
        submitButton.titleLabel!.adjustsFontSizeToFitWidth = true
        
        //Setup clock image view
        clockImageView.contentMode = UIViewContentMode.ScaleAspectFit
        clockImageView.image = clockImage
        currentTimeView.text = "0m 0s"
        currentTimeView.sizeToFit()
        
        //Setup clock buttons
        singleArrowLeftView.contentMode = UIViewContentMode.ScaleAspectFit
        singleArrowRightView.contentMode = UIViewContentMode.ScaleAspectFit
        doubleArrowLeftView.contentMode = UIViewContentMode.ScaleAspectFit
        doubleArrowRightView.contentMode = UIViewContentMode.ScaleAspectFit

        singleArrowLeftView.setImage(singleArrowLeft, forState: UIControlState.Normal)
        singleArrowRightView.setImage(singleArrowRight, forState: UIControlState.Normal)
        doubleArrowLeftView.setImage(doubleArrowLeft, forState: UIControlState.Normal)
        doubleArrowRightView.setImage(doubleArrowRight, forState: UIControlState.Normal)
        singleArrowRightView.addTarget(self, action: "forwardsTimeSmallUnit:", forControlEvents: UIControlEvents.TouchUpInside)
        singleArrowLeftView.addTarget(self, action: "backwardsTimeSmallUnit:", forControlEvents: UIControlEvents.TouchUpInside)
        doubleArrowRightView.addTarget(self, action: "forwardsTimeBigUnit:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        var test = UIButton(frame: CGRectZero)
        

        /*
        singleArrowLeftView.backgroundColor = UIColor.redColor()
        singleArrowRightView.backgroundColor = UIColor.redColor()
        doubleArrowLeftView.backgroundColor = UIColor.redColor()
        doubleArrowRightView.backgroundColor = UIColor.redColor()
        */
        
        //Stop swift from adding its own constraints for all views in use by autolayout
        questionText.setTranslatesAutoresizingMaskIntoConstraints(false)
        submitButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        collectionView!.setTranslatesAutoresizingMaskIntoConstraints(false)
        pickerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        questionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        timerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        clockImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        singleArrowLeftView.setTranslatesAutoresizingMaskIntoConstraints(false)
        singleArrowRightView.setTranslatesAutoresizingMaskIntoConstraints(false)
        doubleArrowLeftView.setTranslatesAutoresizingMaskIntoConstraints(false)
        doubleArrowRightView.setTranslatesAutoresizingMaskIntoConstraints(false)
        currentTimeView.setTranslatesAutoresizingMaskIntoConstraints(false)
        timeTextView.setTranslatesAutoresizingMaskIntoConstraints(false)
        navBarView.setTranslatesAutoresizingMaskIntoConstraints(false)
        resultsIconView.setTranslatesAutoresizingMaskIntoConstraints(false)
        graphIconView.setTranslatesAutoresizingMaskIntoConstraints(false)
        isotopeEncyclopediaIconView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        //Add subviews to main view
        self.view.addSubview(questionView)
        self.view.addSubview(collectionView!)
        self.view.addSubview(timerView)
        self.view.addSubview(navBarView)
        //Add subviews to question view
        self.questionView.addSubview(questionText)
        self.questionView.addSubview(pickerView)
        self.questionView.addSubview(submitButton)
        //self.view.addSubview(questionText)
        //Add subviews to clock and time view
        //self.currentTimeView.addSubview(timeTextView)
        //self.currentTimeView.addSubview(clockImageView)
        //Add subviews to timer view that contains buttons as well
        self.timerView.addSubview(currentTimeView)
        self.timerView.addSubview(singleArrowLeftView)
        self.timerView.addSubview(singleArrowRightView)
        self.timerView.addSubview(doubleArrowLeftView)
        self.timerView.addSubview(doubleArrowRightView)
        self.navBarView.addSubview(resultsIconView)
        self.navBarView.addSubview(graphIconView)
        self.navBarView.addSubview(isotopeEncyclopediaIconView)
    }
    
    func setupConstraints() {
        //Dictionary for all views to be managed by autolayout
        let viewsDic = ["questionText":questionText,"submitButton":submitButton, "collectionView":collectionView!, "pickerView":pickerView, "questionView": questionView,"timerView":timerView,"clockImageView":clockImageView,"singleArrowLeftView":singleArrowLeftView,"singleArrowRightView":singleArrowRightView,"doubleArrowLeftView":doubleArrowLeftView,"doubleArrowRightView":doubleArrowRightView, "currentTimeView":currentTimeView,"timeTextView":timeTextView,"navBarView":navBarView,"resultsIconView":resultsIconView,"graphIconView":graphIconView,"isotopeEncyclopediaIconView":isotopeEncyclopediaIconView]
        
        //Metrics used by autolayout
        let metricsDictionary = ["minGraphWidth": 20]

        //Constraints within currentTimeView
        
        //var timeTextV = NSLayoutConstraint.constraintsWithVisualFormat("H:|[timeTextView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDic)
       // var clockImageViewV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[clockImageView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDic)
       // var internalCurrentTimeViewH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[clockImageView(>=10)]-[timeTextView(>=10)]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDic)
        

        //Constraints within questionView
        var questionTextV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[questionText]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDic)
        var pickerViewV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[pickerView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDic)
        var submitButtonV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[submitButton]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDic)
        var questionViewInternalH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[questionText(>=130)]-[pickerView(>=70,<=200)]-[submitButton(>=50)]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDic)
        //let submitButtonHeightPercent = NSLayoutConstraint(item: submitButton, attribute: .Height, relatedBy: .Equal, toItem: submitButton, attribute: .Width, multiplier: 0.5, constant: 0)
        
        //Constraints within timerView
        var currentTimeViewV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[currentTimeView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDic)
        var singleArrowLeftViewV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[singleArrowLeftView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDic)
        var singleArrowRightViewV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[singleArrowRightView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDic)
        var doubleArrowLeftViewV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[doubleArrowLeftView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDic)
        var doubleArrowRightViewV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[doubleArrowRightView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDic)
        //Constraints to maintain aspect ratios of icons within timerView
        var singleArrowLeftAR:CGFloat = singleArrowLeft!.size.width/singleArrowLeft!.size.height
        var singleArrowRightAR:CGFloat = singleArrowRight!.size.width/singleArrowRight!.size.height
        var doubleArrowLeftAR:CGFloat = doubleArrowLeft!.size.width/doubleArrowLeft!.size.height
        var doubleArrowRightAR:CGFloat = doubleArrowRight!.size.width/doubleArrowRight!.size.height
        let sALConstraintAR = NSLayoutConstraint(item: singleArrowLeftView, attribute: .Width, relatedBy: .Equal, toItem: singleArrowLeftView, attribute: .Height, multiplier: singleArrowLeftAR, constant: 0)
        let sARConstraintAR = NSLayoutConstraint(item: singleArrowRightView, attribute: .Width, relatedBy: .Equal, toItem: singleArrowRightView, attribute: .Height, multiplier: singleArrowRightAR, constant: 0)
        let dALConstraintAR = NSLayoutConstraint(item: doubleArrowLeftView, attribute: .Width, relatedBy: .Equal, toItem: doubleArrowLeftView, attribute: .Height, multiplier: doubleArrowLeftAR, constant: 0)
        let dARConstraintAR = NSLayoutConstraint(item: doubleArrowRightView, attribute: .Width, relatedBy: .Equal, toItem: doubleArrowRightView, attribute: .Height, multiplier: doubleArrowRightAR, constant: 0)
        
        
        let currentTimeViewH = NSLayoutConstraint(item: currentTimeView, attribute: .Width, relatedBy: .Equal, toItem: currentTimeView, attribute: .Height, multiplier: 1.0, constant: 0)
        var clockAndArrowsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(50@100)-[doubleArrowLeftView]-[singleArrowLeftView]-[currentTimeView]-[singleArrowRightView]-[doubleArrowRightView]-(50@100)-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDic)
        
        //Constraints within navBarView
        var navBarViewHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=20)-[isotopeEncyclopediaIconView]-(100)-[resultsIconView]-(100)-[graphIconView]-(>=20)-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDic)
        var resultsIconViewV = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(20)-[resultsIconView]-(20)-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDic)
        var graphIconViewV = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(20)-[graphIconView]-(20)-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDic)
        var isotopeEncyclopediaIconViewV = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(20)-[isotopeEncyclopediaIconView]-(20)-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDic)
        //Constraints to keep navBarView icons with correct aspect ratio
        var resultsIconAR:CGFloat = resultsIconImage!.size.width/resultsIconImage!.size.height
        var graphIconAR:CGFloat = graphIconImage!.size.width/graphIconImage!.size.height
        var isotopeEncyclopediaIconAR:CGFloat = isotopeEncyclopediaIconImage!.size.width/isotopeEncyclopediaIconImage!.size.height
        let resultsIconConstraintAR = NSLayoutConstraint(item: resultsIconView, attribute: .Width, relatedBy: .Equal, toItem: resultsIconView, attribute: .Height, multiplier: resultsIconAR, constant: 0)
        let graphIconConstraintAR = NSLayoutConstraint(item: graphIconView, attribute: .Width, relatedBy: .Equal, toItem: graphIconView, attribute: .Height, multiplier: graphIconAR, constant: 0)
        let isotopeEncyclopediaIconConstraintAR = NSLayoutConstraint(item: isotopeEncyclopediaIconView, attribute: .Width, relatedBy: .Equal, toItem: isotopeEncyclopediaIconView, attribute: .Height, multiplier: isotopeEncyclopediaIconAR, constant: 0)
        
        
        //Constraints within main view
        var mainHConstraintsNavBarView = NSLayoutConstraint.constraintsWithVisualFormat("H:|[navBarView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDic)
        var mainHConstraintsQview = NSLayoutConstraint.constraintsWithVisualFormat("H:|[questionView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDic)
        let timerViewCenterH = NSLayoutConstraint(item: timerView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0)
        var mainHConstraintsCV = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[collectionView]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDic)
        var mainVConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[navBarView(80)]-[timerView(<=50,>=30)]-[collectionView]-[questionView]-(>=5)-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDic)
        
        //Constraints for setting the views on self as a percentage of screensize
        let qViewHeightPercent = NSLayoutConstraint(item: questionView, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 0.15, constant: 0)
        let cViewHeightPercent = NSLayoutConstraint(item: collectionView!, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 0.75, constant: 0)
        //qViewHeightPercent.priority = 100.0
        cViewHeightPercent.priority = 100.0
        
        //Add constraints to relevant view
        self.questionView.addConstraints(questionTextV+pickerViewV+questionViewInternalH+submitButtonV)
        self.view.addConstraints(mainHConstraintsQview+mainHConstraintsCV)
        self.view.addConstraints(mainVConstraints+[qViewHeightPercent,cViewHeightPercent])
        self.view.addConstraint(timerViewCenterH)
        self.view.addConstraints(mainHConstraintsNavBarView)
        self.timerView.addConstraints(currentTimeViewV)
        self.timerView.addConstraint(currentTimeViewH)
        self.timerView.addConstraints(singleArrowLeftViewV+singleArrowRightViewV+doubleArrowLeftViewV+doubleArrowRightViewV)
        self.timerView.addConstraints([sALConstraintAR,sARConstraintAR,dALConstraintAR,dARConstraintAR])
        self.timerView.addConstraints(clockAndArrowsH)
        self.navBarView.addConstraints(navBarViewHConstraints+[resultsIconConstraintAR]+resultsIconViewV)
        self.navBarView.addConstraints(graphIconViewV+[graphIconConstraintAR])
        self.navBarView.addConstraints(isotopeEncyclopediaIconViewV+[isotopeEncyclopediaIconConstraintAR])
        //self.currentTimeView.addConstraints(internalCurrentTimeViewH+clockImageViewV+timeTextV)
        
        //Size font in title to fit
        textResizer = findTextSize(vArray: [questionText])
       
        
    }
    
    //Button target functions
    
    func forwardsTimeSmallUnit(sender: UIButton) {
        //Only continue if there are any nuclei left to decay
        if decayNuclei?.activeNuclei.count > 0 {
            //Call method to deal update the nuclei in collectionView
            decayNuclei?.forwardTimeStep(currentTime)
            //Update the time counter
            currentTime += 1
            //Call function to update current time display (converting to big unit as well)
            updateCurrentTimeView()
        }
    }
    
    func forwardsTimeBigUnit(sender:UIButton) {
        //Here, sample a number from distribution for number that decay at every time step within
        //this big step and then randomly choose from active nuclei that many specific nuclei to
        //decay.
        //We need to sample from the distribution of N(t) given N(0) (we will always use N(1) 
        //and N(0). N(t) = N(0)exp-lt gives expectation of this distribution right?
        
        //Sample from poisson distribution to find how many to decay (mean, mu is N*p=N*lambda)
        if decayNuclei?.activeNuclei.count > 0 {
            println("ForwardsBigStep at currentTime = \(currentTime)")
            //Call method to deal update the nuclei in collectionView
            var timeToProgress = decayNuclei?.forwardLargeTimeStep(currentTime)
            //Update the time counter
            currentTime += timeToProgress!
            //Call function to update current time display (converting to big unit as well)
            updateCurrentTimeView()
            println("Updated currentTime to = \(currentTime)")
        }
        
    }
    
    func backwardsTimeSmallUnit(sender:UIButton) {
        //Only go backwards if not yet at first time-step
        println("Going backwards starting at currentTime = \(currentTime)")
        
        if currentTime > 0 {
            decayNuclei?.backwardTimeStep(currentTime)
            currentTime -= 1
            updateCurrentTimeView()
        }
    }
    
    func goToResultsTable(sender:UIButton) {
        var resultsTableVC:resultsTable = resultsTable(tViewDataSource: decayNuclei!)
        self.navigationController?.pushViewController(resultsTableVC, animated: true)
    }
    
    func goToResultsGraph(sender:UIButton) {
        if decayNuclei != nil {
            if decayNuclei!.numberCount.count > 1 {
                var resultsGraphVC:resultsGraph = resultsGraph(plotYData: decayNuclei!.numberCount)
                self.navigationController?.pushViewController(resultsGraphVC, animated: true)
            } else {
                //No decays have occured yet, so tell user to create some before plotting:
                let alertController = UIAlertController(title: "No decays yet", message: "Decay some atoms first!", preferredStyle: .Alert)
                let okButton = UIAlertAction(title: "OK", style: .Default)
                    {(action) in
                        //Completion handler for what to do if teacher is clicked
                        //Run returnTeacher function that sends back choice to server
                        alertController.removeFromParentViewController()
                }
                alertController.addAction(okButton)
                self.presentViewController(alertController, animated: true) {
                }
            }
        }
    }
    
    func goToIsotopeEncyclopedia(sender:UIButton) {
        var isotopeEncyclopediaVC:IsotopeEncyclopedia = IsotopeEncyclopedia()
        self.navigationController?.pushViewController(isotopeEncyclopediaVC, animated: true)
    }
    
    func submitAnswer(sender:UIButton) {
        //Check whether currently active pickerView choice equals the correct isotope, and if so
        //then give popup saying correct and call a function to reset and give another isotope 
        //as question. If not then give popup saying wrong.
    }
    
    
    //Updates currentTimeView text (small+big unit) given the currentTime in smallest Unit
    func updateCurrentTimeView() {
        currentTimeView.text = "\(currentTime/60)m \(currentTime%60)s"
        currentTimeView.sizeToFit()
    }

    //Delegate methods for UICollectionView
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Natoms
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        //Produce nucleus UIImageView for this cell of the collectionView
        var nucleus = UIImageView(frame: CGRectMake(0,0,20,20))
        nucleus.contentMode = UIViewContentMode.ScaleAspectFit
        nucleus.contentMode = UIViewContentMode.ScaleAspectFit
        nucleus.image = nucleusImage
        //Assign to cell in collectionView
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("myCell", forIndexPath: indexPath) as! UICollectionViewCell
        cell.contentView.addSubview(nucleus)
        nucleus.setTranslatesAutoresizingMaskIntoConstraints(false)
        //Store reference to this UIImageView in array that we will use to decay nuclei
        nucleiArray.append(nucleus)
        
        
        var tConH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[nucleus]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["nucleus":nucleus])
        var tConV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[nucleus]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["nucleus":nucleus])
        cell.addConstraints(tConH + tConV)
        
        return cell
        
    }
    
    
    //UIpickerView delegate and datasource methods
    //Data source methods
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return isotopesDic.count
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    //Delegate methods
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return isotopesDic[row][0] as! String
    }
    
    func halfLifeToProb(halfLife: Double) -> Double {
        //Calculate the probability of decay over one timestep given half-life
        var lambda = log(2.0)/halfLife
        return lambda
    }
    
    
}
