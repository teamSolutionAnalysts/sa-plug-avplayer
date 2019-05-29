# SAPlugAVPlayer

Simple and featured video player with full of customisation possibility, full control over AVPlayer. Adjust as you need in terms of design and feature.
## Getting Started
Here we have a simple plug and play module that a developer can use to integrate for video playing in swift 4.2. PlugAVPlayer lets you create your own UI and add images for buttons like play and fullscreen.

## Features

* Playing local videos and url streming is supported.
* Url with extension and embed video url supported (No control for embedded video).
* Supports only Youtube embed URLs.
* Supports fullscreen.
* Slider design customization available.
* FastForward and Backward support.
* Next and Previous video callback.
* Change player rate.
* PlayerEventDelegate Delegate method control Next previous and reply, replace video with next or previous pan gesture delegate method which helps you manage your animation of video view.
* Supports Save Video locally.
* Supports custom player view.
* Memory controll.

### Preview

![alt text](https://github.com/teamSolutionAnalysts/sa-plug-avplayer/blob/master/SAVideoPlayer/Simulator%20Screen%20Shot%20-%20iPhone%206%20-%202019-05-23%20at%2017.37.56.png)

### Prerequisites

Swift 4.2

iOS 10*

Xcode 10

### Installing

You want to add pod 'SAPlugAVPlayer', '~> 0.2.6' similar to the following to your Podfile
```swift
target 'MyApp' do
  pod 'SAPlugAVPlayer', '~> 0.2.6'
end
```
Then run a pod install inside your terminal, or from CocoaPods.app.

### Carthage

Carthage is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with Homebrew using the following command:
```
$ brew update
$ brew install carthage
```
To integrate SAPlugAVPlayer into your Xcode project using Carthage, specify it in your Cartfile:

	github "iosparesh/SAPlugAVPlayer"
	
Run carthage update to build the framework and drag the built SAPlugAVPlayer.framework into your Xcode project.

### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate SAPlugAVPlayer into your project manually. Just copy the source file in your project directory

### Sample
```swift
	import SAPlugAVPlayer

 	@IBOutlet weak var videoControll: VideoController!
    	@IBOutlet weak var viewVideo: ViewVideo!

	override func viewDidLoad() {
    		super.viewDidLoad()  
 		DispatchQueue.main.async {
	        //Play video locally
        		//self.setUpPlayerWithLocal()
    		    //Play video with url
            self.setUpPlayerWithURlStreaming()
		}
	}

	//Play Video with url streaming
	func setUpPlayerWithURlStreaming()
    	 {
        //MARK : if url is emded. It will play in webview and managed automatically in webview
        viewVideo.configure(url: url,ControllView: self.videoControll)
	viewVideo.play()
	
	//other configuration
        viewVideo.saveVideoLocally = true
        viewVideo.delegate = self
        viewVideo.currentVideoID = self.videoID
    }

	//Play Video locally
	func setUpPlayerWithLocal()
    {
        viewVideo.configure(ControllView: self.videoControll,localPath:self.arrlocalVideo[self.index],fileextension : "mp4")
	viewVideo.play()
	
        viewVideo.delegate = self
        viewVideo.currentVideoID = self.videoID
  	
    }

	//With PlayerEventDelegate Method manage as you need iterate over array of urls and manage Next Previous End of video, fullscreen, totalTime and  many more.

	class ViewController : PlayerEventDelegate{

    func totalTime(_ player: AVPlayer) {
        
    }
    
    func AVPlayer(didEndPlaying: AVPlayer?) {
        //Play your next video
    }
    
    func AVPlayer(didTap overLay: AVPlayer?) {
        self.dropdown?.isHidden = true
    }
    
    func AVPlayer(willExpand player: AVPlayer?) {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            self.viewVideo.isMiniMized = false
            self.btnClose.alpha = 0

            let value = UIInterfaceOrientation.landscapeLeft.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        })
    }
    
    func AVPlayer(didTaptoNextvideo: AVPlayer?) {
        //Replace your video with next one
        if index != self.arrlocalVideo.count - 1
        {
            self.index += 1
            self.viewVideo.replacelocalVideo(path: self.arrlocalVideo[self.index], videoextension: "mp4")
            if index == self.arrVideos.count - 1{
                self.viewVideo.btnForward?.isEnabled = false
            }
            else
            {
                self.viewVideo.btnForward?.isEnabled = true
                self.viewVideo.btnBackward?.isEnabled = true
            }
        }
        
        //self.viewVideo.replacelocalVideo(path: "filename", videoextension: "mp4")
    }
    
    func AVPlayer(didTaptoPreviousvideo: AVPlayer?) {
        //Replace your video with previous one
        if index != 0
        {
            self.index -= 1
            self.viewVideo.replacelocalVideo(path: self.arrlocalVideo[self.index], videoextension: "mp4")
            if index == 0{
                self.viewVideo.btnBackward?.isEnabled = false
            }
            else
            {
                self.viewVideo.btnForward?.isEnabled = true
                self.viewVideo.btnBackward?.isEnabled = true
                
            }
        }
    }
}
```

## UI Guildlines

Directly drag IB to UIViewController, the aspect ratio for the 16:9 constraint (priority to 750, lower than the 1000 line), the code section only needs to achieve. See more detail on the demo.

## Assign VideoController class to controller view
![alt text](https://github.com/teamSolutionAnalysts/sa-plug-avplayer/blob/master/SAVideoPlayer/SetVideoController.png)

## select images for controllers like, play, pause, fullscreen, exitFullscreen, Next and Previous
![alt text](https://github.com/teamSolutionAnalysts/sa-plug-avplayer/blob/master/SAVideoPlayer/Set%20Images%20for%20controller.png)

### Fast Forward and Backward

We have given the pan gesture configuration in ViewController file please add gesture recognizer on your viewvideo and you will be able to manually access the fast forward  and backward methods.
We have kept this code on the developer side because there is another drag video view feature associated. You can take advantage of managing multiple cases.

```swift
	if (touchPoint.x - initialTouchPoint.x) > 1{
       	        self.viewVideo.fastForwardPlayer()
       	}
	else if (initialTouchPoint.x - touchPoint.x) > 10{
		self.viewVideo.fastBackward()
        }
```
### Player Rate 

```swift 
	self.viewVideo.changePlayerRate(rate: rate)
```
There is a method which lets you change the player

## Built With

* AVKit Framework
* URLSession is used

## Authors
Solution Analyst

## Reference:
The slider is used from raxcat/BufferSlider, git
