//
//  AudioSystem.swift
//  MyMusicPlayer
//
//  Created by Carlos Rivas on 12/29/17.
//  Copyright © 2017 CarlosRivas. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import MediaPlayer

class AudioSystem {
    
    private var myAudioPlayer = AVAudioPlayer()
    
    private let audioSession = AVAudioSession.sharedInstance()
    
    private var myNowPlayingInfo: [String: Any]? = nil
    private var needsToUpdateInfoCenter = false;
            
    public func initAudioSystem() {
        
        do {
            try audioSession.setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playback)))
            
        }
        catch {
            print("Audio session category could not be set!")
        }
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        Timer.scheduledTimer(timeInterval: TimeInterval(0.2), target: self, selector: #selector(CheckToUpdateInfoCenter), userInfo: nil, repeats: true)
    }
    
    public func prepareToPlaySong(MusicSong msong: MusicSong) {
        do {
            try myAudioPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: msong.getFilePath()))
        }
        catch {
            print("Could not load song with URL \(msong.getFilePath()) on myMusicPlayer!")
        }
        UpdateSongOnMyInfoCenter(ms: msong)
        //DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + TimeInterval(1.5), execute: {self.ReUpdateSongOnInfoCenter(ms: msong)})
        myAudioPlayer.prepareToPlay()
    }
    
    public func PlayAudio() {
        myNowPlayingInfo!.updateValue(1.0, forKey: MPNowPlayingInfoPropertyPlaybackRate)
        myNowPlayingInfo!.updateValue(myAudioPlayer.currentTime, forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime)
        
        needsToUpdateInfoCenter = true
        
        
        
        self.myAudioPlayer.play()
    }
    
    public func PauseAudio() {
        self.myAudioPlayer.pause()
        
        myNowPlayingInfo!.updateValue(myAudioPlayer.currentTime, forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime)
        myNowPlayingInfo!.updateValue(0.0, forKey: MPNowPlayingInfoPropertyPlaybackRate)
        
        needsToUpdateInfoCenter = true
    }
    
    public func StopAudio() {
        self.myAudioPlayer.stop()
        myNowPlayingInfo!.updateValue(0.0, forKey: MPNowPlayingInfoPropertyPlaybackRate)
        
        myAudioPlayer.currentTime = 0
        myNowPlayingInfo!.updateValue(myAudioPlayer.currentTime, forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime)
        
        needsToUpdateInfoCenter = true
    }
    
    public func isPlaying() -> Bool {
        return myAudioPlayer.isPlaying
    }
    
    public func UpdateAudioCurrentTime(time: TimeInterval) {
        /*if (time + 0.5 > myAudioPlayer.currentTime) {
            myAudioPlayer.currentTime = time - 1.1
        } else {
            myAudioPlayer.currentTime = time
        }*/
        myAudioPlayer.currentTime = time
        myNowPlayingInfo!.updateValue(myAudioPlayer.currentTime, forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime)
        needsToUpdateInfoCenter = true
    }
    
    private func UpdateSongOnMyInfoCenter(ms: MusicSong) {
        if (ms.getArtwork() == nil) {
            myNowPlayingInfo = [
                MPMediaItemPropertyTitle: ms.getSongTitle(),
                MPMediaItemPropertyArtist: ms.getArtistName(),
                //no artwork done
                MPMediaItemPropertyPlaybackDuration: myAudioPlayer.duration,
                MPNowPlayingInfoPropertyPlaybackRate: 1.0,
                MPNowPlayingInfoPropertyDefaultPlaybackRate: 1.0,
            ]
        }
        else {
            myNowPlayingInfo = [
                MPMediaItemPropertyTitle: ms.getSongTitle(),
                MPMediaItemPropertyArtist: ms.getArtistName(),
                MPMediaItemPropertyArtwork: MPMediaItemArtwork(boundsSize: ms.getArtwork()!.size, requestHandler: {(size) -> UIImage in return ms.getArtwork()!}),
                MPMediaItemPropertyPlaybackDuration: myAudioPlayer.duration,
                MPNowPlayingInfoPropertyPlaybackRate: 1.0,
                MPNowPlayingInfoPropertyDefaultPlaybackRate: 1.0,
            ]
        }
        
        
        needsToUpdateInfoCenter = true;
    }
    
    private func ReUpdateSongOnInfoCenter(ms: MusicSong) {
        let currentNowPlayingTitle = MPNowPlayingInfoCenter.default().nowPlayingInfo![MPMediaItemPropertyTitle]! as? String
        
        if (currentNowPlayingTitle != nil) {
            if (currentNowPlayingTitle != ms.getSongTitle()) {
                MPNowPlayingInfoCenter.default().nowPlayingInfo = [
                    MPMediaItemPropertyTitle: ms.getSongTitle(),
                    MPMediaItemPropertyArtist: ms.getArtistName(),
                    MPMediaItemPropertyArtwork: MPMediaItemArtwork(boundsSize: ms.getArtwork()!.size, requestHandler: {(size) -> UIImage in return ms.getArtwork()!}),
                    MPMediaItemPropertyPlaybackDuration: myAudioPlayer.duration,
                    MPNowPlayingInfoPropertyPlaybackRate: 1.0,
                    MPNowPlayingInfoPropertyDefaultPlaybackRate: 1.0,
                    MPNowPlayingInfoPropertyElapsedPlaybackTime: myAudioPlayer.currentTime
                ]
            }
        }
    }
    
    public func GetCurrentAudioURL() -> URL?{
        return myAudioPlayer.url
    }
    
    public func CheckHasReachedEndOfSong() -> Bool {
        if (myAudioPlayer.currentTime + 0.5 >= myAudioPlayer.duration - 0.5) {
            return true
        }
        else {
            return false
        }
    }
    
    @objc private func CheckToUpdateInfoCenter() {
        if (needsToUpdateInfoCenter == true) {
            needsToUpdateInfoCenter = false
            MPNowPlayingInfoCenter.default().nowPlayingInfo = myNowPlayingInfo
        }
    }
    
    public func CanChangeSong (currentSongMS: MusicSong) -> Bool {
        let currentSongName: String? = MPNowPlayingInfoCenter.default().nowPlayingInfo![MPMediaItemPropertyTitle]! as? String
        if (currentSongName != nil) {
            if (currentSongName! == currentSongMS.getSongTitle()) {
                return true
            }
            else {
                return false
            }
        }
        else {
            return false
        }
    }
    
    public func GetDuration() -> TimeInterval {
        return myAudioPlayer.duration
    }
    
    public func GetEllapsedTime() -> TimeInterval {
        return myAudioPlayer.currentTime
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
