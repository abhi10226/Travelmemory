//
//  PlayerScreenView.swift
//  SummerPlayerViewDemo
//
//  Created by derrick on 2020/09/04.
//  Copyright © 2020 Derrick. All rights reserved.
//

import UIKit
import AVKit

class PlayerScreenView: UIView {
    
    public var isPlaying: Bool = true
    private var isTapped: Bool = false
    
    var delegate: PlayerScreenViewDelegate?
    
    lazy private var playerTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "0.0"
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    lazy private var fullTimeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.text = "0.0"
        timeLabel.textColor = UIColor.white
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.textAlignment = .center
        return timeLabel
    }()
    
    lazy private var playerSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.thumbTintColor = UIColor.red
        slider.tintColor = UIColor.red
        slider.maximumTrackTintColor = UIColor(white: 1, alpha: 0.5)
        slider.addTarget(self, action: #selector(self.changeSeekSlider(_:)), for: .valueChanged)
        return slider
    }()
    
    lazy private var moreButton: UIButton = {
        let moreButton = UIButton()
        moreButton.setImage(UIImage(named: "more", in: Bundle(for: PlayerControllView.self), compatibleWith: nil), for: .normal)
        moreButton.tintColor = UIColor(white: 1, alpha: 1)
        moreButton.translatesAutoresizingMaskIntoConstraints = false
//        moreButton.addTarget(self, action: #selector(self.clickMoreButton(_:)), for: .touchUpInside)
        return moreButton
    }()
    
    lazy private var headerTitle: UILabel = {
        let headerTitle = UILabel()
        headerTitle.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        headerTitle.text = "SummerPlayer view is working"
        headerTitle.textColor = UIColor.white
        headerTitle.textAlignment = .left
        headerTitle.translatesAutoresizingMaskIntoConstraints = false
        
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(self.clickHeaderLabel(_:)))
        headerTitle.isUserInteractionEnabled = true
        headerTitle.addGestureRecognizer(labelTap)
        
//        headerTitle.addTarget(self, action: #selector(self.clickMoreButton(_:)), for: .touchUpInside)
        return headerTitle
    }()
    
    lazy private var topView: UIView = {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        headerView.alpha = 0.9
        headerView.addSubview(headerTitle)
//        headerView.addSubview(moreButton)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        return headerView
    }()
    
    lazy private var playButton: UIButton = {
        let playButton = UIButton()
        playButton.setImage(UIImage(named: "play", in: Bundle(for: PlayerControllView.self), compatibleWith: nil), for: .normal)
        
        
        playButton.tintColor = UIColor(white: 1, alpha: 1)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.addTarget(self, action: #selector(self.clickPlayButton(_:)), for: .touchUpInside)
        return playButton
    }()
    
    lazy private var bottomControlsStackView: UIStackView  = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    @objc func clickPlayButton(_ sender: UIButton) {
        print("clicked -> \(isPlaying)")
        
        isPlaying = !isPlaying
        delegate?.playPause(isPlaying)
        
        changePauseOrPlay(isActive: isPlaying)
        
    }
    
    @objc func clickHeaderLabel(_ sender: UIButton) {
        
        delegate?.didPressedHeaderLabel()
    }
    
    public func changePauseOrPlay(isActive:Bool) {
        
        if(isPlaying) {
            playButton.setImage(UIImage(named: "pause", in: Bundle(for: PlayerControllView.self), compatibleWith: nil), for: .normal)
        } else {
            playButton.setImage(UIImage(named: "play", in: Bundle(for: PlayerControllView.self), compatibleWith: nil), for: .normal)
            
        }
    }
    
    @objc func changeSeekSlider(_ sender: UISlider) {
        guard let totalDuration = delegate?.totalDuration else { return }
        let seekTime = CMTime(seconds: Double(sender.value) * totalDuration.asDouble, preferredTimescale: 100)
        playerTimeLabel.text = seekTime.description
        delegate?.seekToTime(seekTime)
        delegate?.didChangeSliderValue(seekTime)
    }
    
    
    
    func videoDidChange(_ time: CMTime) {
        playerTimeLabel.text = time.description
        guard let totalDuration = delegate?.totalDuration else { return }
        let totalTimeInFloat : Double = Double(CMTimeGetSeconds(totalDuration))
        let CurrentTimeInFloat : Double = Double(CMTimeGetSeconds(time))

        var sliderPercentage = (CurrentTimeInFloat * 100) / totalTimeInFloat
        playerSlider.value = Float((sliderPercentage)/100)
    }
    
    func resetPlayerUI() {
        playerTimeLabel.text = CMTime.zero.description
        playerSlider.value = 0.0
    }
    
    func videoDidStart(title:String) {
        playerTimeLabel.text = CMTime.zero.description
        playButton.setImage(UIImage(named: "pause", in: Bundle(for: PlayerControllView.self), compatibleWith: nil), for: .normal)
        
        playerSlider.value = 0.0
        fullTimeLabel.text = delegate?.totalDuration?.description ?? CMTime.zero.description
        
        headerTitle.text = title

    }
    
    public func applyTheme(_ theme: SummerPlayerViewTheme) {
        playerSlider.tintColor = theme.sliderTintColor
        playerSlider.thumbTintColor = theme.sliderThumbColor
        
        playerTimeLabel.textColor = theme.playerScreenTimelabelsTextColor
        playerTimeLabel.font = theme.playerScreenTimelabelsTextFont
        playerTimeLabel.backgroundColor = theme.playerScreenTimelabelsBackground
        
        fullTimeLabel.textColor = theme.playerScreenTimelabelsTextColor
        fullTimeLabel.font = theme.playerScreenTimelabelsTextFont
        fullTimeLabel.backgroundColor = theme.playerScreenTimelabelsBackground
        
        headerTitle.textColor = theme.playerScreenTitleLabelTextColor
        headerTitle.font = theme.playerScreenTitleLabelTextFont
        headerTitle.backgroundColor = theme.playerScreenTitleLabelBackground
        
    }
    
    lazy var bottomView: UIView = {
        
        let bottomView = UIView()
        bottomView.alpha = 0.9
        
        bottomView.addSubview(playButton)
        bottomView.addSubview(bottomControlsStackView)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        
        return bottomView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    fileprivate func hideAllUIComponents(_ willHide:Bool) {
        self.playerSlider.isHidden = willHide
//        self.moreButton.isHidden = willHide
        self.playButton.isHidden = willHide
        self.fullTimeLabel.isHidden = willHide
        self.playerTimeLabel.isHidden = willHide
//        self.headerTitle.isHidden = willHide
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        
        if(isTapped) {
            isTapped = !isTapped
            hideAllUIComponents(false)
        } else {
            isTapped = true
            hideAllUIComponents(true)
        }
        
        delegate?.didTappedPlayerScreenView(isTapped)
        
    }
    
    private func setupView() {
        addSubview(topView)
        addSubview(bottomView)
        setupTopLayout()
        setupBottomLayout()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        addGestureRecognizer(tap)
    }
    
    private func setupTopLayout() {
        NSLayoutConstraint.activate([
            
            headerTitle.topAnchor.constraint(equalTo: topView.topAnchor),
            headerTitle.bottomAnchor.constraint(equalTo: topView.bottomAnchor),
            headerTitle.leadingAnchor.constraint(equalTo: topView.leadingAnchor , constant: 30),
            headerTitle.trailingAnchor.constraint(equalTo: topView.trailingAnchor),
            
//            moreButton.centerYAnchor.constraint(equalTo: topView.centerYAnchor),
//            moreButton.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -10),
            
            topView.topAnchor.constraint(equalTo: topAnchor , constant: 25),
            topView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: trailingAnchor),
            topView.heightAnchor.constraint(equalToConstant: 40),
            
        ])
    }
    private func setupBottomLayout() {
        
        bottomControlsStackView.addArrangedSubview(playerTimeLabel)
        
        playerTimeLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        playerTimeLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        bottomControlsStackView.addArrangedSubview(playerSlider)
        playerSlider.centerYAnchor.constraint(equalTo: bottomControlsStackView.centerYAnchor, constant: 0).isActive = true
        
        bottomControlsStackView.addArrangedSubview(fullTimeLabel)
        
        fullTimeLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        fullTimeLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        bottomView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        let xConstraint = NSLayoutConstraint(item: bottomView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([
            
            bottomView.bottomAnchor.constraint(equalTo: bottomAnchor , constant: -30),
            bottomView.heightAnchor.constraint(equalToConstant: 40),
            xConstraint,
            
            playButton.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 0),
            playButton.heightAnchor.constraint(equalToConstant: 40),
            playButton.widthAnchor.constraint(equalToConstant: 40),
            
            bottomControlsStackView.leadingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: 40),
            bottomControlsStackView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: 0),
            bottomControlsStackView.heightAnchor.constraint(equalToConstant: 40),

        ])
        
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 300, height: 300)
    }
    
}


extension PlayerScreenView: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.classForCoder == UIButton.classForCoder() { return false }
        return true
    }
}

