//
//  ViewControllerOne.m
//  ShowTime
//
//  Created by CSX on 2017/6/13.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//

#import "ViewControllerOne.h"
#import <AlivcLiveVideo/AlivcLiveVideo.h>

#define KMAIN_WIDTH [[UIScreen mainScreen]bounds].size.width
#define KMAIN_HEIGHT [[UIScreen mainScreen]bounds].size.height

@interface ViewControllerOne ()<AlivcLiveSessionDelegate>

/* 推流地址 */
@property (nonatomic, strong) NSString *url;
/* 推流模式（横屏or竖屏）*/
@property (nonatomic, assign) BOOL isScreenHorizontal;

@property(nonatomic, strong)AlivcLiveSession *liveSession;

/* 摄像头方向记录 */
@property (nonatomic, assign) AVCaptureDevicePosition currentPosition;

@end

@implementation ViewControllerOne


- (instancetype)initWithUrl:(NSString *)url isScreenHorizontal:(BOOL)isScreenHorizontal{
    self = [super init];
    self.url = url;
    _isScreenHorizontal = isScreenHorizontal;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [self createView];
    
    [self liveVideoShow];
}

- (void)createView{
    //美颜
    UIButton *BeautifulButton = [UIButton buttonWithType:UIButtonTypeCustom];
    BeautifulButton.frame = CGRectMake(0, KMAIN_HEIGHT-50-50, 100, 40);
    [BeautifulButton setBackgroundColor:[UIColor clearColor]];
    [BeautifulButton setTitle:@"美颜" forState:UIControlStateNormal];
    [BeautifulButton setBackgroundImage:[self createImageWithColor:[UIColor blueColor]] forState:UIControlStateSelected];
    [BeautifulButton addTarget:self action:@selector(beautifulChoose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:BeautifulButton];
    
    //闪光灯
    UIButton *FlashLightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    FlashLightButton.frame = CGRectMake(0, KMAIN_HEIGHT-100-50, 100, 40);
    [FlashLightButton setBackgroundColor:[UIColor clearColor]];
    [FlashLightButton setTitle:@"闪光灯" forState:UIControlStateNormal];
    [FlashLightButton setBackgroundImage:[self createImageWithColor:[UIColor blueColor]] forState:UIControlStateSelected];
    [FlashLightButton addTarget:self action:@selector(FlashChoose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:FlashLightButton];
    
    //摄像头
    UIButton *CameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CameraButton.frame = CGRectMake(0, KMAIN_HEIGHT-150-50, 100, 40);
    [CameraButton setBackgroundColor:[UIColor clearColor]];
    [CameraButton setTitle:@"摄像头" forState:UIControlStateNormal];
    [CameraButton setBackgroundImage:[self createImageWithColor:[UIColor blueColor]] forState:UIControlStateSelected];
    [CameraButton addTarget:self action:@selector(CameraChoose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:CameraButton];
    
    //静音推流
    UIButton *VolumnCleanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    VolumnCleanButton.frame = CGRectMake(0, KMAIN_HEIGHT-200-50, 100, 40);
    [VolumnCleanButton setBackgroundColor:[UIColor clearColor]];
    [VolumnCleanButton setTitle:@"静音推流" forState:UIControlStateNormal];
    [VolumnCleanButton setBackgroundImage:[self createImageWithColor:[UIColor blueColor]] forState:UIControlStateSelected];
    [VolumnCleanButton addTarget:self action:@selector(VolumnCleanChoose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:VolumnCleanButton];
    
    //断开连接
    UIButton *LoseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    LoseButton.frame = CGRectMake(0, KMAIN_HEIGHT-250-50, 100, 40);
    [LoseButton setBackgroundColor:[UIColor clearColor]];
    [LoseButton setTitle:@"断开连接" forState:UIControlStateNormal];
    [LoseButton setBackgroundImage:[self createImageWithColor:[UIColor blueColor]] forState:UIControlStateSelected];
    [LoseButton addTarget:self action:@selector(LoseChoose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:LoseButton];
}

- (void)liveVideoShow{
    //初始化 config 配置类
    AlivcLConfiguration *configuration = [[AlivcLConfiguration alloc] init];
    //设置推流地址
    configuration.url = self.url;
    //设置最大码率
    configuration.videoMaxBitRate = 1500 * 1000;
    //设置当前视频码率
    configuration.videoBitRate = 600 * 1000;
    //设置最小码率
    configuration.videoMinBitRate = 400 * 1000;
    //设置视频帧率
    configuration.fps = 25;
    //设置音频码率
    configuration.audioBitRate = 64 * 1000;
    //设置直播分辨率
    configuration.videoSize = CGSizeMake(360, 640);
    //设置横竖屏
    configuration.screenOrientation = self.isScreenHorizontal? AlivcLiveScreenHorizontal:AlivcLiveScreenVertical;
    //设置摄像头采集质量
    configuration.preset = AVCaptureSessionPresetiFrame1280x720;
    //设置前置摄像头或后置摄像头
    configuration.position = AVCaptureDevicePositionFront;
    //设置水印图片
    configuration.waterMaskImage = [UIImage imageNamed:@"watermask"];
    //设置水印位置
    configuration.waterMaskLocation = 1;
    //设置水印相对x边框距离
    configuration.waterMaskMarginX = 10;
    //设置水印相对y边框距离 
    configuration.waterMaskMarginY = 10;
    //设置重连超时时长
    configuration.reconnectTimeout = 5;
    
    
    
    //初始化 liveSession 类
    self.liveSession = [[AlivcLiveSession alloc]
                        initWithConfiguration: configuration];
    //设置session代理
    self.liveSession.delegate = self;
    
    
    
    //开启直播预览
    [self.liveSession alivcLiveVideoStartPreview];
    //开启直播
//    [self.liveSession alivcLiveVideoConnectServer];
    //获取直播预览视图
    [self.liveSession previewView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 预览view
        [self.view insertSubview:[self.liveSession previewView] atIndex:0];
    });
    
    
    
}
//打开美颜处理
- (void)beautifulChoose:(UIButton *)sender {
    [sender setSelected:!sender.selected];
    [self.liveSession setEnableSkin:sender.selected   ];
}

//打开闪光灯  (闪光灯只有对后摄像头打开的时候才有效。)
- (void)FlashChoose:(UIButton *)sender {
    [sender setSelected:!sender.selected];
    self.liveSession.torchMode = sender.selected;//关闭AVCaptureTorchModeOff
}

//摄像头调换
- (void)CameraChoose:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    self.liveSession.devicePosition = sender.isSelected ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
    self.currentPosition = self.liveSession.devicePosition;
}

//静音推流
- (void)VolumnCleanChoose:(UIButton *)sender {
    [sender setSelected:!sender.selected];
    self.liveSession.enableMute = sender.selected;
}

//断开连接
- (void)LoseChoose:(UIButton *)sender {
    
    
    //缩放
    [self.liveSession alivcLiveVideoZoomCamera:1.0f];
    //聚焦
//    [self.liveSession alivcLiveVideoFocusAtAdjustedPoint:percentPoint autoFocus:YES];
    //调试信息
    AlivcLDebugInfo  *i = [self.liveSession dumpDebugInfo];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //停止预览，注意:停止预览后将liveSession置为nil
    [self.liveSession alivcLiveVideoStopPreview];
    //关闭直播
    [self.liveSession alivcLiveVideoDisconnectServer];
    //销毁直播 session
    self.liveSession = nil;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(UIImage*)createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
@end
