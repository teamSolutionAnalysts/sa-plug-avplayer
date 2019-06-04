//
//  ViewVideo.swift
//  SAVideoPlayer
//
//  Created by Paresh Prajapati on 13/05/19.
//  Copyright © 2019 Solutionanalysts. All rights reserved.
//
import AVFoundation
import UIKit
import WebKit


public protocol PlayerEventDelegate : class{
    func SAAVPlayer(_ player : AVPlayer?, elpsed time : String)
    func SAAVPlayer(didPause player : AVPlayer?)
    func SAAVPlayer(didPlay player : AVPlayer?)
    func SAAVPlayer(willExpand player : AVPlayer?)
    func SAAVPlayer(didTap overLay : AVPlayer?)
    func SAAVPlayer(didTaptoNextvideo : AVPlayer?)
    func SAAVPlayer(didTaptoPreviousvideo : AVPlayer?)
    func SAAVPlayer(didEndPlaying : AVPlayer?)
    func SAAVPlayer(panGesture sender : UIGestureRecognizer?)
    func SAAVPlayer(minimizevideoScreen : Bool)
    func SAAVPlayer(avplayer : AVPlayer?, didFailwith error : String?)
}
public extension PlayerEventDelegate {
    func SAAVPlayer(_ player : AVPlayer?, elpsed time : String){}
    func SAAVPlayer(didPause player : AVPlayer?){}
    func SAAVPlayer(didPlay player : AVPlayer?){}
    func SAAVPlayer(willExpand player : AVPlayer?){}
    func SAAVPlayer(didTap overLay : AVPlayer?){}
    func SAAVPlayer(didTaptoNextvideo : AVPlayer?){}
    func SAAVPlayer(didTaptoPreviousvideo : AVPlayer?){}
    func SAAVPlayer(didEndPlaying : AVPlayer?){}
    func SAAVPlayer(panGesture sender : UIGestureRecognizer?){}
    func SAAVPlayer(minimizevideoScreen : Bool){}
}

public class ViewVideo : UIView
{
    //Mark: - variable
    //Player layer is added in ViewVideo to play video
    public var playerLayer: AVPlayerLayer?
    
    public var player: AVPlayer?
    
    // This is a public variable used to set repeat video. default is false. you can set true if you want to set player to play same video again and again.
    public var isLoop: Bool = false
    
    //To save video locally you can turn this on and dont forgot to name everyvideo video when start playing.
    public var saveVideoLocally: Bool = false
    
    //This variable  will be false if controls are hidden and true when visible.
    public var isToolHidden :Bool = true
    
    //Timer is used to hide controlsa after some time.
    private var timer : Timer?
    
    //This is public activity indicator to show video loading.
    public var activityIndicator : UIActivityIndicatorView?
    
    //you can get total time of the video when started playing.
    public var totalTime : Double = 0
    
    // This is for public use if you want to assign any video to any particular id.
    public var currentVideoID = 0
    
    //This variable only be usable when you have manually set you viewvideo minimized you can manually set this varible.
    public var isMiniMized : Bool = false
    //Delegate is used to notify user about the state of video and manage videos like to manage next and previous, is in fullscreen you can take any action at that time for your UI.
    open weak var delegate : PlayerEventDelegate?
    
    //All Embeded urls will be used in webview you can change it's properties.
    public var webview: WKWebView?
    {
        didSet{
            
        }
    }
    
    //This is public variable which specifies that the video is embedded or not
    open var isEmbeddedVideo : Bool{
        return ViewVideo.checkIfUrlIsEmbedded(url: self.url?.absoluteString ?? "")
    }
    
    // You can always know which url is currently playing the video.
    public var url : URL?
    
    // Observer reference to remove on dismiss
    public var timeObserver :Any?
    
    // seekDuration specifies the fast-forward and backward jump duration you can manually set this to any
    public let seekDuration: Float64 = 5
    
    // the variable will return weather the video is playing in fullscreen or not.
    public var isFullscreen :Bool = false
    
    //Not Available for now
    public var isCell :Bool = false
    
    //MARK: - Internal variable
    var isAnimating : Bool = false
    var nextButton : UIButton!
    var previousButton : UIButton!
    
    //This is a public view which has all controls. you can access it
    public var videoControll : VideoController?
    {
        didSet{
            self.videoControll?.previousButton.addTarget(self, action: #selector(doBackwardJump), for: .touchUpInside)
            self.videoControll?.nextButton.addTarget(self, action: #selector(doForwardJump), for: .touchUpInside)
            self.videoControll?.playButton.addTarget(self, action: #selector(didPressPlayButton), for: .touchUpInside)
            self.videoControll?.fullscreenButton.addTarget(self, action: #selector(btnExpandTouched), for: .touchUpInside)
            self.videoControll?.slider.addTarget(self, action: #selector(sliderDidChangeValue), for: .valueChanged)
        }
    }
    //Get current item playing.
    public var currentItem : AVPlayerItem?{
        if let item = self.player?.currentItem
        {
            return item
        }
        return nil
    }
    
    //You have direct access to the assest from here.
    public lazy var asset: AVURLAsset = {
        
        var asset: AVURLAsset = AVURLAsset(url: self.url!)
        
        asset.resourceLoader.setDelegate(self, queue: DispatchQueue.main)
        
        return asset
    }()
    
    //MARK: - Initialization
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
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.playerLayer?.frame = self.bounds
    }
    
    func _setup()
    {
        self.addActityIndicator()
        
    }
    
    //MARK: - Configure ViewVide
    /*
     To Play Streming url:
        With url and controller view you can start playing with streaming from server.
    */
    
    /*
     To Play Local url
        Without url but with controller, localpath and extension you can play videos from local storage.
    */
    
    /*
     To Play embedded
        With url and without controller view you can play embedded urls
     */
    
    
    public func configure(url: String = "", ControllView:VideoController?, localPath  :String = "", fileextension : String = "") {
    
        //self.addActityIndicator()
        guard let videourl = URL(string: url) else{
            self.delegate?.SAAVPlayer(avplayer: self.player, didFailwith: "Url is not supported")
            return
        }
        self.url = videourl
        if let viewc = ControllView
        {
            self.videoControll = viewc
        }
        if ViewVideo.checkIfUrlIsEmbedded(url: url)
        {
            self.playEmbeddedVideo(url: url)
        }
        else if  self.isEmbeddedVideo == false {
            if videourl.pathExtension == ""
            {
                let newurl = self.formateURl(path: videourl)
                self.url = newurl
                self.configurePlayer(videoURL: newurl!)
            }
            else{
                self.configurePlayer(videoURL: videourl)
            }
            self.setUpGesture()
        }
        else if localPath != "" && fileextension != ""{
            
            self.configurePlayer(localvideoname: localPath, videoextension: fileextension)
            self.setUpGesture()
        }
        if self.isCell == false{
            self.setUpGestureRecognizer()
        }
    }
    
    private func configurePlayer(localvideoname: String, videoextension : String)
    {
        guard let path = Bundle.main.path(forResource: localvideoname, ofType: videoextension) else{
            return
        }
        let url = URL(fileURLWithPath: path)
        self.url = url
        if self.currentItem == nil{
            player = AVPlayer(url:url)
            playerLayer = AVPlayerLayer(player: player)
            player?.currentItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = true
            playerLayer?.frame = bounds
            playerLayer?.videoGravity = AVLayerVideoGravity.resize
            playerLayer?.removeFromSuperlayer()
            if let playerLayer = self.playerLayer {
                layer.addSublayer(playerLayer)
            }
        }
        else{
            self.activityIndicator?.startAnimating()
            self.removeObserverPlayerItem()
            let item = AVPlayerItem(url: url)
            player?.replaceCurrentItem(with: item)
            self.addObserverPlayerItem()
            self.player?.play()
        }
        setPlayerObserver()
    }
    
    private func configurePlayer(videoURL:URL)
    {
        let mimeType = "video/mp4; codecs=\"avc1.42E01E, mp4a.40.2\""
        let asset = AVURLAsset(url: videoURL, options:["AVURLAssetOutOfBandMIMETypeKey": mimeType])
        let item = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem:item)
        playerLayer = AVPlayerLayer(player: player)
        player?.currentItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        playerLayer?.frame = bounds
        playerLayer?.videoGravity = AVLayerVideoGravity.resize
        playerLayer?.removeFromSuperlayer()
        
        if let playerLayer = self.playerLayer {
            DispatchQueue.main.async {
                self.layer.addSublayer(playerLayer)
            }
        }
        self.setPlayerObserver()
        if self.isCell
        {
            self.player = nil
            self.isUserInteractionEnabled = false
        }
    }
    
   
    func addActityIndicator()
    {
        
        self.activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        self.activityIndicator?.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.8)
        self.activityIndicator?.translatesAutoresizingMaskIntoConstraints = false
        self.activityIndicator?.hidesWhenStopped = true
        self.activityIndicator?.isHidden = false
        self.activityIndicator?.startAnimating()
        self.addSubview(self.activityIndicator!)
        self.addConstraintCenter()
    }
    
    public func makeNextButton(enable: Bool)
    {
        self.videoControll?.nextButton.isEnabled = enable
    }
    
    public func makePreviousButton(enable: Bool)
    {
        self.videoControll?.previousButton.isEnabled = enable
    }
    
    //MARK: - Gesture Recognizer
    //Gesture recognizer to trigger fastforward and backward as well as to notify user about the gesture.
    func setUpGestureRecognizer()
    {
        let swipe = UIPanGestureRecognizer(target: self, action: #selector(handleGesture))
        swipe.maximumNumberOfTouches = 1
        if self.isEmbeddedVideo
        {
            if let webView = self.webview
            {
                webView.addGestureRecognizer(swipe)
            }
        }
        else{
            self.addGestureRecognizer(swipe)
        }
        let swipeoverlay = UIPanGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeoverlay.maximumNumberOfTouches = 1
        self.videoControll?.gestureView.addGestureRecognizer(swipeoverlay)
    }
    
    
    @objc func handleGesture(_ sender: UIPanGestureRecognizer) {
        if self.videoControll?.slider.isTracking ?? false
        {
            return
        }
        self.delegate?.SAAVPlayer(panGesture: sender)
    }
    
    //MARK: - Player's value observer
    private func setUpGesture()
    {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeOrientation), name: UIDevice.orientationDidChangeNotification, object: nil)
        self.addObserverPlayerItem()
        let gestureControll = UITapGestureRecognizer(target: self, action: #selector(didTouchOverlay))
        gestureControll.numberOfTapsRequired = 1
        self.addGestureRecognizer(gestureControll)
        let gestureControll1 = UITapGestureRecognizer(target: self, action: #selector(hideOverlay))
        gestureControll1.numberOfTapsRequired = 1
        self.videoControll?.addGestureRecognizer(gestureControll1)
    }
    
    private func addObserverPlayerItem()
    {
        if let playerItem = self.player?.currentItem{
            playerItem.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
            playerItem.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
            playerItem.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
            playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: [.new], context: nil)
            self.player?.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.status), options: [.new, .initial], context: nil)
            self.player?.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.new, .initial], context: nil)
        }
    }
    
    private func removeObserverPlayerItem()
    {
        if let playerItem = self.player?.currentItem{
            playerItem.removeObserver(self, forKeyPath: "playbackBufferEmpty")
            playerItem.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
            playerItem.removeObserver(self, forKeyPath: "playbackBufferFull")
            playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
            player?.removeObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.status))
            player?.removeObserver(self, forKeyPath: #keyPath(AVPlayer.status))
        }
    }
    
    private func setPlayerObserver()
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reachTheEndOfTheVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
        
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 600), queue: DispatchQueue.main, using: { [weak self] (time) in
            guard let strongSelf = self else{
                return
            }
            
            if strongSelf.player!.currentItem?.status == .readyToPlay {
                
                let currentTime = CMTimeGetSeconds(strongSelf.player!.currentTime())
                let secs = Int(currentTime)
                
                if secs == 0{
                    self?.activityIndicator?.stopAnimating()
                }
                strongSelf.videoControll?.labelTime.text = NSString(format: "%02d:%02d", secs/60, secs%60) as String//"\(secs/60):\(secs%60)"
                //                strongSelf.delegate?.didUpdateTimer(strongSelf.player!, elpsed: timetext)
                let currentItem = strongSelf.player?.currentItem
                let currTime:Double = currentItem?.currentTime().seconds ?? 0
                
                let duration = currentItem?.asset.duration
                DispatchQueue.main.async {
                    strongSelf.videoControll?.slider.setValue(Float(currTime / duration!.seconds) , animated: true)
                }
                
            }
            else if strongSelf.player!.currentItem?.status ==  .failed{
                //  print("Error occured playing video")
            }
            else if strongSelf.player!.currentItem?.status ==  .unknown{
                // print("unknown")
            }
        })
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is AVPlayerItem {
            switch keyPath {
                
            case "loadedTimeRanges":
                
                let duration = self.currentItem?.totalBuffer() ?? 0
                let totalduration = currentItem?.asset.duration
                self.videoControll?.slider.bufferEndValue = totalduration?.seconds ?? 0
                self.videoControll?.slider.bufferStartValue = (duration) / (totalduration?.seconds ?? 1)
                //print((duration) / (totalduration?.seconds ?? 1))
                
            case "playbackBufferEmpty":
                // Show loader
                self.activityIndicator?.startAnimating()
                
            case "playbackLikelyToKeepUp":
                // Hide loader
                self.activityIndicator?.stopAnimating()
                
            case "playbackBufferFull":
                // Hide loader
                self.activityIndicator?.stopAnimating()
            case #keyPath(AVPlayer.currentItem.status):
                
                let newStatus: AVPlayerItem.Status
                if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                    newStatus = AVPlayerItem.Status(rawValue: newStatusAsNumber.intValue)!
                } else {
                    newStatus = .unknown
                }
                if newStatus == .failed {
                    NSLog("SA Detected Error: \(String(describing: self.player?.currentItem?.error?.localizedDescription)), error: \(String(describing: self.player?.currentItem?.error))")
                }
            case #keyPath(AVPlayer.status):break
               // print()
            case .none:
                self.activityIndicator?.stopAnimating()
            case .some(_):
                self.activityIndicator?.stopAnimating()
            }
        }
    }
    
    //
    private func disableScrollView(_ view: UIView) {
        (view as? UIScrollView)?.isScrollEnabled = false
        view.subviews.forEach { disableScrollView($0) }
    }
    
    private func saveVideo(notification : Notification)
    {
        if notification.object as? AVPlayerItem  == player?.currentItem {
            
            let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
            
            let filename = "filename.mp4"
            
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
            
            let outputURL = documentsDirectory.appendingPathComponent(filename)
            
            exporter?.outputURL = outputURL
            print("Video Saved At : " + outputURL.absoluteString)
            exporter?.outputFileType = AVFileType.mp4
            
            exporter?.exportAsynchronously(completionHandler: {
                
                // print(exporter?.status.rawValue)
                //  print(exporter?.error)
            })
        }
    }
    
    private func addConstraintCenter()
    {
        
        let leadConstraint = NSLayoutConstraint(item: self.activityIndicator!,attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        
        let trailConstraint = NSLayoutConstraint(item: self.activityIndicator!, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        
        let top = NSLayoutConstraint(item: self.activityIndicator!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        
        let bottom = NSLayoutConstraint(item: self.activityIndicator!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([leadConstraint, trailConstraint,top,(bottom)])
    }

    //MARK: - Check Embedded Url's
    public class func checkIfUrlIsEmbedded(url:String) ->Bool
    {
        let key = "embed"
        var isEmbed = false
        let components = url.components(separatedBy: "/")
        if components.count > 0
        {
            isEmbed = components.contains { (component) -> Bool in
                return component.contains(key)
            }
        }
        if isEmbed == false{
            if let urlp = URL(string: url), urlp.pathExtension == ""
            {
//                return true
            }
        }
       
        return isEmbed
    }
    
    public func availableDuration() -> CMTime
    {
        if let range = self.player?.currentItem?.loadedTimeRanges.first {
            return CMTimeRangeGetEnd(range.timeRangeValue)
        }
        return .zero
    }
    
    @objc func didPressPlayButton()
    {
        if self.isEmbeddedVideo{
            return
        }
        if self.isPlaying
        {
            self.timer?.invalidate()
            self.timer = nil
            self.pause()
            self.showOverlay()
        }
        else{
            self.play()
            self.hideOverlay()
        }
    }
    
    @objc func hideOverlay()
    {
        if self.isEmbeddedVideo{
            return
        }
        DispatchQueue.main.async {
            self.videoControll?.isHidden = true
            self.isToolHidden = true
        }
    }
    
    func showOverlay()
    {
        if self.isEmbeddedVideo{
            return
        }
        DispatchQueue.main.async {
            self.videoControll?.isHidden = false
            self.isToolHidden = false
        }
        
    }
    
    @objc func didTouchOverlay()
    {
        if self.isEmbeddedVideo{
            return
        }
        self.delegate?.SAAVPlayer(didTap: self.player)
        if self.isToolHidden
        {
            DispatchQueue.main.async {
                self.showOverlay()
                self.timer = nil
                self.updateFocusVideo()
               
            }
        }
        else{
            self.hideOverlay()
        }
    }
    
    @objc func btnExpandTouched(_ sender: Any) {
        if self.isEmbeddedVideo{
            return
        }
        if self.isMiniMized
        {
            self.delegate?.SAAVPlayer(willExpand: self.player)
            return
        }
        if UIDeviceOrientation.portrait == UIDevice.current.orientation
        {
            let value = UIInterfaceOrientation.landscapeLeft.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            self.videoControll?.fullscreenButton.setImage(videoControll?.exitfullscreenImage, for: .normal)
//            self.btnFullScreen?.setImage(#imageLiteral(resourceName: "Colaps"), for: .normal)
        }
        else{
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            self.videoControll?.fullscreenButton.setImage(videoControll?.fullscreenImage, for: .normal)
//            self.btnFullScreen?.setImage(#imageLiteral(resourceName: "fullscreen"), for: .normal)
        }
    }
    
    @objc func didChangeOrientation(gesture : Notification)
    {
        if self.isEmbeddedVideo{
            return
        }
        if UIDevice.current.orientation == .portrait
        {
            self.videoControll?.fullscreenButton.setImage(videoControll?.fullscreenImage, for: .normal)
//            self.btnFullScreen?.setImage(#imageLiteral(resourceName: "fullscreen"), for: .normal)
        }
        else{
            self.videoControll?.fullscreenButton.setImage(videoControll?.exitfullscreenImage, for: .normal)
//            self.btnFullScreen?.setImage(#imageLiteral(resourceName: "Colaps"), for: .normal)
            if self.isMiniMized
            {
                self.delegate?.SAAVPlayer(willExpand: self.player)
            }
        }
    }
    
    @objc func sliderDidChangeValue(_ sender: Any) {
        
        if self.isEmbeddedVideo{
            return
        }
        self.timer?.invalidate()
        self.timer = nil
        guard let value = self.videoControll?.slider.value else { return }
        let durationToSeek = Float(self.totalTime) * value
        if let player = self.player{
            player.seek(to: CMTimeMakeWithSeconds(Float64(durationToSeek),preferredTimescale: player.currentItem!.duration.timescale)) { [weak self](state) in
                guard let strongSelf = self else{return}
                strongSelf.updateFocusVideo()
            }
        }
    }
    
    private func updateFocusVideo() {
        if self.isEmbeddedVideo{
            return
        }
        if timer == nil{
            self.timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: {[weak self] (time) in
                guard let strongSelf = self else{return}
                strongSelf.AdjustToolBar()
            })
        }
        else{
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func AdjustToolBar()
    {
        if self.isEmbeddedVideo{
            return
        }
        if self.isToolHidden == false
        {
            self.hideOverlay()
        }
    }
    
    //MARK: - Public methods to play video.
    public func play() {
        
        guard self.player != nil else {
            return
        }
        if self.isEmbeddedVideo{
            return
        }
        if player?.timeControlStatus != AVPlayer.TimeControlStatus.playing {
            player?.play()
            //            self.delegate?.totalTime(self.player!)
            let currentItem = player?.currentItem
            let duration = currentItem?.asset.duration
            self.videoControll?.slider.maximumValue = 1
            self.videoControll?.slider.minimumValue = 0
            let sec = CMTimeGetSeconds(duration!)
            self.totalTime = duration?.seconds ?? 0
            self.setHoursMinutesSecondsFrom(seconds: sec)
            self.videoControll?.playButton?.setImage(self.videoControll?.pauseImage, for: .normal)
            self.delegate?.SAAVPlayer(didPlay: self.player!)
            self.hideOverlay()
        }
    }
    
    private func playEmbeddedVideo(url: String)
    {
        self.webview = WKWebView(frame: self.bounds)
        self.webview?.navigationDelegate = self
        self.disableScrollView(self.webview!)
        self.addSubview(self.webview!)
        if let web = self.webview{
            web.translatesAutoresizingMaskIntoConstraints = false
            self.addConstraint(NSLayoutConstraint(item: web, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: web, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: web, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: web, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
            
        }
        
        if let videoURL = URL(string: url) {
            self.url = videoURL
            self.webview?.load(URLRequest(url: videoURL))
        }
        self.hideOverlay()
    }
    
    //MARK: - Public methods to change video
    public func replaceVideo(videourl:String)
    {
        
        if let fileurl = URL(string: videourl)
        {
            self.url = fileurl
            if ViewVideo.checkIfUrlIsEmbedded(url: videourl)
            {
                self.webview?.load(URLRequest(url: fileurl))
                self.hideOverlay()
            }
            else
            {
                self.removeWebViewUIandInstances()
                self.activityIndicator?.startAnimating()
                
                self.removeObserverPlayerItem()
                let item = AVPlayerItem(url: fileurl)
                player?.replaceCurrentItem(with: item)
                self.addObserverPlayerItem()
                self.player?.play()
                
            }
        }
    }
    /*
        Replace video (except embedded) with new local video.
        you can specify path to the local directory and extension compulsory.
     */
    public func replacelocalVideo(path:String,videoextension : String)
    {
        
        self.configurePlayer(localvideoname: path, videoextension: videoextension)
    }
    
    func removeWebViewUIandInstances()
    {
        self.webview?.removeFromSuperview()
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    //MARK: - public methods to change player rate
    /*
        Specify the rate in (Float) from 0 to 2
     */
    public func changePlayerRate(rate : Float) {
        if self.isEmbeddedVideo{
            
            return
        }
        guard let duration  = self.player?.currentItem?.duration else{
            return
        }
        self.player?.rate = rate
        let timeRange = CMTimeRangeMake(start: CMTime.zero, duration: CMTime(seconds: duration.seconds, preferredTimescale: 1))
        let composition = AVMutableComposition()
        do{
            try composition.insertTimeRange(timeRange,
                                            of: (self.player?.currentItem!.asset)!,
                                            at: CMTime.zero)
            composition.scaleTimeRange(timeRange, toDuration: CMTimeMultiplyByFloat64((self.player?.currentItem?.asset.duration)!, multiplier: Float64(1.0 / rate)))
        }
        catch let error{
            print(error.localizedDescription)
        }
        let playerItem = AVPlayerItem(asset: composition)
        let player = AVPlayer(playerItem: playerItem)
        player.play()
        
    }
    
    @objc func doForwardJump(_ sender: UIButton, event: UIEvent) {
        if self.isEmbeddedVideo{
            return
        }
        self.delegate?.SAAVPlayer(didTaptoNextvideo: self.player)
    }
    
    //MARK: - Fast-Forward
    /*
        To fast forward you video you need just need to call this method.
     */
    public func fastForwardPlayer()
    {
        if self.isEmbeddedVideo{
            return
        }
        guard let duration  = player?.currentItem?.duration else{
            return
        }
        let playerCurrentTime = CMTimeGetSeconds((player?.currentTime())!)
        let newTime = playerCurrentTime + seekDuration
        
        if newTime < CMTimeGetSeconds(duration) {
            
            let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
            player?.seek(to: time2, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
//            player?.seek(to: time2)
            
        }
    }
    
     //MARK: - Move video Backward
    /*
     
     */
    public func fastBackward()
    {
        if self.isEmbeddedVideo{
            return
        }
        let playerCurrentTime = CMTimeGetSeconds((player?.currentTime())!)
        var newTime = playerCurrentTime - seekDuration
        
        if newTime < 0 {
            newTime = 0
        }
        let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        player?.seek(to: time2, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
      
//        player?.seek(to: time2)
    }
    
    @objc func doBackwardJump(_ sender: UIButton, event: UIEvent) {
        if self.isEmbeddedVideo{
            return
        }
        self.delegate?.SAAVPlayer(didTaptoPreviousvideo: self.player)
    }
    
    public func setHoursMinutesSecondsFrom(seconds: Double){
        let secs = Int(seconds)
        self.videoControll?.totalTime?.text = NSString(format: "%02d:%02d", secs/60, secs%60) as String
    }
    
    /*
        Is video playing or not
     */
    public var isPlaying : Bool{
        if self.isEmbeddedVideo{
            return false
        }
        return player?.timeControlStatus == AVPlayer.TimeControlStatus.playing
    }
    
    //MARK: - Pause video
    public func pause() {
        if self.isEmbeddedVideo{
            return
        }
        player?.pause()
        self.videoControll?.playButton?.setImage(videoControll?.playImage, for: .normal)
        self.delegate?.SAAVPlayer(didPause: self.player!)
        self.timer?.invalidate()
        self.timer = nil
        self.isToolHidden = false
    }
     //MARK: - Stop video
    public func stop() {
        if self.isEmbeddedVideo{
            return
        }
        player?.pause()
        player?.seek(to: CMTime.zero)
        
    }
    
    public func prepareforreuse()
    {
        self.playerLayer?.removeFromSuperlayer()
        self.playerLayer = nil
        self.removeObserverPlayerItem()
    }
    
    @objc func reachTheEndOfTheVideo(_ notification: Notification) {
        self.delegate?.SAAVPlayer(didEndPlaying: self.player)
        if self.isEmbeddedVideo{
            return
        }
        if self.saveVideoLocally{
            self.saveVideo(notification: notification)
        }
        if isLoop {
            player?.pause()
            player?.seek(to: CMTime.zero)
            player?.play()
        }
        else
        {
            player?.seek(to: CMTime.zero)
            self.videoControll?.playButton?.setImage(videoControll?.playImage, for: .normal)
            self.stop()
        }
    }
    
     //MARK: - Sub-title
    //To set sub title in video you need another file with .vtt extension and you need to specify the path for that file
    public func setupSubtitle(localpath : String, fileextension : String)
    {
        let url = Bundle.main.url(forResource: localpath, withExtension: fileextension)
        let localVideoAsset = AVAsset(url: url!)
        //Create AVMutableComposition
        let videoPlusSubtitles = AVMutableComposition()
        
        //Adds video track
        let videoTrack = videoPlusSubtitles.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        try? videoTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: localVideoAsset.duration),
                                         of: localVideoAsset.tracks(withMediaType: .video)[0],
                                         at: CMTime.zero)
        
        //Adds subtitle track
        let subtitleAsset = AVURLAsset(url: Bundle.main.url(forResource: localpath, withExtension: ".\(fileextension).vtt")!)
        
        let subtitleTrack = videoPlusSubtitles.addMutableTrack(withMediaType: .text, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        try? subtitleTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: localVideoAsset.duration),
                                            of: subtitleAsset.tracks(withMediaType: .text)[0],
                                            at: CMTime.zero)
    }
    
    deinit {
        //print("Player did deinitialized")
        // self.player?.removeTimeObserver(self)
        if let token = timeObserver {
            player?.removeTimeObserver(token)
            timeObserver = nil
        }
        self.removeObserverPlayerItem()
    }
    
}

//MARK: - WKNavigationDelegate and AVAssetResourceLoaderDelegate
extension ViewVideo : WKNavigationDelegate, AVAssetResourceLoaderDelegate
{
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIndicator?.stopAnimating()
        webView.frame.size.height = 1
        webView.frame.size = webView.scrollView.contentSize
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.activityIndicator?.stopAnimating()
    }
    
    
    func getBundle() -> Bundle?
    {
        let bundle = Bundle(for: self.classForCoder)
        if let buld = Bundle(identifier: bundle.bundleIdentifier ?? "")
        {
            return buld
        }
        return bundle
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
    
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        return true
    }

    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForRenewalOfRequestedResource renewalRequest: AVAssetResourceRenewalRequest) -> Bool {
        return true
    }
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        
    }
    
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForResponseTo authenticationChallenge: URLAuthenticationChallenge) -> Bool {
        return true
    }
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.previousFailureCount > 0 {
            completionHandler(Foundation.URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
        } else if let serverTrust = challenge.protectionSpace.serverTrust {
            completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: serverTrust))
        } else {
            print("unknown state. error: \(challenge.error)")
            // do something w/ completionHandler here
        }
    }
    
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel authenticationChallenge: URLAuthenticationChallenge) {
        
    }
    
    
}

