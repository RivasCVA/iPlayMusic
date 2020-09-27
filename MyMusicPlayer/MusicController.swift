//
//  MusicController.swift
//  MyMusicPlayer
//
//  Created by Carlos Rivas on 1/10/18.
//  Copyright © 2018 CarlosRivas. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

class MusicController {
    
    let myAudioSystem: AudioSystem = AudioSystem()
    public var remoteControlCenter = MPRemoteCommandCenter.shared()
    
    var currentViewController: ViewController? = nil
    
    let myVolumeView = MPVolumeView()
    var myVolumeViewSlider: UISlider? = nil
    
    var allSongs: [MusicSong] = []
    
    var currentSongsArray: [MusicSong] = []
    var currentPlayingSongIndex = 0
    
    var isShuffling = false
    var SongIndexOrderWhileShuffling: [Int] = []
    
    
    public func InitSystem(viewController: ViewController) {
        currentViewController = viewController
        
        myAudioSystem.initAudioSystem()
        
        currentViewController!.view.addSubview(myVolumeView)
        myVolumeView.frame = CGRect(x: -1000, y: -1000, width: 0, height: 0)
        myVolumeView.clipsToBounds = false
        for sv in myVolumeView.subviews {
            if (sv is UISlider) {
                myVolumeViewSlider = (sv as! UISlider)
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
        
    MPRemoteCommandCenter.shared().playCommand.addTarget(viewController, action: #selector(viewController.PlayRemoteCommand))
    MPRemoteCommandCenter.shared().pauseCommand.addTarget(viewController, action: #selector(viewController.PauseRemoteCommand))
MPRemoteCommandCenter.shared().togglePlayPauseCommand.addTarget(viewController, action: #selector(viewController.PlayPauseToggleRemoteCommand))
    MPRemoteCommandCenter.shared().nextTrackCommand.addTarget(viewController, action: #selector(viewController.NextRemoteCommand))
    MPRemoteCommandCenter.shared().previousTrackCommand.addTarget(viewController, action: #selector(viewController.PreviousRemoteCommand))
MPRemoteCommandCenter.shared().changePlaybackPositionCommand.addTarget(viewController, action: #selector(viewController.ChangedPlaybackPosition(event:)))
        
        
        Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(CheckForEndOfSong), userInfo: nil, repeats: true)
        
        Timer.scheduledTimer(timeInterval: TimeInterval(1), target: viewController, selector: #selector(viewController.UpdateElapsedTimeSlider), userInfo: nil, repeats: true)
        
        
        Timer.scheduledTimer(timeInterval: TimeInterval(0.1), target: viewController, selector: #selector(viewController.CheckForManualVolumeChange), userInfo: nil, repeats: true)
        
    }
    
    public func AddNewSong(path filePath: String?, title songTitle: String, artist songArtist: String, genre songGenre: String, image Artwork: UIImage?) {
        
        let ms = MusicSong()
        ms.setArtistName(name: songArtist)
        if (filePath == nil) {
            print("File path for \(songTitle) does not exist!")
        }
        else {
            ms.setFilePath(path: filePath!)
        }
        ms.setSongTitle(title: songTitle)
        ms.setGenre(genre_: songGenre)
        ms.setArtwork(image: Artwork)
        
        allSongs.append(ms)
        currentSongsArray = allSongs
        
        if (allSongs.count == 1) {
            myAudioSystem.prepareToPlaySong(MusicSong: currentSongsArray[currentPlayingSongIndex])
        }
    }
    
    public func Play() {
        myAudioSystem.PlayAudio()
    }
    public func Pause() {
        myAudioSystem.PauseAudio()
    }
    public func Stop() {
        myAudioSystem.StopAudio()
    }
    public func NextSong() {
        let wasPlaying = myAudioSystem.isPlaying()
        if (!currentSongsArray.isEmpty && myAudioSystem.CanChangeSong(currentSongMS: currentSongsArray[currentPlayingSongIndex])) {
                if (isShuffling == true) {
                    if (SongIndexOrderWhileShuffling.isEmpty == true) {
                        currentPlayingSongIndex = Int(arc4random_uniform(UInt32(currentSongsArray.count)))
                        SongIndexOrderWhileShuffling.append(currentPlayingSongIndex)
                    }
                    else if (SongIndexOrderWhileShuffling.count == currentSongsArray.count) {
                        for i in 0 ... SongIndexOrderWhileShuffling.count - 1 {
                            if (SongIndexOrderWhileShuffling[i] == currentPlayingSongIndex) {
                                if (i == SongIndexOrderWhileShuffling.count - 1) {
                                    currentPlayingSongIndex = SongIndexOrderWhileShuffling[0]
                                }
                                else {
                                    currentPlayingSongIndex = SongIndexOrderWhileShuffling[i+1]
                                }
                                break
                            }
                        }
                    }
                    else if (SongIndexOrderWhileShuffling.last! == currentPlayingSongIndex) {
                        currentPlayingSongIndex = Int(arc4random_uniform(UInt32(currentSongsArray.count)))
                        var i = 0
                        while i <= SongIndexOrderWhileShuffling.count - 1 {
                            if (SongIndexOrderWhileShuffling[i] == currentPlayingSongIndex) {
                                currentPlayingSongIndex = Int(arc4random_uniform(UInt32(currentSongsArray.count)))
                                i = -1
                            }
                            i+=1
                        }
                        SongIndexOrderWhileShuffling.append(currentPlayingSongIndex)
                    }
                    else {
                        for i in 0 ... SongIndexOrderWhileShuffling.count - 1 {
                            if (SongIndexOrderWhileShuffling[i] == currentPlayingSongIndex) {
                                currentPlayingSongIndex = SongIndexOrderWhileShuffling[i+1]
                                break
                            }
                        }
                    }
                }
                else {
                    SongIndexOrderWhileShuffling.removeAll()
                    if (currentPlayingSongIndex >= currentSongsArray.count - 1) {
                        currentPlayingSongIndex = 0
                    }
                    else {
                        currentPlayingSongIndex += 1
                    }
                }
                myAudioSystem.prepareToPlaySong(MusicSong: currentSongsArray[currentPlayingSongIndex])
                if (wasPlaying) {
                    Play()
                }
            UpdateSongUIInfo()
            }
        else if (currentSongsArray.isEmpty) {
            print("There are not songs on MusicSong array!")
        }
    }
    
    public func PreviousSong() {
        let wasPlaying = myAudioSystem.isPlaying()
        if (!currentSongsArray.isEmpty && myAudioSystem.CanChangeSong(currentSongMS: currentSongsArray[currentPlayingSongIndex])) {
                if (isShuffling == true) {
                    
                    if (SongIndexOrderWhileShuffling.isEmpty) {
                        currentPlayingSongIndex = 0;
                    }
                    else if (SongIndexOrderWhileShuffling.count == currentSongsArray.count) {
                        for i in 0 ... SongIndexOrderWhileShuffling.count - 1 {
                            if (SongIndexOrderWhileShuffling[i] == currentPlayingSongIndex) {
                                if (i == 0) {
                                    currentPlayingSongIndex = SongIndexOrderWhileShuffling[SongIndexOrderWhileShuffling.count - 1]
                                }
                                else {
                                    currentPlayingSongIndex = SongIndexOrderWhileShuffling[i-1]
                                }
                                break
                            }
                        }
                    }
                    else if (SongIndexOrderWhileShuffling.count >= 2) {
                        for i in 0 ... SongIndexOrderWhileShuffling.count - 1 {
                            if (SongIndexOrderWhileShuffling[i] == currentPlayingSongIndex) {
                                if (i == 0) {
                                    currentPlayingSongIndex = SongIndexOrderWhileShuffling[0]
                                }
                                else {
                                    currentPlayingSongIndex = SongIndexOrderWhileShuffling[i-1]
                                }
                                break
                            }
                        }
                        
                    }
                    else {
                        currentPlayingSongIndex = SongIndexOrderWhileShuffling[0]
                    }
                    
                }
                else {
                    SongIndexOrderWhileShuffling.removeAll()
                    if (currentPlayingSongIndex <= 0) {
                        currentPlayingSongIndex = currentSongsArray.count - 1
                    }
                    else {
                        currentPlayingSongIndex -= 1
                    }
                }
                myAudioSystem.prepareToPlaySong(MusicSong: currentSongsArray[currentPlayingSongIndex])
                if (wasPlaying) {
                    Play()
                }
            UpdateSongUIInfo()
            }
        else if (currentSongsArray.isEmpty) {
            print("There are not songs on MusicSong array!")
        }
    }
    
    public func ReloadSong() {
        Pause()
        myAudioSystem.prepareToPlaySong(MusicSong: currentSongsArray[currentPlayingSongIndex])
        Play()
        UpdateSongUIInfo()
    }
    
    public func FilterSongsBasedOn(Genre genre: String) {
        var GenreHasBeenChanged = false
        
        if (currentViewController!.getCurrentGenreButtonType() != genre) {
            for song in allSongs {
                if (song.getGenre() == genre) {
                    if (GenreHasBeenChanged == false) {
                        currentSongsArray.removeAll()
                    }
                    GenreHasBeenChanged = true
                    currentSongsArray.append(song)
                }
            }
            if (GenreHasBeenChanged == false) { //Special options
                if (genre == "All") {
                    currentSongsArray = allSongs
                    GenreHasBeenChanged = true;
                }
            }
            
            if (GenreHasBeenChanged == true) {
                if (isShuffling == true) {
                    SongIndexOrderWhileShuffling.removeAll()
                    currentPlayingSongIndex = Int(arc4random_uniform(UInt32(currentSongsArray.count)))
                    var i = 0
                    while i <= SongIndexOrderWhileShuffling.count - 1 {
                        if (SongIndexOrderWhileShuffling[i] == currentPlayingSongIndex) {
                            currentPlayingSongIndex = Int(arc4random_uniform(UInt32(currentSongsArray.count)))
                            i = -1
                        }
                        i+=1
                    }
                    SongIndexOrderWhileShuffling.append(currentPlayingSongIndex)
                }
                else {
                    currentPlayingSongIndex = 0;
                }
                let wasPlaying = self.isPlaying()
                ReloadSong()
                if (!wasPlaying) {
                    Pause()
                }
            }
        }
    }
    
    public func UpdateSongPlaybackPosition(NewTime: TimeInterval) {
        myAudioSystem.UpdateAudioCurrentTime(time: NewTime)
        CheckForEndOfSong()
    }
    
    @objc private func CheckForEndOfSong() {
        if (myAudioSystem.CheckHasReachedEndOfSong() && myAudioSystem.isPlaying()) {
            NextSong()
        }
    }
    
    @objc private func PPlay() {
        Play()
    }
    
    public func GetCurrentArtwork() -> UIImage? {
        return currentSongsArray[currentPlayingSongIndex].getArtwork()
    }
    
    public func GetCurrentSongDuration() -> TimeInterval {
        return myAudioSystem.GetDuration()
    }
    
    public func GetCurrentElapsedTime() -> TimeInterval {
        return myAudioSystem.GetEllapsedTime()
    }
    
    public func UpdateSongUIInfo() {
        if (GetCurrentArtwork() != nil) {
            currentViewController!.ArtworkImageView.image = self.GetCurrentArtwork()
        }
        else {
            currentViewController!.ArtworkImageView.image = UIImage(contentsOfFile: Bundle.main.path(forResource: "NoImageWarning", ofType: "png")!)
        }
        
        currentViewController!.SongElapsedTimeSlider.minimumValue = 0.0
        currentViewController!.SongElapsedTimeSlider.maximumValue = Float(self.GetCurrentSongDuration())
        currentViewController!.UpdateElapsedTimeSlider()
        currentViewController!.SongNameLabel.text = currentSongsArray[currentPlayingSongIndex].getSongTitle()
        currentViewController!.ArtistNameLabel.text = currentSongsArray[currentPlayingSongIndex].getArtistName()
    }
    
    public func SetVolume(newVolume: Float) {
        myVolumeViewSlider!.value = newVolume
    }
    
    public func isPlaying() -> Bool {
        return myAudioSystem.isPlaying()
    }
    
    @objc func handleInterruption(_ notification: Notification) {
        guard let info = notification.userInfo,
            let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        if type == .began {
            // Interruption began, take appropriate actions (save state, update user interface)
            if (myAudioSystem.isPlaying()) {
                currentViewController!.PauseRemoteCommand()
            }
        }
        else if type == .ended {
            guard let optionsValue =
                info[AVAudioSessionInterruptionOptionKey] as? UInt else {
                    return
            }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                // Interruption Ended - playback should resume
                currentViewController!.PauseRemoteCommand()
            }
        }
    }
    
    public func ToggleShuffle() {
        self.isShuffling = !self.isShuffling
        if (isShuffling == true) {
            currentPlayingSongIndex = Int(arc4random_uniform(UInt32(currentSongsArray.count)))
            SongIndexOrderWhileShuffling.append(currentPlayingSongIndex)
            ReloadSong()
        }
    }
    
    
    public func SearchForTextInSongArray(Text text: String) -> [Int] {
        
        var SongsFoundWithFullTextIndex: [Int] = []
        //To make sure songs with starting letters get removed when the full text of a song is found
        var SongsWithTypedOrderCharacters: [Int] = []
        
        for i in 0...allSongs.count-1 {
            let NoSpaceText = text.trimmingCharacters(in: .whitespaces)
            if (allSongs[i].getSongTitle().lowercased() == text.lowercased() || allSongs[i].getSongTitle().lowercased() == NoSpaceText.lowercased()) {
                SongsFoundWithFullTextIndex.append(i)
            }
            else if (allSongs[i].getSongTitle().lowercased().first == text.lowercased().first && text.count <= allSongs[i].getSongTitle().count) {
                
                
                var hasAllLettersTyped = false
                for j in 0...text.count-1 {
                    let allSongsStringIndex = allSongs[i].getSongTitle().lowercased().index(allSongs[i].getSongTitle().startIndex, offsetBy: j)
                    let textStringIndex = text.lowercased().index(text.startIndex, offsetBy: j)
                    
                    if (allSongs[i].getSongTitle().lowercased()[allSongsStringIndex] == text.lowercased()[textStringIndex]) {
                        hasAllLettersTyped = true
                    }
                    else {
                        hasAllLettersTyped = false
                        break
                    }
                }
                if (hasAllLettersTyped == true) {
                    var isDuplicate = false
                    for index in SongsWithTypedOrderCharacters {
                        if (index == i) {
                            isDuplicate = true
                        }
                    }
                    if (!isDuplicate) {
                        SongsWithTypedOrderCharacters.append(i)
                    }
                }
                
                
            }
        }
        
        
        if (!SongsFoundWithFullTextIndex.isEmpty) {
            return SongsFoundWithFullTextIndex
        }
        else if (!SongsWithTypedOrderCharacters.isEmpty) {
            return SongsWithTypedOrderCharacters
        }
        else {
            
            var IndeciesOfArtistsThatMatchCompletely: [Int] = []
            var IndeciesOfArtistsThatHaveMatchingLetters: [Int] = []
            
            
            var tempInputText = text.lowercased()
            for sepWord in multipleArtistsSeperatingWords {
                if (tempInputText.contains(sepWord)) {
                    tempInputText = tempInputText.replacingOccurrences(of: String(sepWord), with: "*")
                }
            }
            var tempSplitInputText = tempInputText.components(separatedBy: "* ")
            var exInputText = tempSplitInputText.joined()
            if (exInputText.contains("*")) {
                tempSplitInputText = tempInputText.components(separatedBy: "*")
                exInputText = tempSplitInputText.joined()
            }
            
            let InputText = exInputText
            
            for i in 0...allSongs.count-1 {
                let ArtistsInSong = allSongs[i].getSplitArtistNames()
                
                let noSpaceInputText = InputText.trimmingCharacters(in: .whitespaces)
                
                for artistName in ArtistsInSong {
                    if (artistName.contains(" ")) {
                        let separatedArtistName = artistName.components(separatedBy: " ")
                        for sepName in separatedArtistName {
                            if (sepName == noSpaceInputText) {
                                IndeciesOfArtistsThatMatchCompletely.append(i)
                            }
                        }
                    }
                    if (artistName == InputText || artistName == noSpaceInputText) {
                        IndeciesOfArtistsThatMatchCompletely.append(i)
                    }
                }
                
                
                var matchesNoLetterOfInputText = false
                var hasOneOrMoreWordsMatched = false
                for artistName in ArtistsInSong {
                    
                    for partOfName in artistName.components(separatedBy: " ") {

                        for partOfText in InputText.components(separatedBy: " ") {
                            
                                if (partOfText != "" && partOfText != " ") {
                                
                                for j in 0...partOfText.count-1 {
                                    
                                    if (partOfName.count-1 < j) {
                                        break
                                    }
                                    
                                    let partOfNameIndex = partOfName.index(partOfName.startIndex, offsetBy: j)
                                    let partOfTextIndex = partOfText.index(partOfText.startIndex, offsetBy: j)
                                    if (partOfName[partOfNameIndex] == partOfText[partOfTextIndex]) {
                                        if (j == partOfText.count-1) {
                                            IndeciesOfArtistsThatHaveMatchingLetters.append(i)
                                            hasOneOrMoreWordsMatched = true
                                        }
                                    }
                                    else {
                                        if (hasOneOrMoreWordsMatched == false) {
                                            matchesNoLetterOfInputText = true
                                        }
                                        /*
                                        if (partOfTextLoopCount >= 1) {
                                            matchesNoLetterOfInputText = true
                                            if (IndeciesOfArtistsThatHaveMatchingLetters.contains(i)) {
                                                IndeciesOfArtistsThatHaveMatchingLetters.remove(at: IndeciesOfArtistsThatHaveMatchingLetters.index(of: i)!)
                                            }
                                        }
                                        */
                                        break
                                    }
                                    
                                }
                                    
                            }
                            
                            if (matchesNoLetterOfInputText == true) {
                                break
                            }
                        }
                        
                    }
                    
                }
                
            }
            
            //// ALLOWS ALL ARTIST NAMES TO BE "SCANNED/COMPARED" AND ALSO THE FULL NAME OF ARTISTS/////////
            var FilteredIndeciesOfArtistsThatHaveMatchingLetters: [Int] = []
            var hadDuplicate = false
            var maxMatchingIndecies = 0 //Makes sure the song(s) with the most duplicates is the only one shown
            for index in IndeciesOfArtistsThatHaveMatchingLetters {
                
                var numMatchingIndecies = 0 //There should always be 1 (the current testing index)
                for index2 in IndeciesOfArtistsThatHaveMatchingLetters {
                    if (index == index2) {
                        numMatchingIndecies += 1
                    }
                }
                
                if (numMatchingIndecies < maxMatchingIndecies && maxMatchingIndecies != 0) {
                    numMatchingIndecies = 0 //so that index is not added anymore
                }
                else if (numMatchingIndecies > maxMatchingIndecies && maxMatchingIndecies != 0) {
                    FilteredIndeciesOfArtistsThatHaveMatchingLetters.removeAll()
                    maxMatchingIndecies = numMatchingIndecies
                }
                else if (maxMatchingIndecies == 0) {
                    maxMatchingIndecies = numMatchingIndecies
                }
                if (numMatchingIndecies > 1) {
                    hadDuplicate = true
                    if (!FilteredIndeciesOfArtistsThatHaveMatchingLetters.contains(index)) {
                        FilteredIndeciesOfArtistsThatHaveMatchingLetters.append(index)
                    }
                }
                
            }
            
            if (hadDuplicate == true) {
                IndeciesOfArtistsThatHaveMatchingLetters = FilteredIndeciesOfArtistsThatHaveMatchingLetters
            }
            ////////////////////////////////////////////////////////////////////////////////////////////////
 
            
            if (!IndeciesOfArtistsThatMatchCompletely.isEmpty) {
                return IndeciesOfArtistsThatMatchCompletely
            }
            else if (!IndeciesOfArtistsThatHaveMatchingLetters.isEmpty) {
                return IndeciesOfArtistsThatHaveMatchingLetters
            }
            else {
                return []
            }
            
        }
    }
}





















//Failed search engine for artists // newer version above
/*
 var ArtistsFoundWithFullTextIndex: [Int] = []
 var ArtistsWithAtLeastOneTextIndex: [Int] = []
 var OtherPossibelArtistsIndex: [Int] = []
 
 var textHadLatestFullWordOfArtist = false
 var lastLetterMatches = false
 for i in 0...allSongs.count-1 {
 
 
 if (allSongs[i].getArtistName().lowercased() == text.lowercased()) {
 ArtistsFoundWithFullTextIndex.append(i)
 LatestFullWordOfArtist = allSongs[i].getArtistName().lowercased().components(separatedBy: " ")[allSongs[i].getArtistName().lowercased().components(separatedBy: " ").count-1]
 textHadLatestFullWordOfArtist = true
 }
 else {
 
 let splitArtistNameArray = allSongs[i].getArtistName().lowercased().split(separator: " ")
 let splitTextArray = text.lowercased().split(separator: " ")
 
 
 
 //THIS IS ALL PROCESSING ONLY 1 SONG
 var EndProcessHasOneOrMoreWords = false
 var EndProcessHasSignificantPartOfWord = false //3+ digits
 var HasLatestFullWordOfArtist = false
 
 var artistNameCount = 0
 for artistName in splitArtistNameArray {
 var hasPartOfWord = false
 
 var textNameCount = 0
 for textName in splitTextArray {
 
 for j in 0...textName.count-1 {
 
 if (textName.count <= artistName.count && String(artistName) != "ft.") {
 
 
 
 //print(artistName)
 if ((String(artistName) == LatestFullWordOfArtist && String(splitArtistNameArray[0]) == String(splitTextArray[0])) || LatestFullWordOfArtist == "") {
 HasLatestFullWordOfArtist = true
 textHadLatestFullWordOfArtist = true
 print(LatestFullWordOfArtist)
 print(artistName)
 }
 
 let artistNameStringIndex = artistName.index(artistName.startIndex, offsetBy: j)
 let textStringIndex = textName.index(textName.startIndex, offsetBy: j)
 
 if (artistName[artistNameStringIndex] == textName[textStringIndex]) {
 
 if (textNameCount == splitTextArray.count-1 && artistNameCount == splitArtistNameArray.count-1) {
 lastLetterMatches = true
 }
 
 
 print("\(artistName.last!) : \(textName[textStringIndex])")
 if (artistName.last! == textName[textStringIndex] && j == textName.count-1 && j == artistName.count-1 && HasLatestFullWordOfArtist) {
 EndProcessHasOneOrMoreWords = true
 LatestFullWordOfArtist = String(artistName)
 hasPartOfWord = false
 break
 }
 else if (LatestFullWordOfArtist.isEmpty || HasLatestFullWordOfArtist) { //SIG
 hasPartOfWord = true
 EndProcessHasSignificantPartOfWord = true
 }
 
 }
 else {
 hasPartOfWord = false
 EndProcessHasSignificantPartOfWord = false
 break
 }
 
 }
 
 }
 
 //end of j loop
 if (hasPartOfWord) { //doest need to see other words
 break
 }
 textNameCount += 1
 }
 
 //end of textName loop
 if (hasPartOfWord) { //doest need to see other words
 break
 }
 artistNameCount += 1
 }
 
 //end of artistName loop
 if (EndProcessHasOneOrMoreWords && HasLatestFullWordOfArtist && lastLetterMatches) {
 ArtistsWithAtLeastOneTextIndex.append(i)
 }
 else if (EndProcessHasSignificantPartOfWord) {
 OtherPossibelArtistsIndex.append(i)
 }
 }
 }
 
 
 if (!textHadLatestFullWordOfArtist) {
 LatestFullWordOfArtist = ""
 }
 
 
 if (!ArtistsFoundWithFullTextIndex.isEmpty && ArtistsWithAtLeastOneTextIndex.isEmpty) {
 return ArtistsFoundWithFullTextIndex
 }
 else if (!ArtistsWithAtLeastOneTextIndex.isEmpty) {
 if (ArtistsFoundWithFullTextIndex.count > 0) {
 for index in ArtistsFoundWithFullTextIndex {
 ArtistsWithAtLeastOneTextIndex.append(index)
 }
 }
 return ArtistsWithAtLeastOneTextIndex
 
 }
 else {
 return OtherPossibelArtistsIndex
 }
 
 */
