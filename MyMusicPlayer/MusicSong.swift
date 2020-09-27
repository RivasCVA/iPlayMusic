//
//  MusicSong.swift
//  MyMusicPlayer
//
//  Created by Carlos Rivas on 1/10/18.
//  Copyright © 2018 CarlosRivas. All rights reserved.
//

import Foundation
import UIKit

public let multipleArtistsSeperatingWords: [String] = ["ft.", "feat", "and", "&", "with", ",", "feat.", "ft", "x", "w/", " y "]


class MusicSong {
    
    
    private var fullArtistName: String = ""
    private var splitArtistNames: [String] = []
    private var songTitle: String = ""
    private var filePath: String = ""
    private var genre: String = ""
    private var artwork: UIImage? = nil
    
    public func setArtistName(name: String) {
        fullArtistName = name
        
        //separates artists
        var fullName = fullArtistName.lowercased()
        for sepWord in multipleArtistsSeperatingWords {
            if (fullName.contains(sepWord)) {
                fullName = fullName.replacingOccurrences(of: sepWord, with: "*")
            }
        }
        splitArtistNames = fullName.components(separatedBy: "*")
        
        //Removes the spaces before and after each name and empty strings
        var removeIndecies: [Int] = []
        for i in 0...splitArtistNames.count-1 {
            if (splitArtistNames[i].isEmpty) {
                removeIndecies.append(i)
            }
            else {
                if (splitArtistNames[i] == " ") {
                    removeIndecies.append(i)
                }
                else {
                    for _ in 0...3 {
                        if (String(splitArtistNames[i].first!) == " ") {
                            splitArtistNames[i].remove(at: splitArtistNames[i].startIndex)
                        }
                        if (String(splitArtistNames[i].last!) == " ") {
                            splitArtistNames[i].remove(at: splitArtistNames[i].index(before: splitArtistNames[i].endIndex))
                        }
                    }
                }
            }
        }
        for index in removeIndecies {
            splitArtistNames.remove(at: index)
        }
        
    }
    public func setSongTitle(title: String) {
        songTitle = title
    }
    public func setFilePath(path: String) {
        filePath = path
    }
    public func setArtwork(image: UIImage?) {
        artwork = image
    }
    public func setGenre(genre_: String) {
        self.genre = genre_
    }
    
    public func getArtistName() -> String {
        return fullArtistName
    }
    public func getSongTitle() -> String {
        return songTitle
    }
    public func getFilePath() -> String {
        return filePath
    }
    public func getArtwork() -> UIImage? {
        return artwork
    }
    public func getGenre() -> String {
        return genre
    }
    public func getSplitArtistNames() -> [String] {
        //All names are lowercased
        return splitArtistNames
    }
    
}
