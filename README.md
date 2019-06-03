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

## Installing

You want to add pod 'SAPlugAVPlayer', '~> 0.2.6' similar to the following to your Podfile
```swift
target 'MyApp' do
  pod 'SAPlugAVPlayer', '~> 0.2.6'
end
```
Then run a pod install inside your terminal, or from CocoaPods.app.

## Carthage

Carthage is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with Homebrew using the following command:
```
$ brew update
$ brew install carthage
```
To integrate SAPlugAVPlayer into your Xcode project using Carthage, specify it in your Cartfile:

	github "teamSolutionAnalysts/sa-plug-avplayer" == 0.2.9
	
Run carthage update to build the framework and drag the built SAPlugAVPlayer.framework into your Xcode project.

## Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate SAPlugAVPlayer into your project manually. Just copy the source folder in your project directory from https://github.com/teamSolutionAnalysts/sa-plug-avplayer/tree/master/SAVideoPlayer/Source

## Steps to add player
### Assign ViewVideo class

![alt text](https://github.com/teamSolutionAnalysts/sa-plug-avplayer/blob/master/SAVideoPlayer/AssignViewVideo.png)

### Note for embed urls :
If you are planing to play only youtube embedded urls. Do not take VideoController view. You can play embedded url with ViewVideo only.

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    setUpPlayerWithURlStreaming()
}

func setUpPlayerWithURlStreaming()
{
    self.viewVideo.configure(url: self.url, ControllView: nil)
    self.viewVideo.delegate = self
 }
```

### Assign VideoController class to controller view

![alt text](https://github.com/teamSolutionAnalysts/sa-plug-avplayer/blob/master/SAVideoPlayer/SetVideoController.png)

Drag and drop IBOutlets from UI

```swift 
class ViewController : UIViewController{
   
    @IBOutlet weak var viewVideo: ViewVideo!
    @IBOutlet weak var videoController: VideoController!
    
}
```

### Add and select images for buttons, play, pause, fullscreen, exitFullscreen, next and previous from Attribute Inspector as shown below
![alt text](https://github.com/teamSolutionAnalysts/sa-plug-avplayer/blob/master/SAVideoPlayer/Set%20Images%20for%20controller.png)

### To Play video from url streaming

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    setUpPlayerWithURlStreaming()
}

func setUpPlayerWithURlStreaming()
{
    self.viewVideo.configure(url: self.url, ControllView: self.videoController)
    self.viewVideo.delegate = self
    self.viewVideo.play()
 }
```

### To Play video from local path with extension
```swift
override func viewDidLoad() {
    super.viewDidLoad()
    setUpPlayerWithLocal()
}

func setUpPlayerWithLocal()
{
    viewVideo.configure(ControllView: self.videoController,localPath:"localpath",fileextension : "mp4")
    viewVideo.delegate = self
    viewVideo.play()
 }
```

### Add PlayerEventDelegate

```swift 
// MARK: - Player Delegate Methods
extension ViewController : PlayerEventDelegate
{
    func AVPlayer(minimizevideoScreen: Bool) {
      
    }
    
    func AVPlayer(panGesture didTriggerd: UIPanGestureRecognizer?) {
        
    }
    
    func totalTime(_ player: AVPlayer) {
        
    }
    
    func AVPlayer(didEndPlaying: AVPlayer?) {
        //Play your next video
	//Replace your local video with next one
        self.viewVideo.replacelocalVideo(path: "Your next video path", videoextension: "mp4")
	
	OR
	
	//Replace your streaming url with next one
	self.viewVideo.replaceVideo(videourl: "url")
	
    }
    
    func AVPlayer(didTap overLay: AVPlayer?) {
    }
    
    func AVPlayer(willExpand player: AVPlayer?) {
       
    }
    
    func AVPlayer(didTaptoNextvideo: AVPlayer?) {
	//Replace your local video with next one
        self.viewVideo.replacelocalVideo(path: "Your next video path", videoextension: "mp4")
	
	OR
	
	//Replace your streaming url with next one
	self.viewVideo.replaceVideo(videourl: "url")
    }
    
    func AVPlayer(didTaptoPreviousvideo: AVPlayer?) {
        //Replace your video with previous one
        self.viewVideo.replacelocalVideo(path: "Your previous video", videoextension: "mp4")
	
	OR
	
	//Replace your streaming url with next one
	self.viewVideo.replaceVideo(videourl: "url")
    }
    
    func AVPlayer(panGesture sender: UIGestureRecognizer?) {
        guard let sender = sender else{
            return
        }
        let touchPoint = sender.location(in: self.viewVideo?.window)
        if sender.state == UIGestureRecognizer.State.began {
            initialTouchPoint = touchPoint
        } else if sender.state == UIGestureRecognizer.State.changed {
            if (touchPoint.x - initialTouchPoint.x) > 10
            {
                self.viewVideo.fastForwardPlayer()
            }
            else if (initialTouchPoint.x - touchPoint.x) > 10
            {
                self.viewVideo.fastBackward()
            }
        }
    }
}

```

## Optional configuration

```swift
	self.viewVideo.saveVideoLocally = false
        self.viewVideo.currentVideoID = self.videoID // to manage video by id
        
        //Change slider configuration (optional)
        self.videoController.slider.baseColor  = // UIColor
        self.videoController.slider.bufferColor = // UIColor
        self.videoController.slider.progressColor = // UIColor
        self.videoController.slider.borderWidth = // CGFloat
        self.videoController.slider.roundedSlider = // Bool
```

### Player Rate 

```swift 
	self.viewVideo.changePlayerRate(rate: rate)
```
There is a method which lets you change the player

### Built With

* AVKit Framework
* URLSession is used

## Authors
Solution Analyst

## Reference:
The slider is used from raxcat/BufferSlider, git

## License

MIT License

Copyright (c) 2019 Solution Analysts Pvt. Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
