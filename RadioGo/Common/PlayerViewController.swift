import UIKit
import XCGLogger
import SnapKit
import AudioPlayerManager
import MediaPlayer
import DFCache
import Nuke

extension UINavigationController {
    override open var shouldAutorotate: Bool {
        get {
            if let visibleVC = visibleViewController {
                if visibleVC is PlayerViewController {
                    return false
                }
            }
            return super.shouldAutorotate
        }
    }
}

extension AudioPlayerManager {
    public func remoteControlReceivedWithEvent(_ event: UIEvent?) {
        if let _event = event {
            switch _event.subtype {
            case UIEventSubtype.remoteControlPlay:
                NotificationCenter.default.post(Notification(name: PlayerViewController.PlayNotification))
            case UIEventSubtype.remoteControlPause:
                NotificationCenter.default.post(Notification(name: PlayerViewController.PauseNotification))
            case UIEventSubtype.remoteControlTogglePlayPause:
                NotificationCenter.default.post(Notification(name: PlayerViewController.TogglePlayPauseNotification))
            default:
                break
            }
        }
    }
}

extension MPVolumeView {
    var volumeSlider: UISlider? {
        showsRouteButton = false
        showsVolumeSlider = false
        isHidden = true
        for subview in subviews where subview is UISlider {
            let slider =  subview as! UISlider
            slider.isContinuous = false
            slider.value = AVAudioSession.sharedInstance().outputVolume
            return slider
        }
        return nil
    }
}

class PlayerViewController: UIViewController {
    let log = XCGLogger.default
    
    static let shared: PlayerViewController = {
        let instance = PlayerViewController()
        return instance
    }()
    
    static let SystemVolumeNotification    = Notification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification")
    static let PlayNotification            = Notification.Name(rawValue: "PlayerViewControllerPlayNotification")
    static let PauseNotification           = Notification.Name(rawValue: "PlayerViewControllerPauseNotification")
    static let TogglePlayPauseNotification = Notification.Name(rawValue: "PlayerViewControllerTogglePlayPauseNotification")
    
    static let sizeImage     = CGFloat(40)
    static let spacingButton = CGFloat(20)
    
    var manager = Nuke.Manager.shared
    var station: Station!
    
    var stationImage           = UIImage(named: "music")
    
    let muteOnImage            = UIImage(named: "mute_on")?.resize(sizeImage, sizeImage)
    let muteOffImage           = UIImage(named: "mute_off")?.resize(sizeImage, sizeImage)
    
    let musicImage             = UIImage(named: "music")
    
    let playImage              = UIImage(named: "play")?.resize(80, 80)
    let pauseImage             = UIImage(named: "pause")?.resize(80, 80)
    var isMute           = false
    
    var stationImageView:   UIImageView!
    
    var volumeView:         UIView!
    var muteOnOffButton:    UIButton!
    var volumeSlider:       UISlider!

    var controlsView:              UIView!
    var timeSlider:                UISlider!
    var currentTimeLabel:          UILabel!
    var stationLabel:             UILabel!
    
    var buttonsView:               UIView!
    var playPauseButton:           UIButton!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = UIColor.white
        
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.volumeValueChanged(_:)), name: PlayerViewController.SystemVolumeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.playPauseTouched(_:)), name: PlayerViewController.TogglePlayPauseNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.didPressPauseRemote), name: PlayerViewController.PauseNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.didPressPlayRemote), name: PlayerViewController.PlayNotification, object: nil)
        
        self.initPlaybackTimeViews()
        self.updateButtonStates()
        
        // Listen to the player state updates. This state is updated if the play, pause or queue state changed.
        AudioPlayerManager.shared.addPlayStateChangeCallback(self, callback: { [weak self] (track: AudioTrack?) in
            self?.updateButtonStates()
            self?.updateSongInformation(with: track)
        })
        // Listen to the playback time changed. Thirs event occurs every `AudioPlayerManager.PlayingTimeRefreshRate` seconds.
        AudioPlayerManager.shared.addPlaybackTimeChangeCallback(self, callback: { [weak self] (track: AudioTrack?) in
            self?.updatePlaybackTime(track)
        })
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "arrow_down"), style: .plain, target: self, action: #selector(PlayerViewController.hideTouched(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "favorite_off"), style: .plain, target: self, action: #selector(PlayerViewController.addRemovefavoriteTouched(_:)))

        self.stationImageView = UIImageView()
        self.stationImageView.image = self.musicImage
        self.view.addSubview(self.stationImageView)
        self.stationImageView.snp.makeConstraints {
            $0.centerY.equalTo(self.view.snp.centerY).offset(-20)
            $0.centerX.equalTo(self.view.snp.centerX)
            $0.width.equalTo(300)
            $0.height.equalTo(300)
        }
        
        self.volumeView = UIView()
        self.view.addSubview(self.volumeView)
        self.volumeView.snp.makeConstraints {
            $0.bottom.equalTo(self.stationImageView.snp.top).offset(-20)
            $0.left.equalTo(self.view.snp.left).offset(5)
            $0.right.equalTo(self.view.snp.right).offset(-5)
            $0.height.equalTo((self.muteOnImage?.size.height)! + 5)
        }

        self.volumeSlider = UISlider()
        self.volumeSlider.addTarget(self, action: #selector(didChangeVolumeSliderValue), for: .valueChanged)
        self.volumeView.addSubview(self.volumeSlider)
        self.volumeSlider.snp.makeConstraints {
            $0.top.equalTo(self.volumeView.snp.top).offset(5)
            $0.left.equalTo(self.volumeView.snp.left).offset(5)
        }
        
        self.muteOnOffButton = UIButton()
        self.muteOnOffButton.addTarget(self, action: #selector(didChangeMuteStateValue), for: .touchUpInside)
        self.muteOnOffButton.setImage(self.muteOffImage, for: .normal)
        self.volumeView.addSubview(self.muteOnOffButton)
        self.muteOnOffButton.snp.makeConstraints {
            $0.top.equalTo(self.volumeView.snp.top).offset(5)
            $0.left.equalTo(self.volumeSlider.snp.right).offset(5)
            $0.right.equalTo(self.volumeView.snp.right).offset(-5)
        }
       
        self.controlsView = UIView()
        self.view.addSubview(self.controlsView)
        self.controlsView.snp.makeConstraints {
            $0.top.equalTo(self.stationImageView.snp.bottom).offset(5)
            $0.bottom.equalTo(self.view.snp.bottom).offset(-5)
            $0.left.equalTo(self.view.snp.left).offset(5)
            $0.right.equalTo(self.view.snp.right).offset(-5)
        }
        
        self.currentTimeLabel = UILabel(frame: CGRect.zero)
        self.currentTimeLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightThin)
        self.currentTimeLabel.text = "--:--"
        self.controlsView.addSubview(self.currentTimeLabel)
        self.currentTimeLabel.snp.makeConstraints {
            $0.top.equalTo(self.controlsView.snp.top).offset(5)
            $0.centerX.equalTo(self.controlsView.snp.centerX)
        }
        
        self.timeSlider = UISlider()
        self.timeSlider.addTarget(self, action: #selector(didChangeTimeSliderValue), for: .valueChanged)
        self.controlsView.addSubview(self.timeSlider)
        self.timeSlider.snp.makeConstraints {
            $0.top.equalTo(self.currentTimeLabel.snp.bottom)
            $0.left.equalTo(self.controlsView.snp.left).offset(5)
            $0.right.equalTo(self.controlsView.snp.right).offset(-5)
        }
        
        self.stationLabel = UILabel(frame: CGRect.zero)
        self.stationLabel.font = UIFont.boldSystemFont(ofSize: 20)
        self.stationLabel.textAlignment = .center
        self.stationLabel.text = ""
        self.controlsView.addSubview(self.stationLabel)
        self.stationLabel.snp.makeConstraints {
            $0.top.equalTo(self.timeSlider.snp.bottom)
            $0.left.equalTo(self.controlsView.snp.left).offset(5)
            $0.right.equalTo(self.controlsView.snp.right).offset(-5)
        }

        /* Buttons */
        self.buttonsView = UIView()
        self.controlsView.addSubview(self.buttonsView)
        self.buttonsView.snp.makeConstraints {
            $0.left.equalTo(self.controlsView.snp.left)
            $0.right.equalTo(self.controlsView.snp.right)
            $0.bottom.equalTo(self.controlsView.snp.bottom).offset(-20)
            $0.height.equalTo(80)
        }
        
        self.playPauseButton = UIButton()
        self.playPauseButton.addTarget(self, action: #selector(PlayerViewController.playPauseTouched(_:)), for: .touchUpInside)
        self.playPauseButton.setImage(self.playImage, for: .normal)
        self.buttonsView.addSubview(self.playPauseButton)
        self.playPauseButton.snp.makeConstraints {
            $0.center.equalTo(self.buttonsView.snp.center)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        manager = CachingDataLoader.manager
    }

    deinit {
        // Stop listening to the callbacks
        AudioPlayerManager.shared.removePlayStateChangeCallback(self)
        AudioPlayerManager.shared.removePlaybackTimeChangeCallback(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.log.info("volume = \(AVAudioSession.sharedInstance().outputVolume)")
        self.volumeSlider.value = AVAudioSession.sharedInstance().outputVolume
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.log.info("to: \(size)") // fare riferimento a 'to size'
    }

    func initPlaybackTimeViews() {
        self.timeSlider?.value = 0
        self.timeSlider?.maximumValue = 1.0
        self.currentTimeLabel?.text = "--:--"
    }
    
    func updateButtonStates() {
        //self.rewindButton?.isEnabled = AudioPlayerManager.shared.canRewind()
        if AudioPlayerManager.shared.isPlaying() {
            self.playPauseButton?.setImage(self.pauseImage, for: UIControlState())
        } else {
            self.playPauseButton?.setImage(self.playImage, for: UIControlState())
        }
        self.playPauseButton?.isEnabled = AudioPlayerManager.shared.canPlay()
        //self.forwardButton?.isEnabled = AudioPlayerManager.shared.canForward()
    }
    
    func updatePlaybackTime(_ track: AudioTrack?) {
        self.currentTimeLabel?.text = track?.displayablePlaybackTimeString() ?? "--:--"
        self.timeSlider?.value = track?.currentProgress() ?? 0
    }
    
    func updateSongInformation(with track: AudioTrack?) {
        self.stationLabel.text = self.station.name
        self.stationImageView.image = self.stationImage
        self.updatePlaybackTime(track)
    }

    func play(station: Station) {
        self.log.info(station)
        self.station = station
        
        let f = FavouriteDataHelper.shared
        if let favourite = f.find(byStationId: self.station.id) {
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "favorite_on")
        } else {
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "favorite_off")
        }
        
        if let url = URL(string: station.streamUrl) {
            AudioPlayerManager.shared.play(url: url)
            
            if let imageUrl = URL(string: station.imageUrl) {
                let request = Request(url: imageUrl)
                manager.loadImage(with: request, into: self.stationImageView)
            } else {
                self.stationImageView.image = self.musicImage
            }
            self.stationImage = self.stationImageView.image
        }
    }
}

extension PlayerViewController {
    func didPressPlayRemote(_ notification: Notification) {
        AudioPlayerManager.shared.play()
    }
    func didPressPauseRemote(_ notification: Notification) {
        AudioPlayerManager.shared.pause()
    }
    
    func volumeValueChanged(_ notification: Notification) {
        self.log.info(notification)
        if let volumeValue = notification.userInfo?["AVSystemController_AudioVolumeNotificationParameter"] as? Float {
            self.volumeSlider.value = volumeValue
        }
    }
    
    func didChangeVolumeSliderValue(_ sender: UISlider) {
        (MPVolumeView().subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}.first as? UISlider)?.setValue(self.volumeSlider.value, animated: false)
    }

    func didChangeMuteStateValue(_ sender: UIButton) {
        if self.isMute {
            self.isMute = false
            self.muteOnOffButton.setImage(self.muteOffImage, for: .normal)
        } else {
            self.isMute = true
            self.muteOnOffButton.setImage(self.muteOnImage, for: .normal)
        }
        AudioPlayerManager.shared.setMute(self.isMute)
        /*
         open func setMute(_ muted: Bool) {
            self.player?.isMuted = muted
         }
        */
    }
}

// MARK: - IBActions

extension PlayerViewController {
    @IBAction func addRemovefavoriteTouched(_ sender: UIBarButtonItem) {
        self.log.warning("Start")
        var isFavorite = false
        
        let f = FavouriteDataHelper.shared
        if let favourite = f.find(byStationId: self.station.id) {
            self.log.info("delete: \(f.delete(id: favourite.id))" )
            isFavorite = false
        } else {
            let favourite = Favourite(
                id:           0,
                stationId:    self.station.id,
                displayOrder: 1,
                description:  self.station.name,
                streamUrl:    self.station.streamUrl,
                imageUrl:     self.station.imageUrl)
            self.log.info("insert: \(f.insert(favourite))")
            f.reorder()
            isFavorite = true
        }
        
        if isFavorite {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "favorite_on"), style: .plain, target: self, action: #selector(PlayerViewController.addRemovefavoriteTouched(_:)))
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "favorite_off"), style: .plain, target: self, action: #selector(PlayerViewController.addRemovefavoriteTouched(_:)))
        }
    }
    
    @IBAction func hideTouched(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressStopButton(_ sender: AnyObject) {
        AudioPlayerManager.shared.stop()
    }
    
    @IBAction func playPauseTouched(_ sender: AnyObject) {
        AudioPlayerManager.shared.togglePlayPause()
    }
    
    @IBAction func didChangeTimeSliderValue(_ sender: Any) {
        guard let _newProgress = self.timeSlider?.value else {
            return
        }
        AudioPlayerManager.shared.seek(toProgress: _newProgress)
    }
}
