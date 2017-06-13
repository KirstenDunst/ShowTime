//
//  SecondViewControllerTwo.m
//  ShowTime
//
//  Created by CSX on 2017/6/9.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//

#import "SecondViewControllerTwo.h"
#import <AliyunPlayerSDK/AliyunPlayerSDK.h>

#define KMAIN_WIDTH [[UIScreen mainScreen]bounds].size.width
#define KMAIN_HEIGHT [[UIScreen mainScreen]bounds].size.height

@interface SecondViewControllerTwo ()
{
    NSURL*  mSourceURL;
    AliVcMediaPlayer *player;
    
    UISlider *slider;
    UILabel *begainLabel;
    UILabel *AllLabel;
    NSTimer *mTimer;
    BOOL timeRemainingDecrements;
}
@property (nonatomic, strong) UIView *mPlayerView;

@end

@implementation SecondViewControllerTwo

- (void) SetMoiveSource:(NSURL*)url
{
    mSourceURL = [url copy];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor redColor];
    
    [self getNewIntitlizeWithPlayer];
    
    [self createView];
}

- (void)getNewIntitlizeWithPlayer{
    _mPlayerView = [[UIView alloc] init];
    _mPlayerView.frame = self.view.frame;
    _mPlayerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_mPlayerView];
    
    //初始化播放器的类
    player = [[AliVcMediaPlayer alloc] init];
    //创建播放器，传入显示窗口
    [player create:_mPlayerView];
    //注册准备完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OnVideoPrepared:) name:AliVcMediaPlayerLoadDidPreparedNotification object:player];
    //注册错误通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OnVideoError:) name:AliVcMediaPlayerPlaybackErrorNotification object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnVideoSeekingDidFinish:) name:AliVcMediaPlayerSeekingDidFinishNotification object:nil];
    NSLog(@">>>>>播放地址：%@",mSourceURL);
    //传入播放地址，准备播放
    [player prepareToPlay:mSourceURL];
    

}

- (void)createView{
    //暂停。播放按钮
    UIButton *PauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    PauseButton.frame = CGRectMake(KMAIN_WIDTH-50, KMAIN_HEIGHT-100, 50, 50);
    [PauseButton setBackgroundColor:[UIColor clearColor]];
    [PauseButton setImage:[UIImage imageNamed:@"moviePlay"] forState:UIControlStateNormal];
    [PauseButton addTarget:self action:@selector(paus:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:PauseButton];
    
    
    //重新播放按钮
    UIButton *RestartButton = [UIButton buttonWithType:UIButtonTypeSystem];
    RestartButton.frame = CGRectMake(0, KMAIN_HEIGHT-100, 50, 50);
    [RestartButton setBackgroundColor:[UIColor clearColor]];
    [RestartButton setTitle:@"rePlay" forState:UIControlStateNormal];
    [RestartButton addTarget:self action:@selector(restartPlay:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:RestartButton];
    
    //快退
    UIButton *BackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    BackButton.frame = CGRectMake(0, KMAIN_HEIGHT-150, 70, 50);
    [BackButton setBackgroundColor:[UIColor grayColor]];
    [BackButton setImage:[UIImage imageNamed:@"movieBackward"] forState:UIControlStateNormal];
    [BackButton setImage:[UIImage imageNamed:@"movieBackwardSelected"] forState:UIControlStateHighlighted];
    [BackButton addTarget:self action:@selector(backChoose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:BackButton];
    
    
    //快进
    UIButton *ForwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    ForwardButton.frame = CGRectMake(KMAIN_WIDTH-70, KMAIN_HEIGHT-150, 70, 50);
    [ForwardButton setBackgroundColor:[UIColor grayColor]];
    [ForwardButton setImage:[UIImage imageNamed:@"movieForward"] forState:UIControlStateNormal];
    [ForwardButton setImage:[UIImage imageNamed:@"movieForwardSelected"] forState:UIControlStateHighlighted];
    [ForwardButton addTarget:self action:@selector(ForwardChoose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:ForwardButton];
    
    
    slider = [[UISlider alloc]initWithFrame:CGRectMake(100, KMAIN_HEIGHT-100, KMAIN_WIDTH-200, 40)];
    slider.continuous = YES;//是否支持连续变化。默认情况下就是yes
    slider.value = 0.0;
    slider.minimumTrackTintColor = [UIColor blueColor];
    slider.maximumTrackTintColor = [UIColor whiteColor];
    slider.thumbTintColor = [UIColor redColor];
    [self.view addSubview:slider];
    [slider addTarget:self action:@selector(ChangePress:) forControlEvents:UIControlEventValueChanged];
    
    //进度时间（已经观看的时间）
    begainLabel = [[UILabel alloc]init];
    begainLabel.frame = CGRectMake(50, KMAIN_HEIGHT-100, 50, 40);
    begainLabel.font = [UIFont systemFontOfSize:14];
    begainLabel.textColor = [UIColor redColor];
    begainLabel.textAlignment = 1;
    [self.view addSubview:begainLabel];
    
    //总共的时间长度（所有的时间有多少）
    AllLabel = [[UILabel alloc]init];
    AllLabel.frame = CGRectMake(KMAIN_WIDTH-100, KMAIN_HEIGHT-100, 50, 40);
    AllLabel.font = [UIFont systemFontOfSize:14];
    AllLabel.textColor = [UIColor grayColor];
    AllLabel.textAlignment = 1;
    [self.view addSubview:AllLabel];
    
    
    //以下放在上面显示样式
    
    //关闭声音，开启声音
    UIButton *SoundButton = [UIButton buttonWithType:UIButtonTypeCustom];
    SoundButton.frame = CGRectMake(0, 70, 50, 50);
    [SoundButton setBackgroundColor:[UIColor grayColor]];
    [SoundButton setImage:[UIImage imageNamed:@"sound"] forState:UIControlStateNormal];
    [SoundButton addTarget:self action:@selector(SoundChoose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:SoundButton];
    
    
    //声音的进度条
    UISlider *voiceSlider = [[UISlider alloc]initWithFrame:CGRectMake(100, 100, KMAIN_WIDTH-200, 40)];
    voiceSlider.value = 0.5;
    voiceSlider.minimumTrackTintColor = [UIColor blueColor];
    voiceSlider.maximumTrackTintColor = [UIColor whiteColor];
    voiceSlider.thumbTintColor = [UIColor redColor];
    [self.view addSubview:voiceSlider];
    
    
    //亮度进度条
    UISlider *lightSlider = [[UISlider alloc]initWithFrame:CGRectMake(0, 280, 140, 40)];
    lightSlider.value = 0.5;
    lightSlider.transform = CGAffineTransformMakeRotation(-M_PI_2);
    lightSlider.minimumTrackTintColor = [UIColor blueColor];
    lightSlider.maximumTrackTintColor = [UIColor whiteColor];
    lightSlider.thumbTintColor = [UIColor redColor];
    [self.view addSubview:lightSlider];
    
    timeRemainingDecrements = NO;
     mTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(UpdateP:) userInfo:nil repeats:YES];
}
//播放暂停；
- (void)paus:(UIButton *)sender{
    static BOOL isPause;
    if (isPause) {
        [sender setImage:[UIImage imageNamed:@"moviePlay"] forState:UIControlStateNormal];
        [player pause];
    }else {
        [sender setImage:[UIImage imageNamed:@"moviePause"] forState:UIControlStateNormal];
        [player play];
    }
    isPause = !isPause;
}

//重新播放
- (void)restartPlay:(UIButton *)sender{
    [player reset];
    //创建播放器，传入显示窗口
    [player create:_mPlayerView];
    //传入播放地址，准备播放
    [player prepareToPlay:mSourceURL];
    
    [player stop];
}

//快退
- (void)backChoose:(UIButton *)sender{
//   [player seekTo:<#(NSTimeInterval)#>]
    
}

//快进
- (void)ForwardChoose:(UIButton *)sender{
    
}

//slider值改变的时候触发的事件
- (void)ChangePress:(UISlider *)sender{
    //调节滑杆的进度，进而调节进度显示。
//    seekto
    
}

- (void)SoundChoose:(UIButton *)sender{
    static BOOL closeVoice;
    if (closeVoice) {
        [sender setImage:[UIImage imageNamed:@"mute"] forState:UIControlStateNormal];
    }else{
        [sender setImage:[UIImage imageNamed:@"sound"] forState:UIControlStateNormal];
    }
    closeVoice = !closeVoice;
}
-(void)UpdateP:(NSTimer *)timer{
    
    //[self testInfo];
    
    //when seeking, do not update the slider
    
    double currentTime = player.currentPosition;
    double totalTime = player.duration;
    NSLog(@">>>>>>>>>>>>>>%f<<<<<<<<<<<<<<<<<<<<%f",currentTime,totalTime);
    [self setTimeLabValues:currentTime totalTime:totalTime];
}

- (void)setTimeLabValues:(double)currentTime totalTime:(double)totalTime {
    
    int currentTim = (int)currentTime/1000;
    int totalTim = (int)totalTime/1000;
    int minutesElapsed = currentTim/60%60;
    int secondsElapsed = currentTim%60;
    int hourElapsed = currentTim/360%24;
    
    begainLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hourElapsed,minutesElapsed,secondsElapsed];
    
    double minutesRemaining;
    double secondsRemaining;
    double hourRemaining;
    if (timeRemainingDecrements) {
        hourRemaining = floor((totalTime - currentTime)/3600.0);
        minutesRemaining = floor(fmod((totalTime - currentTime)/60.0,60.0));
        secondsRemaining = floor(fmod((totalTime - currentTime),60.0));
    } else {
        minutesRemaining = floor(fmod(totalTime/60.0,60.0));
        secondsRemaining = floor(fmod(totalTime,60.0));
        hourRemaining = floor(totalTime/3600.0);
    }
    AllLabel.text = timeRemainingDecrements ? [NSString stringWithFormat:@"-%02.0f:%02.0f:%02.0f", hourRemaining,minutesRemaining, secondsRemaining] : [NSString stringWithFormat:@"%02.0f:%02.0f:%02.0f", hourRemaining,minutesRemaining, secondsRemaining];
    
    slider.value = currentTime/totalTime;
    
}










- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void) OnVideoPrepared:(NSNotification *)notification
{
    //收到完成通知后，获取视频的相关信息，更新界面相关信息
        [slider setMinimumValue:0];
     begainLabel.text = [NSString stringWithFormat:@"%.2f",player.currentPosition];
       AllLabel.text = [NSString stringWithFormat:@"%.2f",player.duration];
    
}
-(void)OnVideoError:(NSNotification *)notification
{
    AliVcMovieErrorCode error_code = player.errorCode;
    NSLog(@"播放错误的原因：%ld",(long)error_code);
}
- (void)OnVideoSeekingDidFinish:(NSNotification *)notification{
    [mTimer invalidate];
    mTimer = nil;
}

@end
