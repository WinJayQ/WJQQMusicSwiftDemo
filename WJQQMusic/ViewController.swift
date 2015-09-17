//
//  ViewController.swift
//  WJQQMusic
//
//  Created by jh navi on 15/9/16.
//  Copyright (c) 2015年 WJ. All rights reserved.
//

import UIKit
import MediaPlayer
import QuartzCore

class ViewController: UIViewController,HttpProtocol {
    
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var photoBorderView: UIView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playTimeLabel: UILabel!
    @IBOutlet weak var allTimeLabel: UILabel!
    
    var eHttp:HttpController = HttpController()
    var tableData:NSArray = NSArray()
    var currentSong:Song = Song()
    var currentIndex: Int = 0
    var audioPlayer:MPMoviePlayerController=MPMoviePlayerController()
    var timer:NSTimer?


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //将图像变圆形
        photo.layer.cornerRadius = self.photo.frame.size.width/2
        photo.clipsToBounds = true
        photoBorderView.layer.cornerRadius = self.photoBorderView.frame.size.width/2
        photoBorderView.clipsToBounds = true
        //模糊效果
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.view.frame
        backgroundImageView.addSubview(blurView)
        //设置slider图标
        progressSlider.setMinimumTrackImage(UIImage(named: "player_slider_playback_left.png"), forState: UIControlState.Normal)
        progressSlider.setMaximumTrackImage(UIImage(named: "player_slider_playback_right.png"), forState: UIControlState.Normal)
        progressSlider.setThumbImage(UIImage(named: "player_slider_playback_thumb.png"), forState: UIControlState.Normal)
        
       // rotationAnimation()
        
        //请求网络数据
        eHttp.delegate=self
        eHttp.onSearch("http://douban.fm/j/mine/playlist?channel=1")//华语
    }

    //图片旋转动画
    func rotationAnimation(){
        let rotation=CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.timingFunction=CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        rotation.toValue=2*M_PI
        rotation.duration=16
        rotation.repeatCount=HUGE
        rotation.autoreverses=false
        photo.layer.addAnimation(rotation, forKey: "rotationAnimation")
        pauseLayer(photo.layer)
    }
    
    //停止Layer上面的动画
    func pauseLayer(layer:CALayer){
        var pausedTime:CFTimeInterval=layer.convertTime(CACurrentMediaTime(), fromLayer: nil)
        layer.speed=0.0
        layer.timeOffset=pausedTime
    }
    
    //继续Layer上面的动画
    func resumeLayer(layer:CALayer){
        var pausedTime:CFTimeInterval = layer.timeOffset
        layer.speed=1.0
        layer.timeOffset=0.0
        layer.beginTime=0.0
        var timeSincePause:CFTimeInterval=layer.convertTime(CACurrentMediaTime(), fromLayer: nil)-pausedTime
        layer.beginTime=timeSincePause
    }

    
    
    @IBAction func showPlayList(sender: UIButton) {
        var playList: PlayListView = NSBundle.mainBundle().loadNibNamed("PlayListView", owner: self, options: nil).last as! PlayListView
        playList.tableData=self.tableData
        playList.viewContorller=self
        playList.showPlayListView()
    }
    
    //请求网络数据结果
    func didRecieveResults(results:NSDictionary){
        NSLog("请求到的数据:%@", results)
        if (results["song"] != nil) {
            let resultData:NSArray = results["song"] as! NSArray
            NSLog("resultData = %@", resultData)
            let list:NSMutableArray = NSMutableArray()
            
            for(var index:Int=0;index<resultData.count;index++){
                var dic:NSDictionary = resultData[index] as! NSDictionary
                var song:Song=Song()
                NSLog("dic = %@",dic)
                song.setValuesForKeysWithDictionary(dic as [NSObject : AnyObject] )
                NSLog("song = %@",song.picture)
                list.addObject(song)
                NSLog("list = %d",list.count)
            }
            self.tableData=list
            self.setMyCurrentSong(list[0] as! Song)
           
        }
    }
    
    func setMyCurrentSong(curSong: Song) {
        currentSong = curSong
        currentIndex = tableData.indexOfObject(curSong)
        NSLog("%d",currentIndex)
        photo.image = getImageWithUrl(currentSong.picture)
        backgroundImageView.image = photo.image
        titleLabel.text = currentSong.title as String
        artistLabel.text = currentSong.artist as String
        playButton.selected = false
        playTimeLabel.text = "00:00"
        self.progressSlider.value = 0.0
        self.rotationAnimation()
        self.audioPlayer.stop()
        self.audioPlayer.contentURL=NSURL(string:currentSong.url as String)
        timer?.invalidate()
        timer=NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "updateTime", userInfo: nil, repeats: true)
        playButton.setImage(UIImage(named: "player_btn_play_normal.png"), forState: UIControlState.Normal)

    }
    
    //播放
    @IBAction func playButtonClick(sender: UIButton) {
        if sender.selected {
            //暂停播放
            self.audioPlayer.pause()
            pauseLayer(photo.layer)
            playButton.setImage(UIImage(named: "player_btn_play_normal.png"), forState: UIControlState.Normal)
            
        }else{
            //开始/继续播放
            self.audioPlayer.play()
            resumeLayer(photo.layer)
            playButton.setImage(UIImage(named: "player_btn_pause_highlight.png"), forState: UIControlState.Normal)
        }
        sender.selected = !sender.selected
    }
    
    //上一曲
    @IBAction func preSongClick(sender: UIButton) {
        NSLog("上一曲")
        if currentIndex > 0 {
            currentIndex--
        }
        currentSong = tableData.objectAtIndex(currentIndex) as! Song
        setMyCurrentSong(currentSong)
    }
    
    
    //下一曲
    @IBAction func nextSongClick(sender: UIButton) {
        NSLog("下一曲")
        if currentIndex < tableData.count {
            currentIndex++
        }
        currentSong = tableData.objectAtIndex(currentIndex) as! Song
        setMyCurrentSong(currentSong)
    }
    
    //更新播放时间
    func updateTime(){
        var c=audioPlayer.currentPlaybackTime
        // audioPlayer.endPlaybackTime
        if c>0.0 {
            let t=audioPlayer.duration
            let p:CFloat=CFloat(c/t)
            progressSlider.value=p;
            let all:Int=Int(c)//共多少秒
            let m:Int=all % 60//秒
            let f:Int=Int(all/60)//分
            var time=NSString(format:"%02d:%02d",f,m)
            playTimeLabel.text=time as String
        }
    }



}

