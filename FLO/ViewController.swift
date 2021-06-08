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
    
    @IBOutlet weak var lyricsView: UIView!
    @IBOutlet weak var lyricsLabel: UILabel!
    @IBOutlet weak var lyricsCloseButton: UIButton!
    
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    
    var lyricsList: [Int : String] = [:]

        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lyricsView.isHidden = true
        coverImageView.layer.cornerRadius = 40
        readyForPlay()
        
        timeSlider.value = 0
        
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
    
    @IBAction func touchLyrics(_ sender: UITapGestureRecognizer) {
        lyricsView.isHidden = false
//        print(lyricsList)
    }
    
    @IBAction func touchLyricsClose(_ sender: UIButton) {
        lyricsView.isHidden = true
    }

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
        
        let list = data.lyrics.components(separatedBy: "\n")
        for element in list {
            let time = element.components(separatedBy: "]")[0]
            let lyric = element.components(separatedBy: "]")[1]
            
            let times = time.components(separatedBy: "[")[1]
            let minute = Int(times.components(separatedBy: ":")[0])
            let second = Int(times.components(separatedBy: ":")[1])
//            print(times)
//            print(lyric)
            let totalTime = minute! * 60 + second!
            
            self.lyricsList[totalTime] = lyric
            print(lyricsList[totalTime])
            
            self.lyricsLabel.text = self.lyricsList[totalTime]
//        }
        }
    }
    
    func secondsToString(seconds: Double) -> String {
        guard seconds.isNaN == false else { return "00:00" }
        let totalSeconds = Int(seconds)
        let min = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", min, seconds)
    }
}

extension ViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(lyricsList.count)
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LyricCell", for: indexPath) as? LyricCell else {
            return UITableViewCell()
        }
        cell.LyricCellLabel.text = lyricsList[indexPath.row]
        return cell
    }
}

class LyricCell: UITableViewCell {
    @IBOutlet weak var LyricCellLabel: UILabel!
}

struct Music: Codable {
    let singer: String
    let album: String
    let title: String
    let duration: Int
    let image: String
    let file: String
    let lyrics: String
}
