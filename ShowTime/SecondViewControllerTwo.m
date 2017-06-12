//
//  SecondViewControllerTwo.m
//  ShowTime
//
//  Created by CSX on 2017/6/9.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//

#import "SecondViewControllerTwo.h"
#import <AliyunPlayerSDK/AliyunPlayerSDK.h>

@interface SecondViewControllerTwo ()
{
    NSURL*  mSourceURL;
    AliVcMediaPlayer *player;
    
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
    NSLog(@">>>>>播放地址：%@",mSourceURL);
    //传入播放地址，准备播放
    [player prepareToPlay:mSourceURL];
    //开始播放
    [player play];
    
}
-(void) OnVideoPrepared:(NSNotification *)notification
{
    //收到完成通知后，获取视频的相关信息，更新界面相关信息
//    [self.playSlider setMinimumValue:0];
//    [self.playSlider setMaximumValue:player.duration];

}
-(void)OnVideoError:(NSNotification *)notification
{
    AliVcMovieErrorCode error_code = player.errorCode;
    NSLog(@"播放错误的原因：%ld",(long)error_code);
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

@end
