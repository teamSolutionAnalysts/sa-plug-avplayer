//
//  DemoData.swift
//  SAVideoPlayer
//
//  Created by Paresh Prajapati on 14/05/19.
//  Copyright © 2019 Solutionanalysts. All rights reserved.
//

import Foundation
import UIKit
class DemoData : NSObject{
//    var mediaJSON  = ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4","http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4","http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4","http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4", "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4","http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4","http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDir.mp4","https://www.youtube.com/embed/tgbNymZ7vqY"]
    
    var mediaJSON : [video]{
        return [video(url:"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4" , thumbnail: nil),video(url:"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4" , thumbnail: nil),video(url:"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4" , thumbnail: nil),video(url:"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4" , thumbnail: nil),video(url:"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4" , thumbnail: nil),video(url:"https://www.youtube.com/embed/tgbNymZ7vqY" , thumbnail: nil)]
    }
}


struct video {
    var url: String = ""
    var thumbnail: UIImage?
    
}


