//
//  VacationViewController.swift
//  Vacation 360
//
//  Created by Ryan Farley on 9/28/16.
//  Copyright © 2016 perf. All rights reserved.
//

import UIKit

class VacationViewController: UIViewController {
    
    @IBOutlet weak var imageVRView: GVRPanoramaView!
    @IBOutlet weak var videoVRView: GVRVideoView!
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var videoLabel: UILabel!
    
    enum Media {
        static var photoArray = ["sindhu_beach.jpg", "grand_canyon.jpg", "underwater.jpg"]
        static let videoURL = "https://s3.amazonaws.com/ray.wenderlich/elephant_safari.mp4"
    }
    
    var currentView: UIView?
    var currentDisplayMode = GVRWidgetDisplayMode.embedded
    var isPaused = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageLabel.isHidden = true
        imageVRView.isHidden = true
        videoLabel.isHidden = true
        videoVRView.isHidden = true
        
        imageVRView.load(UIImage(named: Media.photoArray.first!), of: GVRPanoramaImageType.mono)
        imageVRView.enableCardboardButton = true
        imageVRView.enableFullscreenButton = true
        imageVRView.delegate = self
        
        videoVRView.load(from: URL(string: Media.videoURL))
        videoVRView.enableCardboardButton = true
        videoVRView.enableFullscreenButton = true
        videoVRView.delegate = self
    }
    
    func refreshVideoPlayStatus() {
        if currentView == videoVRView && currentDisplayMode != GVRWidgetDisplayMode.embedded {
            videoVRView?.resume()
            isPaused = false
        }
        else {
            videoVRView?.pause()
            isPaused = true
        }
    }
}

extension VacationViewController: GVRWidgetViewDelegate {
    func widgetView(_ widgetView: GVRWidgetView!, didLoadContent content: Any!) {
        if content is UIImage {
            imageVRView.isHidden = false
            imageLabel.isHidden = false
        } else if content is URL {
            videoVRView.isHidden = false
            videoLabel.isHidden = false
            refreshVideoPlayStatus()
        }
    }

    func widgetView(_ widgetView: GVRWidgetView!, didFailToLoadContent content: Any!, withErrorMessage errorMessage: String!) {
        print(errorMessage)
    }

    func widgetView(_ widgetView: GVRWidgetView!, didChange displayMode: GVRWidgetDisplayMode) {
        currentView = widgetView
        currentDisplayMode = displayMode
        refreshVideoPlayStatus()
        
        if currentView == imageVRView && currentDisplayMode != GVRWidgetDisplayMode.embedded {
            view.isHidden = true
        } else {
            view.isHidden = false
        }
    }

    func widgetViewDidTap(_ widgetView: GVRWidgetView!) {
        guard currentDisplayMode != GVRWidgetDisplayMode.embedded else {return}

        if currentView == imageVRView {
            Media.photoArray.append(Media.photoArray.removeFirst())
            imageVRView?.load(UIImage(named: Media.photoArray.first!), of: GVRPanoramaImageType.mono)
        } else {
            if isPaused {
                videoVRView?.resume()
            } else {
                videoVRView?.pause()
            }
            isPaused = !isPaused
        }

    }
}

extension VacationViewController: GVRVideoViewDelegate {
    func videoView(videoView: GVRVideoView!, didUpdatePosition position: NSTimeInterval) {
        if position >= videoView.duration() {
            videoView.seekTo(0)
            videoView.resume()
        }
    }
}
