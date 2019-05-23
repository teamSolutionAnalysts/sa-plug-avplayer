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
    func didUpdateTimer(_ player : AVPlayer, elpsed time : String)
    func totalTime(_ player : AVPlayer)
    func AVPlayer(didPause player : AVPlayer)
    func AVPlayer(didPlay player : AVPlayer)
    func AVPlayer(willExpand player : AVPlayer?)
    func AVPlayer(didTap overLay : AVPlayer?)
    func AVPlayer(didTaptoNextvideo : AVPlayer?)
    func AVPlayer(didTaptoPreviousvideo : AVPlayer?)
    func AVPlayer(didEndPlaying : AVPlayer?)
}
public extension PlayerEventDelegate {
    func didUpdateTimer(_ player : AVPlayer, elpsed time : String){}
    func AVPlayer(didPause player : AVPlayer){}
    func AVPlayer(didPlay player : AVPlayer){}
}

public class ViewVideo : UIView
{
    public var playerLayer: AVPlayerLayer?
    public var player: AVPlayer?
    public var isLoop: Bool = false
    public var saveVideoLocally: Bool = false
    public var isToolHidden :Bool = true
    private var timer : Timer?
    public var slider : BufferSlider?
    public var activityIndicator : UIActivityIndicatorView?
    public var totalTime : Double = 0
    public var lblStartTime : VideoControllLabel?
    public var lblTotalTime : VideoControllLabel?
    public var currentVideoID = 0
    public var isMiniMized : Bool = false
    open weak var delegate : PlayerEventDelegate?
    public var btnBackward : VideoControllButton?
    public var btnForward : VideoControllButton?
    public var btnPlayPause : VideoControllButton?
    public var btnFullScreen : VideoControllButton?
    public var webview: WKWebView?
    public var OverlayWindow: UIView?
    open var isEmbeddedVideo = false
    public var url : URL?
    public var timeObserver :Any?
    public let seekDuration: Float64 = 5
    public var isFullscreen :Bool = false
    public weak var controllerView:UIView?
    {
        didSet{
            if self.isEmbeddedVideo{
                return
            }
            for vw  in (self.controllerView?.subviews ?? [])
            {
                if let btn = vw as? VideoControllButton, btn.controllType == .backward
                {
                    self.btnBackward = btn
                    // self.btnBackward?.addTarget(self, action: #selector(doBackwardJump), for: .touchDownRepeat)
                    self.btnBackward?.addTarget(self, action: #selector(doBackwardJump), for: .touchUpInside)
                    
                }
                else if let btn = vw as? VideoControllButton, btn.controllType == .forward
                {
                    self.btnForward = btn
                    // self.btnForward?.addTarget(self, action: #selector(doForwardJump), for: .touchDownRepeat)
                    self.btnForward?.addTarget(self, action: #selector(doForwardJump), for: .touchUpInside)
                }
                else if let playbtn = vw as? VideoControllButton, playbtn.controllType == .PlayPause
                {
                    self.btnPlayPause = playbtn
                    self.btnPlayPause?.addTarget(self, action: #selector(didPressPlayButton), for: .touchUpInside)
                }
                else if let fullscreenbtn = vw as? VideoControllButton, fullscreenbtn.controllType == .Expand
                {
                    self.btnFullScreen = fullscreenbtn
                    self.btnFullScreen?.addTarget(self, action: #selector(btnExpandTouched), for: .touchUpInside)
                }
                else if let slide = vw as? BufferSlider
                {
                    self.slider = slide
                    self.slider?.addTarget(self, action: #selector(sliderDidChangeValue), for: .valueChanged)
                    let currentItem = player?.currentItem
                    let duration = currentItem?.asset.duration
                    self.totalTime = duration?.seconds ?? 0
                }
                else if let timeLabel = vw as? VideoControllLabel, timeLabel.controllType == .TimeLabelStart
                {
                    self.lblStartTime = timeLabel
                }
                else if let timeLabel = vw as? VideoControllLabel, timeLabel.controllType == .TimeLabelTotal
                {
                    self.lblTotalTime = timeLabel
                }
            }
        }
    }
    
    public var currentItem : AVPlayerItem?{
        if let item = self.player?.currentItem
        {
            return item
        }
        return nil
    }
    
    public lazy var asset: AVURLAsset = {
        
        var asset: AVURLAsset = AVURLAsset(url: self.url!)
        
        asset.resourceLoader.setDelegate(self, queue: DispatchQueue.main)
        
        return asset
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    public func configure(url: String = "", ControllView:UIView?, loader : UIActivityIndicatorView?, localPath  :String = "", fileextension : String = "") {
        if let loaderview = loader{
            self.activityIndicator = loaderview
            self.activityIndicator?.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
            self.activityIndicator?.hidesWhenStopped = true
            
        }
        if let viewc = ControllView
        {
            self.controllerView = viewc
            self.controllerView?.backgroundColor = UIColor.clear
        }
        if ViewVideo.checkIfUrlIsEmbedded(url: url)
        {
            self.playEmbeddedVideo(url: url)
            return
        }
        
        if let videoURL = URL(string: url), self.isEmbeddedVideo == false {
            self.url = videoURL
            self.configurePlayer(videoURL: videoURL)
        }
        else if localPath != "" && fileextension != ""{
            self.configurePlayer(localvideoname: localPath, videoextension: fileextension)
        }
        self.setUpGesture()
    }
    
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
        self.controllerView?.addGestureRecognizer(gestureControll1)
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
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is AVPlayerItem {
            switch keyPath {
                
            case "loadedTimeRanges":
                
                let duration = self.currentItem?.totalBuffer() ?? 0
                let totalduration = currentItem?.asset.duration
                self.slider?.bufferEndValue = totalduration?.seconds ?? 0
                self.slider?.bufferStartValue = (duration) / (totalduration?.seconds ?? 1)
                print((duration) / (totalduration?.seconds ?? 1))
                
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
            case #keyPath(AVPlayer.status):
                print()
            case .none:
                self.activityIndicator?.stopAnimating()
            case .some(_):
                self.activityIndicator?.stopAnimating()
            }
        }
    }
    
    
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
                return true
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
        player = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: player)
        player?.currentItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        playerLayer?.frame = bounds
        playerLayer?.videoGravity = AVLayerVideoGravity.resize
        playerLayer?.removeFromSuperlayer()
        if let playerLayer = self.playerLayer {
            layer.addSublayer(playerLayer)
        }
        self.setPlayerObserver()
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
                if secs == 0
                {
                    self?.activityIndicator?.stopAnimating()
                }
                strongSelf.lblStartTime?.text = NSString(format: "%02d:%02d", secs/60, secs%60) as String//"\(secs/60):\(secs%60)"
                //                strongSelf.delegate?.didUpdateTimer(strongSelf.player!, elpsed: timetext)
                let currentItem = strongSelf.player?.currentItem
                let currTime:Double = currentItem?.currentTime().seconds ?? 0
                
                let duration = currentItem?.asset.duration
                
                strongSelf.slider?.setValue(Float(currTime / duration!.seconds) , animated: true)
            }
            else if strongSelf.player!.currentItem?.status ==  .failed{
                print("Error occured playing video")
            }
            else if strongSelf.player!.currentItem?.status ==  .unknown{
                print("unknown")
            }
        })
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
            self.isToolHidden = false
        }
        else{
            self.play()
            self.controllerView?.isHidden = true
            self.isToolHidden = true
        }
    }
    
    @objc func hideOverlay()
    {
        if self.isEmbeddedVideo{
            return
        }
        self.controllerView?.isHidden = true
        self.isToolHidden = true
    }
    
    @objc func didTouchOverlay()
    {
        if self.isEmbeddedVideo{
            return
        }
        self.delegate?.AVPlayer(didTap: self.player)
        if self.isToolHidden
        {
            DispatchQueue.main.async {
                self.controllerView?.isHidden = false
                self.timer = nil
                self.updateFocusVideo()
                self.isToolHidden = false
            }
        }
        else{
            self.controllerView?.isHidden = true
            self.isToolHidden = true
        }
    }
    
    @objc func btnExpandTouched(_ sender: Any) {
        if self.isEmbeddedVideo{
            return
        }
        if self.isMiniMized
        {
            self.delegate?.AVPlayer(willExpand: self.player)
            return
        }
        if UIDeviceOrientation.portrait == UIDevice.current.orientation
        {
            let value = UIInterfaceOrientation.landscapeLeft.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            self.btnFullScreen?.setImage(#imageLiteral(resourceName: "Colaps"), for: .normal)
        }
        else{
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            self.btnFullScreen?.setImage(#imageLiteral(resourceName: "fullscreen"), for: .normal)
        }
    }
    
    @objc func didChangeOrientation(gesture : Notification)
    {
        if self.isEmbeddedVideo{
            return
        }
        if UIDevice.current.orientation == .portrait
        {
            self.btnFullScreen?.setImage(#imageLiteral(resourceName: "fullscreen"), for: .normal)
        }
        else{
            self.btnFullScreen?.setImage(#imageLiteral(resourceName: "Colaps"), for: .normal)
            if self.isMiniMized
            {
                self.delegate?.AVPlayer(willExpand: self.player)
            }
        }
    }
    
    @objc func sliderDidChangeValue(_ sender: Any) {
        if self.isEmbeddedVideo{
            return
        }
        self.timer?.invalidate()
        self.timer = nil
        guard let value = self.slider?.value else { return }
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
            self.controllerView?.isHidden = true
            self.isToolHidden = true
        }
    }
    
    public func play() {
        if self.isEmbeddedVideo{
            return
        }
        if player?.timeControlStatus != AVPlayer.TimeControlStatus.playing {
            player?.play()
            //            self.delegate?.totalTime(self.player!)
            let currentItem = player?.currentItem
            let duration = currentItem?.asset.duration
            self.slider?.maximumValue = 1
            self.slider?.minimumValue = 0
            let sec = CMTimeGetSeconds(duration!)
            self.totalTime = duration?.seconds ?? 0
            self.setHoursMinutesSecondsFrom(seconds: sec)
            self.btnPlayPause?.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.delegate?.AVPlayer(didPlay: self.player!)
            self.controllerView?.isHidden = true
            self.isToolHidden = true
        }
    }
    
    private func playEmbeddedVideo(url: String)
    {
        self.isEmbeddedVideo = true
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
        self.controllerView?.isHidden = true
    }
    
    public func replaceVideo(videourl:String)
    {
        if let fileurl = URL(string: videourl)
        {
            self.url = fileurl
            if ViewVideo.checkIfUrlIsEmbedded(url: videourl)
            {
                self.webview?.load(URLRequest(url: fileurl))
                self.controllerView?.isHidden = true
            }
            else
            {
                self.activityIndicator?.startAnimating()
                self.removeObserverPlayerItem()
                let item = AVPlayerItem(url: fileurl)
                player?.replaceCurrentItem(with: item)
                self.addObserverPlayerItem()
                self.player?.play()
            }
        }
    }
    
    public func replacelocalVideo(path:String,videoextension : String)
    {
        
        self.configurePlayer(localvideoname: path, videoextension: videoextension)
    }
    
    public func changePlayerRate(rate : Float) {
        if self.isEmbeddedVideo{
            return
        }
        guard let duration  = player?.currentItem?.duration else{
            return
        }
        self.player?.rate = rate
        let timeRange = CMTimeRangeMake(start: CMTime.zero, duration: CMTime(seconds: duration.seconds, preferredTimescale: 1))
        let composition = AVMutableComposition()
        do{
            try composition.insertTimeRange(timeRange,
                                            of: (player?.currentItem!.asset)!,
                                            at: CMTime.zero)
            composition.scaleTimeRange(timeRange, toDuration: CMTimeMultiplyByFloat64((player?.currentItem?.asset.duration)!, multiplier: Float64(1.0 / rate)))
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
        self.delegate?.AVPlayer(didTaptoNextvideo: self.player)
    }
    
    public func fastForwardPlayer()
    {
        guard let duration  = player?.currentItem?.duration else{
            return
        }
        let playerCurrentTime = CMTimeGetSeconds((player?.currentTime())!)
        let newTime = playerCurrentTime + seekDuration
        
        if newTime < CMTimeGetSeconds(duration) {
            
            let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
            player?.seek(to: time2)
        }
    }
    
    public func fastBackward()
    {
        let playerCurrentTime = CMTimeGetSeconds((player?.currentTime())!)
        var newTime = playerCurrentTime - seekDuration
        
        if newTime < 0 {
            newTime = 0
        }
        let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        player?.seek(to: time2)
    }
    
    @objc func doBackwardJump(_ sender: UIButton, event: UIEvent) {
        if self.isEmbeddedVideo{
            return
        }
        self.delegate?.AVPlayer(didTaptoPreviousvideo: self.player)
    }
    
    public func setHoursMinutesSecondsFrom(seconds: Double){
        let secs = Int(seconds)
        self.lblTotalTime?.text = NSString(format: "%02d:%02d", secs/60, secs%60) as String
    }
    
    public var isPlaying : Bool{
        if self.isEmbeddedVideo{
            return false
        }
        return player?.timeControlStatus == AVPlayer.TimeControlStatus.playing
    }
    
    public func pause() {
        if self.isEmbeddedVideo{
            return
        }
        player?.pause()
        self.btnPlayPause?.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        self.delegate?.AVPlayer(didPause: self.player!)
        self.timer?.invalidate()
        self.timer = nil
        self.isToolHidden = false
    }
    
    public func stop() {
        if self.isEmbeddedVideo{
            return
        }
        player?.pause()
        player?.seek(to: CMTime.zero)
        
    }
    
    @objc func reachTheEndOfTheVideo(_ notification: Notification) {
        self.delegate?.AVPlayer(didEndPlaying: self.player)
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
            self.btnPlayPause?.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.stop()
        }
    }
    
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
        print("Player did deinitialized")
        //        self.player?.removeTimeObserver(self)
        if let token = timeObserver {
            player?.removeTimeObserver(token)
            timeObserver = nil
        }
        self.removeObserverPlayerItem()
    }
}

extension ViewVideo : WKNavigationDelegate, AVAssetResourceLoaderDelegate
{
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIndicator?.stopAnimating()
        webView.frame.size.height = 1
        webView.frame.size = webView.scrollView.contentSize
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.activityIndicator?.stopAnimating()
    }
    
    
}

