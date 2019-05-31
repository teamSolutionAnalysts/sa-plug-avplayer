//
//  ViewController.swift
//  SAVideoPlayer
//
//  Created by Paresh Prajapati on 13/05/19.
//  Copyright © 2019 Solutionanalysts. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices

class ViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var aspectRationVideoView: NSLayoutConstraint!
    @IBOutlet weak var lblDislikes: UILabel!
    @IBOutlet weak var lblLikes: UILabel!
    @IBOutlet weak var viewOverlay: VideoController!
    @IBOutlet weak var viewVideo: ViewVideo!

    var arrVideos = DemoData().mediaJSON
    var arrlocalVideo:[String] =  ["filename", "filename1","filename2"]
    var index = 0
    var dropdown : UIView?
    var videoID = 0
    var isAnimating = false
    var swipe : UIPanGestureRecognizer?
    var swipeoverlay : UIPanGestureRecognizer?
    var url : String = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4"
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnClose.alpha = 0
        self.viewOverlay.isHidden = true
        self.view.isUserInteractionEnabled = false
        DispatchQueue.main.async {
            //Play video locally
//            self.setUpPlayerWithLocal()
            //Play video with url
            self.setUpPlayerWithURlStreaming()
            NotificationCenter.default.addObserver(self, selector: #selector(self.didChangeOrientation), name: UIDevice.orientationDidChangeNotification, object: nil)
            self.btnClose.layer.cornerRadius = self.btnClose.frame.size.height / 2
            self.setupDropdown()
            self.view.isUserInteractionEnabled = true
        }
    }
    
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.isAnimating == false && self.viewVideo.isEmbeddedVideo == false
        {
            self.viewVideo.playerLayer?.frame = self.viewVideo.bounds
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewOverlay.backgroundColor = UIColor.clear
        AppUtility.lockOrientation(.all)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.viewVideo.pause()
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        AppUtility.lockOrientation(.portrait)
    }
    
    // MARK: - Other Methods
    @objc func didChangeOrientation(gesture : Notification)
    {
        self.dropdown?.isHidden = true
    }
    
    //MARK: Class methods
    func setUpPlayerWithURlStreaming()
    {
        viewVideo.configure(url: self.url,ControllView: self.viewOverlay)
        viewVideo.play()
        
        // Other optional Configuration
        viewVideo.saveVideoLocally = false
        viewVideo.delegate = self
        viewVideo.currentVideoID = self.videoID
        
    }
    
    func formateURl(path : URL) -> URL?
    {
        let fileManager = FileManager()
        let newPath = path.appendingPathExtension("mp4")
        if fileManager.fileExists(atPath: path.absoluteString)
        {
            do{
                try fileManager.createSymbolicLink(atPath: newPath.absoluteString, withDestinationPath: path.absoluteString)
                
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
        return newPath
    }
    
    
    func setUpPlayerWithLocal()
    {
        viewVideo.configure(ControllView: self.viewOverlay,localPath:self.arrlocalVideo[self.index],fileextension : "mp4")
        viewVideo.play()
        
        //Other optional configuration
        viewVideo.delegate = self
        viewVideo.currentVideoID = self.videoID
    }
    
    func animateLikeDisLike(like:Bool)
    {
        let transition = CATransition()
        transition.duration = 0.2
        transition.type = CATransitionType.moveIn
        transition.subtype = CATransitionSubtype.fromBottom
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        if like{
            self.lblLikes.layer.add(transition, forKey: "LikeAnimation")
        }
        else
        {
            self.lblDislikes.layer.add(transition, forKey: "DisLikeAnimation")
        }
    }
    
    // MARK: - IBActions
    @IBAction func btnCloseTouched(_ sender: Any) {
        if self.viewVideo.isMiniMized{
            self.removeFromParent()
            self.view.removeFromSuperview()
            print("\nremoved")
        }
    }
    
    @IBAction func btnLikeTouched(_ sender: Any) {
        var likes = self.lblLikes.toInt()
        likes += 1
        self.animateLikeDisLike(like: true)
        self.lblLikes.text = "\(likes)"
    }
    
    @IBAction func btnDisLikeTouched(_ sender: Any) {
        var likes = self.lblDislikes.toInt()
        likes += 1
        self.animateLikeDisLike(like: false)
        self.lblDislikes.text = "\(likes)"
    }
    
    @IBAction func btnRateTouched(_ sender: Any, forEvent event : UIEvent) {
        guard self.dropdown?.isHidden == true else {
            self.dropdown?.isHidden = true
            return
        }
    }
    
    func setupDropdown()
    {
        let items = ["0.2","0.5", "1", "1.666","2"]
        dropdown = UIView(frame:CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(120), height: CGFloat(items.count * 30)))
        dropdown?.backgroundColor = UIColor.white
        for i in 0..<items.count{
            let button = UIButton(frame: CGRect(x: CGFloat(0), y: CGFloat(i * 30), width: CGFloat(dropdown?.frame.size.width ?? 120), height: CGFloat(30)))
            button.setTitle(items[i], for: .normal)
            button.addTarget(self, action: #selector(didTouchedDropDown), for: .touchUpInside)
            button.titleLabel?.textColor = UIColor.black
            button.backgroundColor = UIColor.lightGray
            dropdown?.addSubview(button)
        }
        self.view.addSubview(self.dropdown!)
        self.dropdown?.isHidden = true
    }
    
    @objc func didTouchedDropDown(sender : UIButton)
    {
        for i in (self.dropdown?.subviews ?? [])
        {
            (i as! UIButton).backgroundColor = UIColor.lightGray
        }
        sender.backgroundColor = UIColor.darkGray
        let rate = Float(sender.titleLabel?.text ?? "1") ?? 1
        self.viewVideo.changePlayerRate(rate: rate)
        self.dropdown?.isHidden = true
    }
}

// MARK: - Player Delegate Methods
extension ViewController : PlayerEventDelegate
{
    func SAAVPlayer(avplayer: AVPlayer?, didFailwith error: String?) {
        print(error ?? "")
    }
    
    func SAAVPlayer(minimizevideoScreen: Bool) {
        DispatchQueue.main.async {
            if minimizevideoScreen{
                self.btnClose.alpha = 1
            }
            else{
                self.btnClose.alpha = 0
            }
        }
    }
    
    func SAAVPlayer(panGesture sender: UIGestureRecognizer?) {
        guard let sender = sender else{
            return
        }
        let touchPoint = sender.location(in: self.viewVideo?.window)
        if sender.state == UIGestureRecognizer.State.began {
            initialTouchPoint = touchPoint
            if touchPoint.y - initialTouchPoint.y > 0 && self.viewVideo.isFullscreen == false{
                self.isAnimating = true
                //self.viewVideo.pause()
            }
        } else if sender.state == UIGestureRecognizer.State.changed {
            if (touchPoint.x - initialTouchPoint.x) > 10
            {
                self.viewVideo.fastForwardPlayer()
            }
            else if (initialTouchPoint.x - touchPoint.x) > 10
            {
                self.viewVideo.fastBackward()
            }
            else if touchPoint.y - initialTouchPoint.y > 0 && self.viewVideo.isMiniMized == false && self.viewVideo.isFullscreen == false{
                self.view.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
            }
            else if self.view.frame.origin.y != 0 && self.viewVideo.isMiniMized == true && self.viewVideo.isFullscreen == false
            {
                self.view.frame = CGRect(x: 0, y:(self.view.frame.size.height - self.viewVideo.frame.size.height) - (initialTouchPoint.y - touchPoint.y), width: self.view.frame.size.width, height: self.view.frame.size.height)
            }
        } else if sender.state == UIGestureRecognizer.State.ended || sender.state == UIGestureRecognizer.State.cancelled && (self.viewVideo.isFullscreen == false) {
            
            if touchPoint.y - initialTouchPoint.y > (UIScreen.main.bounds.height / 2) - 70 {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(x: 0, y: self.view.frame.size.height - (self.viewVideo.frame.size.height + 20), width: self.view.frame.size.width, height: self.view.frame.size.height)
                    self.viewVideo.isMiniMized = true
                    self.btnClose.alpha = 1
                    self.view.backgroundColor = UIColor.clear
                    self.scrollView.setContentOffset(CGPoint.zero, animated: true)
                })
                
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                    self.viewVideo.isMiniMized = false
                    self.btnClose.alpha = 0
                    self.view.backgroundColor = UIColor.white
                })
                
            }
            self.isAnimating = false
            //self.viewVideo.play()
        }
    }
    
    
    func totalTime(_ player: AVPlayer) {
        
    }
    
    func SAAVPlayer(didEndPlaying: AVPlayer?) {
        //Play your next video
    }
    
    func SAAVPlayer(didTap overLay: AVPlayer?) {
        self.dropdown?.isHidden = true
    }
    
    func SAAVPlayer(willExpand player: AVPlayer?) {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            self.viewVideo.isMiniMized = false
            self.btnClose.alpha = 0
            let value = UIInterfaceOrientation.landscapeLeft.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        })
    }
    
    func SAAVPlayer(didTaptoNextvideo: AVPlayer?) {
        //Replace your video with next one
        if index != self.arrVideos.count - 1
        {
            self.index += 1
            self.viewVideo.replaceVideo(videourl: self.arrVideos[index].url)
            if index == self.arrVideos.count - 1{
                self.viewVideo.makeNextButton(enable: false)
            }
            else
            {
                self.viewVideo.makeNextButton(enable: true)
                self.viewVideo.makePreviousButton(enable: true)
            }
        }
        
        //self.viewVideo.replacelocalVideo(path: "filename", videoextension: "mp4")
    }
    
    func SAAVPlayer(didTaptoPreviousvideo: AVPlayer?) {
        //Replace your video with previous one
        if index != 0
        {
            self.index -= 1
            self.viewVideo.replaceVideo(videourl: self.arrVideos[index].url)
            if index == 0{
                self.viewVideo.makePreviousButton(enable: false)
                //self.viewVideo.btnBackward?.isEnabled = false
            }
            else
            {
                //self.viewVideo.btnForward?.isEnabled = true
                //self.viewVideo.btnBackward?.isEnabled = true
                self.viewVideo.makeNextButton(enable: true)
                self.viewVideo.makePreviousButton(enable: true)
            }
        }
    }
}

extension ViewController {
    
   
    
    func showHelperCircle(){
        let center = CGPoint(x: view.bounds.width * 0.5, y: 100)
        let small = CGSize(width: 30, height: 30)
        let circle = UIView(frame: CGRect(origin: center, size: small))
        circle.layer.cornerRadius = circle.frame.width/2
        circle.backgroundColor = UIColor.white
        circle.layer.shadowOpacity = 0.8
        circle.layer.shadowOffset = CGSize()
        view.addSubview(circle)
        UIView.animate(
            withDuration: 0.5,
            delay: 0.25,
            options: [],
            animations: {
                circle.frame.origin.y += 200
                circle.layer.opacity = 0
        },
            completion: { _ in
                circle.removeFromSuperview()
        }
        )
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIApplication.shared.statusBarOrientation.isLandscape {
            self.viewVideo.isFullscreen = true
        } else {
            self.viewVideo.isFullscreen = false
        }
    }
}
extension UILabel{
    func toInt() -> Int
    {
        if let text = self.text, text.count > 0
        {
            return Int(text) ?? 0
        }
        else
        {
            return 0
        }
    }
}
