//
//  AlivcLiveViewController.m
//  DevAlivcLiveVideo
//
//  Created by yly on 16/3/21.
//  Copyright © 2016年 Alivc. All rights reserved.
//


#import "AlivcLiveViewController.h"
#import <AlivcLiveVideo/AlivcLiveVideo.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

@interface AlivcLiveViewController ()<AlivcLiveSessionDelegate>


@property (nonatomic, strong) AlivcLiveSession *liveSession;

/* 推流模式（横屏or竖屏）*/
@property (nonatomic, assign) BOOL isScreenHorizontal;
/* 推流地址 */
@property (nonatomic, strong) NSString *url;
/* 摄像头方向记录 */
@property (nonatomic, assign) AVCaptureDevicePosition currentPosition;
/* 曝光度记录 */
@property (nonatomic, assign) CGFloat exposureValue;
// UI
@property (weak, nonatomic) IBOutlet UISlider *skinSlider;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *muteButton;

// 调试
@property (nonatomic, strong) CTCallCenter *callCenter;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableArray *logArray;

@property (nonatomic, assign) BOOL isCTCallStateDisconnected;
@property (nonatomic, assign) CGFloat lastPinchDistance;

@end

@implementation AlivcLiveViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSString *)url isScreenHorizontal:(BOOL)isScreenHorizontal{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    _url = url;
    _isScreenHorizontal = isScreenHorizontal;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.logArray = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self addGesture];

    [self createSession];
    
    [self startDebug];
    
    NSLog(@"版本号:%@", [AlivcLiveSession alivcLiveVideoVersion]);
}



#pragma mark - 推流Session 创建 销毁
- (void)createSession{
    
    AlivcLConfiguration *configuration = [[AlivcLConfiguration alloc] init];
    configuration.url = self.url;
    configuration.videoMaxBitRate = 1500 * 1000;
    configuration.videoBitRate = 600 * 1000;
    configuration.videoMinBitRate = 400 * 1000;
    configuration.audioBitRate = 64 * 1000;
    configuration.videoSize = CGSizeMake(360, 640);// 横屏状态宽高不需要互换
    configuration.fps = 20;
    configuration.preset = AVCaptureSessionPresetiFrame1280x720;
    configuration.screenOrientation = self.isScreenHorizontal;
    // 重连时长
    configuration.reconnectTimeout = 5;
    // 水印
    configuration.waterMaskImage = [UIImage imageNamed:@"watermask"];
    configuration.waterMaskLocation = 1;
    configuration.waterMaskMarginX = 10;
    configuration.waterMaskMarginY = 10;
    // 摄像头方向
    if (self.currentPosition) {
        configuration.position = self.currentPosition;
    } else {
        configuration.position = AVCaptureDevicePositionFront;
        self.currentPosition = AVCaptureDevicePositionFront;
    }
    configuration.frontMirror = YES;
    
    // alloc session
    self.liveSession = [[AlivcLiveSession alloc] initWithConfiguration:configuration];
    self.liveSession.delegate = self;
    // 是否静音推流
    self.liveSession.enableMute = self.muteButton.selected;
    // 开始预览
    [self.liveSession alivcLiveVideoStartPreview];
    // 开始推流
    [self.liveSession alivcLiveVideoConnectServer];
    
    NSLog(@"开始推流");

    dispatch_async(dispatch_get_main_queue(), ^{
        // 预览view
        [self.view insertSubview:[self.liveSession previewView] atIndex:0];
    });
    
    self.exposureValue = 0;
}

- (void)destroySession{
    [self.liveSession alivcLiveVideoDisconnectServer];
    [self.liveSession alivcLiveVideoStopPreview];
    [self.liveSession.previewView removeFromSuperview];
    self.liveSession = nil;
    NSLog(@"销毁推流");
}

#pragma mark - AlivcLiveVideo Delegate
- (void)alivcLiveVideoLiveSession:(AlivcLiveSession *)session error:(NSError *)error{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *msg = [NSString stringWithFormat:@"%zd %@",error.code, error.localizedDescription];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Live Error" message:msg delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"重新连接", nil];
        alertView.delegate = self;
        [alertView show];
    });
    
    NSLog(@"liveSession Error : %@", error);
}

- (void)alivcLiveVideoLiveSessionNetworkSlow:(AlivcLiveSession *)session {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前网络环境较差" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertView show];
    self.textView.text = @"网速过慢，影响推流效果，拉流端会造成卡顿等，建议暂停直播";
    NSLog(@"网速过慢");
    
}

- (void)alivcLiveVideoLiveSessionConnectSuccess:(AlivcLiveSession *)session {
    
    NSLog(@"推流  connect success!");
}


- (void)alivcLiveVideoReconnectTimeout:(AlivcLiveSession *)session error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"重连超时-error:%ld", error.code] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alertView show];
    });
    NSLog(@"重连超时");
}


- (void)alivcLiveVideoOpenAudioSuccess:(AlivcLiveSession *)session {
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"YES" message:@"麦克风打开成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    //        [alertView show];
    //    });
}

- (void)alivcLiveVideoOpenVideoSuccess:(AlivcLiveSession *)session {
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"YES" message:@"摄像头打开成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    //        [alertView show];
    //    });
}


- (void)alivcLiveVideoLiveSession:(AlivcLiveSession *)session openAudioError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"麦克风获取失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        //        [alertView show];
    });
}

- (void)alivcLiveVideoLiveSession:(AlivcLiveSession *)session openVideoError:(NSError *)error {
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"摄像头获取失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    //        [alertView show];
    //    });
}

- (void)alivcLiveVideoLiveSession:(AlivcLiveSession *)session encodeAudioError:(NSError *)error {
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"音频编码初始化失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    //        [alertView show];
    //    });
    
}

- (void)alivcLiveVideoLiveSession:(AlivcLiveSession *)session encodeVideoError:(NSError *)error {
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"视频编码初始化失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    //        [alertView show];
    //    });
}

- (void)alivcLiveVideoLiveSession:(AlivcLiveSession *)session bitrateStatusChange:(ALIVC_LIVE_BITRATE_STATUS)bitrateStatus {
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"YES" message:[NSString stringWithFormat:@"ALIVC_LIVE_BITRATE_STATUS = %ld", bitrateStatus] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    //        [alertView show];
    //    });
    NSLog(@"码率变化 %ld", bitrateStatus);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self.liveSession alivcLiveVideoConnectServer];
    } else {
        [self.liveSession alivcLiveVideoDisconnectServer];
    }
}



#pragma mark - Debug

- (void)startDebug {
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeUpdate) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

- (void)timeUpdate{
    
    // 获取调试信息
    AlivcLDebugInfo *i = [self.liveSession dumpDebugInfo];
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *currentDateStr = [dateFormatter   stringFromDate:currentDate];
    
    NSMutableString *msg = [[NSMutableString alloc] init];
    [msg appendFormat:@"%@\n",currentDateStr];
    [msg appendFormat:@"CycleDelay(%0.2fms)\n",i.cycleDelay];
    [msg appendFormat:@"bitrate(%zd) buffercount(%zd)\n",[self.liveSession alivcLiveVideoBitRate] ,self.liveSession.dumpDebugInfo.localBufferVideoCount];
    [msg appendFormat:@" efc(%zd) pfc(%zd)\n",i.encodeFrameCount, i.pushFrameCount];
    [msg appendFormat:@"%0.2ffps %0.2fKB/s %0.2fKB/s\n", i.fps,i.encodeSpeed, i.speed/1024];
    [msg appendFormat:@"%lluB pushSize(%lluB) status(%zd)",i.localBufferSize, i.pushSize, i.connectStatus];
    [msg appendFormat:@" %0.2fms\n",i.localDelay];
    [msg appendFormat:@"video_pts:%zd\naudio_pts:%zd\n", i.currentVideoPTS,i.currentAudioPTS];
    [msg appendFormat:@"fps:%f\n", i.fps];
    
    self.textView.text = msg;
}


#pragma mark - 手势
- (void)addGesture {
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.view addGestureRecognizer:gesture];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    [self.view addGestureRecognizer:pinch];
    
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleSwipe:)];
    [self.view addGestureRecognizer:recognizer];
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture{
    CGPoint point = [gesture locationInView:self.view];
    CGPoint percentPoint = CGPointZero;
    percentPoint.x = point.x / CGRectGetWidth(self.view.bounds);
    percentPoint.y = point.y / CGRectGetHeight(self.view.bounds);
    [self.liveSession alivcLiveVideoFocusAtAdjustedPoint:percentPoint autoFocus:YES];
    
}

- (void)pinchGesture:(UIPinchGestureRecognizer *)gesture {
    
    if (_currentPosition == AVCaptureDevicePositionFront) {
        return;
    }
    
    if (gesture.numberOfTouches != 2) {
        return;
    }
    CGPoint p1 = [gesture locationOfTouch:0 inView:self.view];
    CGPoint p2 = [gesture locationOfTouch:1 inView:self.view];
    CGFloat dx = (p2.x - p1.x);
    CGFloat dy = (p2.y - p1.y);
    CGFloat dist = sqrt(dx*dx + dy*dy);
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _lastPinchDistance = dist;
    }
    
    CGFloat change = dist - _lastPinchDistance;
    [self.liveSession alivcLiveVideoZoomCamera:(change / 1000 )];

}

- (void)handleSwipe:(UIPanGestureRecognizer *)swipe {
 
    if (swipe.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [swipe translationInView:self.view];
        CGFloat absX = fabs(translation.x);
        CGFloat absY = fabs(translation.y);
        
        if (MAX(absX, absY) < 10) {
            return;
        }
        if (absY > absX) {
            if (translation.y<0) {
                self.exposureValue += 0.01;
                [self.liveSession alivcLiveVideoChangeExposureValue:self.exposureValue];
                
            }else{
                self.exposureValue -= 0.01;
                [self.liveSession alivcLiveVideoChangeExposureValue:self.exposureValue];
            }
        }
    }
}


#pragma mark - Notification
- (void)appResignActive{
    
    // 退入后台停止推流 因为iOS后台机制，不能满足充分的摄像头采集和GPU渲染
    [self destroySession];
    
    // 监听电话
    _callCenter = [[CTCallCenter alloc] init];
    _isCTCallStateDisconnected = NO;
    _callCenter.callEventHandler = ^(CTCall* call) {
        if ([call.callState isEqualToString:CTCallStateDisconnected])
        {
            _isCTCallStateDisconnected = YES;
        }
        else if([call.callState isEqualToString:CTCallStateConnected])
            
        {
            _callCenter = nil;
        }
    };
    
    NSLog(@"退入后台");

}

- (void)appBecomeActive{
    
    if (_isCTCallStateDisconnected) {
        sleep(2);
    }
    // 回到前台重新推流
    [self createSession];
    
    NSLog(@"回到前台");
}

#pragma mark - Actions
- (IBAction)buttonCloseClick:(id)sender {
    [self destroySession];
    [_timer invalidate];
    _timer = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cameraButtonClick:(UIButton *)button {
    button.selected = !button.isSelected;
    self.liveSession.devicePosition = button.isSelected ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
    self.currentPosition = self.liveSession.devicePosition;
}

- (IBAction)skinButtonClick:(UIButton *)button {
    button.selected = !button.isSelected;
    [self.skinSlider setHidden:!button.selected];
    [self.liveSession setEnableSkin:button.isSelected];
}

- (IBAction)skinSliderAction:(UISlider *)sender {
    
    [self.liveSession alivcLiveVideoChangeSkinValue:sender.value];
    
}


- (IBAction)flashButtonClick:(UIButton *)button {
    button.selected = !button.isSelected;
    self.liveSession.torchMode = button.isSelected ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
}

- (IBAction)muteButton:(UIButton *)sender {
    [sender setSelected:!sender.selected];
    self.liveSession.enableMute = sender.selected;
}

- (IBAction)disconnectButtonClick:(UIButton *)sender {
    [sender setSelected:!sender.selected];
    if (self.liveSession.dumpDebugInfo.connectStatus == AlivcLConnectStatusNone) {
        [self.liveSession alivcLiveVideoConnectServer];
    }else{
        [self.liveSession alivcLiveVideoDisconnectServer];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
