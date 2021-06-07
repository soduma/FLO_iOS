//
//  ViewController.swift
//  FLO
//
//  Created by 장기화 on 2021/06/03.
//

import UIKit
import AVFoundation
import Kingfisher

class ViewController: UIViewController {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var singer: UILabel!
    @IBOutlet weak var album: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var timeObserver: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coverImageView.layer.cornerRadius = 40
        readyForPlay()
        
        timeSlider.value = 0
//        updateTime(time: CMTime)
        
//        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 10), queue: .main, using: { time in
//            print(self.timeSlider.value)
//        })
        
    }
    
    @IBAction func touchPlayButton(_ sender: UIButton) {
        playButton.isSelected = !playButton.isSelected
        
        if playButton.isSelected == true {
            print("play")
            player?.play()
        } else {
            print("pause")
            player?.pause()
        }
    }
    
    @IBAction func seek(_ sender: UISlider) {
        guard let currentItem = player?.currentItem else { return }
        let position = Double(sender.value)
        let seconds = position * currentItem.duration.seconds
        let time = CMTime(seconds: seconds, preferredTimescale: 100)
        player?.seek(to: time)
    }
}

extension ViewController {
    func readyForPlay() {
        guard let url = URL(string: "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com/2020-flo/song.json") else {
            print("missing url")
            return
        }
        
        guard let jsonData = try? String(contentsOf: url).data(using: .utf8) else { return }
//        print(jsonData)
        
        guard let data = try? JSONDecoder().decode(Music.self, from: jsonData) else { return }
//        print(data)
//        print(data.singer)
//        print(data.image)
        
        songTitle.text = data.title
        singer.text = data.singer
        album.text = data.album
        
        guard let imageURL = URL(string: data.image) else { return }
        coverImageView.kf.setImage(with: imageURL)
        
        guard let fileURL = URL(string: data.file) else { return }
        playerItem = AVPlayerItem(url: fileURL)
        player = AVPlayer(playerItem: playerItem)
        
        let totalTime = Double(data.duration)
        totalLabel.text = secondsToString(seconds: totalTime)
        
        guard let currentTime = player?.currentItem?.currentTime().seconds else { return }
//        timeLabel.text = secondsToString(seconds: currentTime)
//        timeSlider.value = Float(currentTime/totalTime)
        
//        self.timeSlider.value = Float(currentTime / totalTime)
//        print(Float(currentTime / totalTime))
    }
    
    private func secondsToString(seconds: Double) -> String {
        guard seconds.isNaN == false else { return "00:00" }
        let totalSeconds = Int(seconds)
        let min = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", min, seconds)
    }
    
}

struct Music: Codable {
    let singer: String
    let album: String
    let title: String
    let duration: Int
    let image: String
    let file: String
}
