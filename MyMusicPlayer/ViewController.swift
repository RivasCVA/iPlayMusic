//
//  ViewController.swift
//  MyMusicPlayer
//
//  Created by Carlos Rivas on 12/28/17.
//  Copyright © 2017 CarlosRivas. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var myMusicController = MusicController()
    
    @IBOutlet weak var PlayButton: UIButton!
    @IBOutlet weak var PauseButton: UIButton!
    
    @IBOutlet weak var VolumeSlider: UISlider!
    
    @IBOutlet weak var ArtworkImageView: UIImageView!
    
    @IBOutlet weak var SongElapsedTimeSlider: UISlider!
    
    @IBOutlet weak var SongTimeLabel: UILabel!
    
    
    @IBOutlet weak var SongNameLabel: UITextField!
    
    @IBOutlet weak var ArtistNameLabel: UITextField!
    
    @IBOutlet weak var GenrePullDownButton: UIButton!
    var isGenreMenuDown = false
    
    @IBOutlet var GenreTypeButtons: [UIButton]!
    
    private var currentSelectedGenreTypeButton: UIButton? = nil
    
    @IBOutlet weak var ShuffleButton: UIButton!
    
    
    @IBOutlet weak var SearchSongTextField: UITextField!
    
    
    @IBOutlet weak var SearchSongTableView: UITableView!
    var SearchedSongIndecies: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myMusicController.InitSystem(viewController: self)
        
        self.SearchSongTextField.delegate = self
        
        self.SearchSongTableView.delegate = self
        self.SearchSongTableView.dataSource = self
        
        loadAllSongs(MusicController: myMusicController)
        
        PlayButton.isEnabled = true
        PlayButton.isHidden = false
        PauseButton.isEnabled = false
        PauseButton.isHidden = true
        
        SearchSongTableView.isHidden = true
        SearchSongTableView.rowHeight = CGFloat(55)
        
        ArtworkImageView.image = myMusicController.GetCurrentArtwork()
        let sliderImage = UIImage(contentsOfFile: Bundle.main.path(forResource: "SongSlider2", ofType: "png")!)
        SongElapsedTimeSlider.setThumbImage(sliderImage!, for: .normal)
        
        
        myMusicController.UpdateSongUIInfo()
        
        for button in GenreTypeButtons {
            button.isHidden = true
            if (button.titleLabel!.text! == "All") {
                currentSelectedGenreTypeButton = button
                ChangeButtonBackgroundColor(Button: currentSelectedGenreTypeButton!, Color: .darkGray)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        SearchSongTextField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        SearchSongTableView.isOpaque = false
        SearchSongTableView.backgroundColor = .white
        SearchSongTableView.backgroundView = nil
    }
    
    //this code excutles at the beginning and/or when you reload the data of tableview
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (SearchedSongIndecies.count)
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchedsongs", for: indexPath) as! CustomTableViewCell
        
        cell.SongNameLabel.text = myMusicController.allSongs[SearchedSongIndecies[indexPath.row]].getSongTitle()
        cell.ArtistNameLabel.text = myMusicController.allSongs[SearchedSongIndecies[indexPath.row]].getArtistName()
        cell.SongArtwork.image = myMusicController.allSongs[SearchedSongIndecies[indexPath.row]].getArtwork()
        
        return (cell)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for button in GenreTypeButtons {
            if (button.titleLabel!.text! == "All") {
                GenreTypeButtonPressed(button)
            }
        }
        if (myMusicController.isShuffling) {
            ShuffleButtonPressed(ShuffleButton)
        }
        myMusicController.currentSongsArray = myMusicController.allSongs
        myMusicController.currentPlayingSongIndex = SearchedSongIndecies[indexPath.row]
        let wasPlaying = myMusicController.isPlaying()
        myMusicController.ReloadSong()
        if (!wasPlaying) {
            myMusicController.Pause()
        }
        self.view.endEditing(true)
        SearchSongTextField.text = ""
        
    }
    
    
    
    
    @objc func PlayRemoteCommand() -> MPRemoteCommandHandlerStatus {
        PlayButton(PlayButton)
        return .success
    }
    @objc func PauseRemoteCommand() -> MPRemoteCommandHandlerStatus {
        PauseButton(PauseButton)
        return .success
    }
    @objc func PlayPauseToggleRemoteCommand()  -> MPRemoteCommandHandlerStatus {
        if (myMusicController.isPlaying()) {
            PauseButton(PauseButton)            
        }
        else {
            PlayButton(PlayButton)
        }
        return .success
    }
    @objc func NextRemoteCommand()  -> MPRemoteCommandHandlerStatus {
        myMusicController.NextSong()
        return .success
    }
    @objc func PreviousRemoteCommand()  -> MPRemoteCommandHandlerStatus {
        myMusicController.PreviousSong()
        return .success
    }
    @objc func ChangedPlaybackPosition(event: MPChangePlaybackPositionCommandEvent)  -> MPRemoteCommandHandlerStatus {
        myMusicController.UpdateSongPlaybackPosition(NewTime: event.positionTime)
        return .success
    }
    @objc func UpdateElapsedTimeSlider() {
        if (SongElapsedTimeSlider.isTracking == false) {
            SongElapsedTimeSlider.value = Float(myMusicController.GetCurrentElapsedTime())
            UpdateSongTimeLabel(Time: myMusicController.GetCurrentElapsedTime())
        }
        
        //Also checks for the case in which the song is playing, but button is wrong
        if (PlayButton.isEnabled == true && myMusicController.isPlaying()) {
            PauseButton(PauseButton)
        }
        else if (PauseButton.isEnabled == true && myMusicController.isPlaying() == false) {
            PauseButton(PauseButton)
        }
        
    }
    @objc func CheckForManualVolumeChange() {
        if (VolumeSlider.value != myMusicController.myVolumeViewSlider!.value) {
            setVolumeSlider(value: myMusicController.myVolumeViewSlider!.value)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func PlayButton(_ sender: UIButton) {
        myMusicController.Play()
        SwitchPlayPauseButton()

    }
    
    @IBAction func PauseButton(_ sender: UIButton) {
        myMusicController.Pause()
        SwitchPlayPauseButton()
    }
    
    @IBAction func StopButton(_ sender: UIButton) {
        myMusicController.Stop()
    }
    
    @IBAction func NextSongButton(_ sender: UIButton) {
        myMusicController.NextSong()
    }
    
    @IBAction func PreviousSongButton(_ sender: UIButton) {
        myMusicController.PreviousSong()
    }
    
    
    @IBAction func SearchSongTextFieldEditingDidBegin(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.SearchSongTableView.isHidden = false
        }
    }
    
    
    @IBAction func SearchSongTextFieldEditingDidEnd(_ sender: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.SearchSongTableView.isHidden = true
            self.SearchedSongIndecies.removeAll()
            self.SearchSongTableView.reloadData()
        }
    }
    
    
    @IBAction func GenreButtonPressed(_ sender: UIButton) {
        ToggleGenreMenu()
    }
    
    @IBAction func SeachSongTextFieldEditingChanged(_ sender: UITextField) {
        var indecies: [Int] = []
        if let newText = sender.text {
            indecies = myMusicController.SearchForTextInSongArray(Text: newText)
        }
        if (!indecies.isEmpty || indecies.isEmpty) {
            SearchedSongIndecies = indecies
            SearchSongTableView.reloadData()
        }
        else if (sender.text!.isEmpty) {
            SearchedSongIndecies = []
            SearchSongTableView.reloadData()
        }
    }
    
    @IBAction func GenreTypeButtonPressed(_ sender: UIButton) {
        myMusicController.FilterSongsBasedOn(Genre: sender.titleLabel!.text!)
        // ChangeButtonBorderColor(Button: currentSelectedGenreTypeButton!, Color: .black)
        ChangeButtonBackgroundColor(Button: currentSelectedGenreTypeButton!, Color: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1))
        currentSelectedGenreTypeButton = sender
        // ChangeButtonBorderColor(Button: currentSelectedGenreTypeButton!, Color: .cyan)
        ChangeButtonBackgroundColor(Button: currentSelectedGenreTypeButton!, Color: .darkGray)
        if (!GenreTypeButtons[0].isHidden) {
            ToggleGenreMenu()
        }
    }
    
    @IBAction func VolumeSliderChanged(_ sender: UISlider) {
        myMusicController.SetVolume(newVolume: sender.value / 100.0)
    }
    
    
    @IBAction func ShuffleButtonPressed(_ sender: UIButton) {
        ToggleShuffle()
        if (myMusicController.isShuffling) {
            ChangeButtonBackgroundColor(Button: sender, Color: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1))
        }
        else {
            ChangeButtonBackgroundColor(Button: sender, Color: .darkGray)
        }
    }
    
    
    @IBAction func SongElapsedTimeSliderChanged(_ sender: UISlider) {
        myMusicController.UpdateSongPlaybackPosition(NewTime: TimeInterval(sender.value))
        
    }
    
    
    @IBAction func SongElapsedTimeSliderIsTracking(_ sender: UISlider) {
        UpdateSongTimeLabel(Time: Double(sender.value))
    }
    
    
    
    func SwitchPlayPauseButton() {
        if (PauseButton.isEnabled == true) {
            PlayButton.isEnabled = true
            PlayButton.isHidden = false
            PauseButton.isEnabled = false
            PauseButton.isHidden = true
        }
        else {
            PlayButton.isEnabled = false
            PlayButton.isHidden = true
            PauseButton.isEnabled = true
            PauseButton.isHidden = false
        }
    }
    
    func UpdateSongTimeLabel(Time time: Double) {
        var newTime = Double(time)
        newTime = newTime / 60.0
        let minutes = Int(floor(newTime))
        let seconds = Int((newTime - Double(minutes)) * 60.0)
        var secondsString: String = ""
        if (seconds < 10) {
            secondsString = String("0\(seconds)")
        }
        else {
            secondsString = String("\(seconds)")
        }
        
        SongTimeLabel.text = String("\(minutes):") + secondsString
    }
    
    func setVolumeSlider(value: Float) {
        VolumeSlider.value = value * 100.0
    }
    
    private func ToggleGenreMenu() {
        isGenreMenuDown = !isGenreMenuDown
        GenreTypeButtons.forEach { (button) in
            UIView.animate(withDuration: 0.2, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    private func ChangeButtonBorderColor(Button button: UIButton, Color color: UIColor) {
        button.layer.borderColor = color.cgColor
    }
    
    private func ChangeButtonBackgroundColor(Button button: UIButton, Color color: UIColor) {
        button.backgroundColor = color
    }
    
    private func ChangeButtonTextColor(Button button: UIButton, Color color: UIColor) {
        button.setTitleColor(color, for: .normal)
    }
    
    public func getCurrentGenreButtonType() -> String {
        return currentSelectedGenreTypeButton!.titleLabel!.text!
    }
    
    public func ToggleShuffle() {
        myMusicController.ToggleShuffle();
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        if (isGenreMenuDown == true) {
            ToggleGenreMenu()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

