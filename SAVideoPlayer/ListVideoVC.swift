//
//  ListVideoVC.swift
//  SAVideoPlayer
//
//  Created by Paresh Prajapati on 13/05/19.
//  Copyright © 2019 Solutionanalysts. All rights reserved.
//

import UIKit
import AVKit
protocol VideoScreenMinimize : class{
    func didDismiss(view: ViewVideo?, and controlView: UIView?)
}

class ListVideoVC: UIViewController {

    var dataSource = DemoData().mediaJSON
    var intialFrame :CGRect = CGRect.zero
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    @IBOutlet weak var tableVideo: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableVideo.estimatedRowHeight = 220
        self.tableVideo.rowHeight = UITableView.automaticDimension
    }
}

extension ListVideoVC : UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellVideo", for: indexPath) as! cellVideo
        
        if let url = URL(string: self.dataSource[indexPath.row].url), self.dataSource[indexPath.row].thumbnail == nil
        {
            
            //cell.lblTitle.text = ""
            if ViewVideo.checkIfUrlIsEmbedded(url: self.dataSource[indexPath.row].url)
            {
                let imgurl = "http://img.youtube.com/vi/\(url.lastPathComponent)/3.jpg"
                cell.imgVideo.downloadImageFrom(link: imgurl, contentMode: UIView.ContentMode.scaleAspectFill)
            }
            else{
                AVAsset(url: url).generateThumbnail { (image) in
                    DispatchQueue.main.async {
                        guard let image = image else { return }
                        self.dataSource[indexPath.row].thumbnail = image
                        cell.imgVideo.image = image
                    }
                }
            }
        }
        else
        {
            cell.imgVideo.image = self.dataSource[indexPath.row].thumbnail
        }
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.children.forEach { (vc) in
                vc.removeFromParent()
                vc.view.removeFromSuperview()
                print("\nremoved")
            }
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "videoPlayer") as! ViewController
            nextVC.modalPresentationStyle = .overCurrentContext
            nextVC.url = self.dataSource[indexPath.row].url
            nextVC.videoID = indexPath.row
            nextVC.view.alpha = 0
//            nextVC.index = indexPath.row
            UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseInOut, animations: {
                self.addChild(nextVC)
                self.view.addSubview(nextVC.view)
                nextVC.view.alpha = 1
            }) { (finished) in
                nextVC.didMove(toParent: self)
            }
        }
    }
}

extension ListVideoVC {
    
}

class cellVideo : UITableViewCell
{
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgVideo: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.imgVideo.image = nil
    }
    
}



