//
//  VideoController.swift
//  SAVideoPlayer
//
//  Created by Paresh Prajapati on 24/05/19.
//  Copyright © 2019 Solutionanalysts. All rights reserved.
//

import UIKit

public class VideoController : UIView{
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self._setup()
    }
    
    #if !TARGET_INTERFACE_BUILDER
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self._setup()
    }
    #endif
    
    override public func prepareForInterfaceBuilder() {
        self._setup()
    }
    
    func _setup(){
        self.setToolBar()
    }
    
    var fullscreenButton : UIButton!
    var playButton : UIButton!
    var nextButton : UIButton!
    var previousButton : UIButton!
    public var slider : BufferSlider!
    
    var playImage : UIImage?
    var pauseImage : UIImage?
    var exitfullscreenImage : UIImage?
    var fullscreenImage : UIImage?
    var nextbtnImage : UIImage?
    var previousbtnImage : UIImage?
    public var toolView = UIView()
    
    public var labelTime : UILabel!
    public var totalTime : UILabel!
    
    public var playbuttonImage : UIImage?{
        get{
            return playImage
        }
        set{
            self.playImage = newValue
        }
    }
    
    public var pausebuttonImage : UIImage?{
        get{
            return pauseImage
        }
        set{
            self.pauseImage = newValue
        }
    }
    
    public var fullscreenbuttonImage : UIImage?{
        get{
            return fullscreenImage
        }
        set{
            self.fullscreenImage = newValue
        }
    }
    
    public var exitscreenbuttonImage : UIImage?{
        get{
            return exitfullscreenImage
        }
        set{
            self.exitfullscreenImage = newValue
        }
    }
    
    public var nextButtonImage : UIImage?{
        get{
            return nextbtnImage
        }
        set{
            self.nextbtnImage = newValue
        }
    }
    
    public var previousButtonImage : UIImage?{
        get{
            return previousbtnImage
        }
        set{
            self.previousbtnImage = newValue
        }
    }
    
    
    
    private func addConstraintCenter(cview: UIView, multiplier : CGFloat)
    {
        
        
        let widthConstraint = NSLayoutConstraint(item: cview, attribute: .width, relatedBy: .equal,
                                                 toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100)
        
        let heightConstraint = NSLayoutConstraint(item: cview, attribute: .height, relatedBy: .equal,
                                                  toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100)
        
        
        let xConstraint = NSLayoutConstraint(item: cview, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: multiplier, constant: 0)
        
        let yConstraint = NSLayoutConstraint(item: cview, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        
//        self.addConstraint(widthConstraint)
//        self.addConstraint(heightConstraint)
//       self.addConstraint(xConstraint)
//        self.addConstraint(yConstraint)
        NSLayoutConstraint.activate([xConstraint, yConstraint,widthConstraint,(heightConstraint)])
    }
    
    private func addConstraintToolbar()
    {
        
        //Tool View Constraint
        self.toolView.translatesAutoresizingMaskIntoConstraints = false
        let leadingtoolview = NSLayoutConstraint(item: self.toolView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        
        let trailingtoolview = NSLayoutConstraint(item: self.toolView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        
        let bottomtoolview = NSLayoutConstraint(item: self.toolView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        
        let heightConstrainttool = NSLayoutConstraint(item: toolView, attribute: .height, relatedBy: .equal,
                                                  toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50)
        NSLayoutConstraint.activate([leadingtoolview, trailingtoolview,bottomtoolview, heightConstrainttool])
        
        //Start TIme label Constraint
        let labelTimetop = NSLayoutConstraint(item: self.labelTime, attribute: .top, relatedBy: .equal, toItem: self.toolView, attribute: .top, multiplier: 1, constant: -8)
        
        let labelTimeleading = NSLayoutConstraint(item: self.labelTime, attribute: .leading, relatedBy: .equal, toItem: self.toolView, attribute: .leading, multiplier: 1, constant: 8)
        NSLayoutConstraint.activate([labelTimetop, labelTimeleading])
        
        //TotalTime Constraint
        let labelTotaltop = NSLayoutConstraint(item: self.totalTime, attribute: .top, relatedBy: .equal, toItem: self.toolView, attribute: .top, multiplier: 1, constant: -8)
        let labelTotaltrailing = NSLayoutConstraint(item: self.totalTime, attribute: .trailing, relatedBy: .equal, toItem: self.fullscreenButton!, attribute: .leading, multiplier: 1, constant: 8)
        NSLayoutConstraint.activate([labelTotaltop, labelTotaltrailing])
        
        //Slider and Full Screeen Constraint
         let leading = NSLayoutConstraint(item: self.slider!, attribute: .leading, relatedBy: .equal, toItem: self.toolView, attribute: .leading, multiplier: 1, constant: 8)
        let trailing = NSLayoutConstraint(item: self.slider!, attribute: .trailing, relatedBy: .equal, toItem: self.fullscreenButton, attribute: .leading, multiplier: 1, constant: 8)
        let botton = NSLayoutConstraint(item: self.slider!, attribute: .bottom, relatedBy: .equal, toItem: self.toolView, attribute: .bottom, multiplier: 1, constant: 8)
        let heightConstraint = NSLayoutConstraint(item: slider!, attribute: .height, relatedBy: .equal,
                                                  toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 66)
        let tralingexpand = NSLayoutConstraint(item: self.fullscreenButton!, attribute: .trailing, relatedBy: .equal, toItem: self.toolView, attribute: .trailing, multiplier: 1, constant: 8)

        let bottomfullscreen = NSLayoutConstraint(item: self.fullscreenButton!, attribute: .bottom, relatedBy: .equal, toItem: self.toolView, attribute: .bottom, multiplier: 1, constant: 8)
        
        let widthConstraint = NSLayoutConstraint(item: fullscreenButton!, attribute: .width, relatedBy: .equal,
                                                 toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 66)
        let heightfullscreenConstraint = NSLayoutConstraint(item: fullscreenButton!, attribute: .height, relatedBy: .equal,
                                                  toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 66)
        
        NSLayoutConstraint.activate([leading, botton,trailing,tralingexpand,bottomfullscreen,widthConstraint,(heightConstraint),heightfullscreenConstraint])
        
        
    }
    
    private func setToolBar()
    {
        //set Slider
        self.backgroundColor = UIColor.clear
        let trailing = 78
        self.slider = BufferSlider(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(self.frame.size.width - CGFloat(32 + trailing)), height: CGFloat(20)))
        
        //Configure Slider
        slider.baseColor = UIColor.blue
        slider.progressColor = UIColor.clear
        slider.bufferColor = UIColor.yellow
        slider.sliderHeight = 4
        slider.bufferStartValue = 0
        slider.borderWidth = 2
        slider.roundedSlider = true
        
        //Set Fullscreen
        self.fullscreenButton = UIButton(type: .custom)
        self.fullscreenButton?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(70), height: CGFloat(70))
        self.fullscreenButton?.translatesAutoresizingMaskIntoConstraints = false
        self.fullscreenImage = UIImage(named: "fullscreen@2x", in: self.getBundle(resource: "fullscreen@2x", ofType: ".png"), compatibleWith: nil)
        self.exitfullscreenImage = UIImage(named: "Colaps@2x", in: self.getBundle(resource: "Colaps@2x", ofType: ".png"), compatibleWith: nil)
        self.fullscreenButton?.setImage(self.fullscreenImage, for: .normal)
        
        //Set PlayPause Button
        self.playButton = UIButton(type: .custom)
        self.playButton?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(70), height: CGFloat(70))
        self.playButton?.translatesAutoresizingMaskIntoConstraints = false
        self.playImage = UIImage(named: "play@2x", in: self.getBundle(resource: "play@2x", ofType: ".png"), compatibleWith: nil)
        self.pauseImage = UIImage(named: "pause@2x", in: self.getBundle(resource: "pause@2x", ofType: ".png"), compatibleWith: nil)
        self.playButton?.setImage(self.playImage, for: .normal)
        
        ///Set next button image
        self.nextButton = UIButton(type: .custom)
        self.nextButton?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(70), height: CGFloat(70))
        self.nextbtnImage = UIImage(named: "fast-forward", in: self.getBundle(resource: "fast-forward", ofType: ".png"), compatibleWith: nil)
        self.nextButton?.translatesAutoresizingMaskIntoConstraints = false
        self.nextButton?.setImage(self.nextbtnImage, for: .normal)
        //Set Previous button image
        self.previousButton = UIButton(type: .custom)
        self.previousButton?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(70), height: CGFloat(70))
        self.previousbtnImage = UIImage(named: "backward", in: self.getBundle(resource: "backward", ofType: ".png"), compatibleWith: nil)
        self.previousButton?.translatesAutoresizingMaskIntoConstraints = false
        self.previousButton?.setImage(self.previousbtnImage, for: .normal)
        
        //tool View
        
        toolView = UIView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(70), height: CGFloat(70)))
        toolView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        self.addSubview(toolView)
        
        self.toolView.addSubview(self.fullscreenButton!)
        self.toolView.addSubview(slider)
        self.addSubview(self.playButton)
        self.addConstraintCenter(cview: self.playButton,multiplier: 1)
        self.addSubview(self.nextButton)
        self.addConstraintCenter(cview: self.nextButton,multiplier: 1.5)
        self.addSubview(self.previousButton)
        self.addConstraintCenter(cview: self.previousButton,multiplier: 0.5)
        self.slider.translatesAutoresizingMaskIntoConstraints = false
        
        self.labelTime = UILabel(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(70), height: CGFloat(21)))
        self.labelTime.numberOfLines = 0
        self.labelTime.sizeToFit()
        self.labelTime.textColor = UIColor.black
        self.labelTime.font = UIFont.boldSystemFont(ofSize: 16)
        self.labelTime.translatesAutoresizingMaskIntoConstraints = false
        self.toolView.addSubview(labelTime)
        
        self.totalTime = UILabel(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(70), height: CGFloat(21)))
        self.totalTime.numberOfLines = 0
        self.totalTime.sizeToFit()
        self.totalTime.textColor = UIColor.black
        self.totalTime.font = UIFont.boldSystemFont(ofSize: 16)
        self.totalTime.translatesAutoresizingMaskIntoConstraints = false
        self.toolView.addSubview(totalTime)
        
        
        addConstraintToolbar()
    }
    
    func getBundle(resource: String, ofType: String) -> Bundle?
    {
        let bundlePath = Bundle.main.path(forResource: resource, ofType:ofType)
        return Bundle.init(path: bundlePath!)
        
    }

}