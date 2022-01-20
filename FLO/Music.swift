//
//  Music.swift
//  FLO
//
//  Created by 장기화 on 2022/01/20.
//

import Foundation

struct Music: Codable {
    let singer: String
    let album: String
    let title: String
    let duration: Int
    let image: String
    let file: String
    let lyrics: String
}
