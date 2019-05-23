# SAPlugAVPlayer

Simple and featured video player with full of customisation possibility, full control over AVPlayer. Adjust as you need in terms of design and feature.
## Getting Started
Here we have a simple plug and play module that a developer can use to integrate for video playing in swift 4.2. PlugAVPlayer lets you create your own UI and add images for buttons like play and fullscreen.

## Features

* Support play local and network
* Url with extension and embed video url supported.(No control for embedded video it will be played using WkWebView)
* Only youtube embed url will be supported
* support Fullscreen
* Custom slider with buffer loader.
* FastForward and Backward support
* Change player rate.
* PlayerEventDelegate Delegate method control Next previous and replay video method control single or multiple urls.
* Save Video locally.
* Support custom player view.
* Support subtitle
* Memory management taken care.

Reference:
The slider is taken from BufferSlider Github project.

### Preview (Mine)
##Note : Make your own design. this is just a view to view

![alt text](https://github.com/teamSolutionAnalysts/sa-plug-avplayer/blob/master/SAVideoPlayer/Simulator%20Screen%20Shot%20-%20iPhone%206%20-%202019-05-23%20at%2017.37.56.png)


![alt text](https://github.com/teamSolutionAnalysts/sa-plug-avplayer/blob/master/SAVideoPlayer/Simulator%20Screen%20Shot%20-%20iPhone%206%20-%202019-05-23%20at%2017.37.59.png)

### Prerequisites

Swift 4.2

iOS 10*

Xcode 10.2
### Installing

You want to add pod 'SAPlugAVPlayer', '~> 0.1.5' similar to the following to your Podfile
```swift
target 'MyApp' do
  pod 'SAPlugAVPlayer', '~> 0.1.5'
end
```
Then run a pod install inside your terminal, or from CocoaPods.app.

Manually
If you prefer not to use any of the aforementioned dependency managers, you can integrate SA-Plug-AVPlayer into your project manually. Just copy the source file in your project directory

### Sample
```swift
	import SAPlugAVPlayer

 	@IBOutlet weak var viewController: UIView!
    	@IBOutlet weak var viewVideo: ViewVideo!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

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
        viewVideo.configure(url: url,ControllView: self.viewOverlay,loader: self.activityIndicator)
        viewVideo.saveVideoLocally = true
        viewVideo.delegate = self
        viewVideo.currentVideoID = self.videoID
        viewVideo.play()
        viewVideo.activityIndicator?.startAnimating()
    }

	//Play Video locally
	func setUpPlayerWithLocal()
    {
        viewVideo.configure(ControllView: self.viewOverlay,loader: self.activityIndicator,localPath:self.arrlocalVideo[self.index],fileextension : "mp4")
        viewVideo.delegate = self
        viewVideo.currentVideoID = self.videoID
        viewVideo.play()
        viewVideo.activityIndicator?.startAnimating()
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

## UI Guildlines

Make a view for video player and another with all controlls like,
* Use VideoControllButton subclass for PlayPause, FullScreen
* Use VideoControllLabel subclass for time label and total time
* Use BufferSlider for UISlider which lets you customize colors and other property.

## Note 
Do not forgot to write ButtonControlType :
For Buttons -> playpause, expand, forward, backward
For Labels -> LabelControllType 1 for timelabelupdate or 2 for total time
See more detail on the demo.


Directly drag IB to UIViewController, the aspect ratio for the 16:9 constraint (priority to 750, lower than the 1000 line), the code section only needs to achieve. See more detail on the demo.

```
viewVideo.configure(url: url,ControllView: self.viewController,loader: self.activityIndicator)
```

## Controlls Types 
```swift
	enum ButtonControlType :String {
        case PlayPause = "playpause"
        case Expand = "expand"
        case forward = "forward"
        case backward = "backward"
    	}
```

### Sub Class Controlls
User BufferSlider for buffer progress
VideoControllButton for PlayPause and fullscreeExit buttons
VideoControllLabel for time labels 

```swift
	VideoControllButton
	VideoControllLabel
	BufferSlider
```
## Built With

* AVKit Framework
* URLSession is used

## Authors
Solution Analyst
