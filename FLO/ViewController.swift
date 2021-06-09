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
    @IBOutlet weak var tableView: UITableView!
    
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
    @IBOutlet weak var lyricsBookmarkButton: UIButton!
    
    var player = AVPlayer()
    var playerItem: AVPlayerItem?
    
    var lyricsList: [Int : String] = [:]
    var data: Music!
    var eachTime: Int = 0
    
    private var lyricForTable = Array<String>()
    private var timeForTable = Array<Int>()
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coverImageView.layer.cornerRadius = 40
        timeSlider.value = 0
        lyricsView.isHidden = true
        lyricsLabel.text = "..."
        lyricsBookmarkButton.isSelected = true
        buttonColor()
        
        readyForPlay()
        readyForLyrics()
        
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 10), queue: .main, using: { time in
            self.updateTime(time: time)
        })
    }
    
    @IBAction func touchPlayButton(_ sender: UIButton) {
        playButton.isSelected = !playButton.isSelected
        
        if playButton.isSelected == true {
            print("play")
            player.play()
        } else {
            print("pause")
            player.pause()
        }
    }
    
    @IBAction func seek(_ sender: UISlider) {
        guard let currentItem = player.currentItem else { return }
        let position = Double(sender.value)
        let seconds = position * currentItem.duration.seconds
        let time = CMTime(seconds: seconds, preferredTimescale: 100)
        player.seek(to: time)
    }
    
    @IBAction func touchLyrics(_ sender: UITapGestureRecognizer) {
        lyricsView.isHidden = false
    }
    
    @IBAction func touchLyricsClose(_ sender: UIButton) {
        lyricsView.isHidden = true
    }
    
    @IBAction func touchLyricsBookmarkButton(_ sender: UIButton) {
        lyricsBookmarkButton.isSelected = !lyricsBookmarkButton.isSelected
        buttonColor()
    }
    
    private func buttonColor() {
        if lyricsBookmarkButton.isSelected {
            if #available(iOS 13.0, *) {
                lyricsBookmarkButton.tintColor = .systemIndigo
            } else {
                lyricsBookmarkButton.tintColor = .purple
            }
            
        } else {
            lyricsBookmarkButton.tintColor = .systemGray
        }
    }
    
    func readyForPlay() {
        guard let url = URL(string: "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com/2020-flo/song.json") else {
            print("missing url")
            return
        }
        
        guard let jsonData = try? String(contentsOf: url).data(using: .utf8) else { return }
//        print(jsonData)
        
        data = try? JSONDecoder().decode(Music.self, from: jsonData)
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
            eachTime = minute! * 60 + second!
//            print("eachTime\(eachTime)")
            self.lyricsList[eachTime] = lyric
//            print(lyricsList[eachTime])
        }
    }
    
    func readyForLyrics() {
        for i in lyricsList.keys {
            timeForTable.append(i)
            timeForTable.sort()
        }
//        print("11111\(timeForTable)")
        
        for key in timeForTable {
            lyricForTable.append(lyricsList[key]!)
        }
//        print("22222\(lyricForTable)")
    }
    
    func updateTime(time: CMTime) {
        guard let currentItem = player.currentItem?.currentTime().seconds else { return }
//        print(currentItem)
        timeLabel.text = secondsToString(seconds: currentItem)
        
        if lyricsList[Int(currentItem)] != nil {
            lyricsLabel.text = lyricsList[Int(currentItem)]
        } else {
            lyricsLabel.text = lyricsLabel.text
        }
    }
    
    func updateCell(time: CMTime, setTime: Int, indexPath: IndexPath) {
        guard let currentItem = player.currentItem?.currentTime().seconds else { return }
//        let setTime = Int(TimeInterval(timeForTable)
//        print("111")
        
        if Int(currentItem) == setTime {
            tableView.cellForRow(at: indexPath)?.backgroundColor = .cyan
        } else {
            tableView.cellForRow(at: indexPath)?.backgroundColor = .clear
        }
//        if indexPath < indexPath.row {
            
//        }
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
        if lyricsBookmarkButton.isSelected {
            let currentTime = TimeInterval(timeForTable[indexPath.row])
            let time = CMTime(seconds: currentTime, preferredTimescale: 10)
            player.seek(to: time)
        } else {
            lyricsView.isHidden = true
        }
        
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lyricsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LyricCell", for: indexPath) as? LyricCell else {
            return UITableViewCell()
        }
//        print(lyricForTable[indexPath.row])
        cell.LyricCellLabel.text = lyricForTable[indexPath.row] //////
        
//        print(timeForTable[indexPath.row])
//        let currentTime = Int(player.currentItem!.currentTime().seconds)
//        print(currentTime)
        let setTime = Int(TimeInterval(timeForTable[indexPath.row]))
//        print(setTime)
//        print(timeForTable[indexPath.row])
        
//        if currentTime == Int(timeForTable[indexPath.row]) {
//            print("bbbbfbfbfbfbb")
//            cell.LyricCellLabel.textColor = .red
//        }
//        if timeForTable[indexPath.row] == Int(currentItem) {
//            print("yes")
//            lyricsLabel.text = lyricsList[Int(currentItem)]
//        } else {
//            lyricsLabel.text = lyricsLabel.text
//        }
        
//        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 10), queue: .main, using: { time in
//            self.updateTime(time: time)
//        })
        
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { time in
            self.updateCell(time: time, setTime: setTime, indexPath: indexPath)
        }
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
