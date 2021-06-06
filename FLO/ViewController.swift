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
    @IBOutlet weak var zeroLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coverImageView.layer.cornerRadius = 40
        readyForPlay()
    }
    
    func readyForPlay() {
        guard let url = URL(string: "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com/2020-flo/song.json") else {
            print("missing url")
            return
        }
        
        guard let jsonData = try? String(contentsOf: url).data(using: .utf8) else { return }
        print(jsonData)
        
        guard let data = try? JSONDecoder().decode(Music.self, from: jsonData) else { return }
        
        print(data)
        print(data.singer)
        print(data.image)
        
        songTitle.text = data.title
        singer.text = data.singer
        album.text = data.album
        
        guard let imageURL = URL(string: data.image) else { return }
        coverImageView.kf.setImage(with: imageURL)
        
        guard let fileURL = URL(string: data.file) else { return }
        playerItem = AVPlayerItem(url: fileURL)
        player = AVPlayer(playerItem: playerItem)
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
    
    
}



struct Music: Codable {
    let singer: String
    let album: String
    let title: String
    let duration: Int
    let image: String
    let file: String
}
