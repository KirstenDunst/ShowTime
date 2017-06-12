//
//  SecondViewControllerTwo.h
//  ShowTime
//
//  Created by CSX on 2017/6/9.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewControllerTwo : UIViewController

/**
 *  设置播放的视频地址，需要在试图启动之前设置
 *  参数url为本地地址或网络地址
 *  如果位本地地址，则需要用[NSURL fileURLWithPath:path]初始化NSURL
 *  如果为网络地址则需要用[NSURL URLWithString:path]初始化NSURL
 */
- (void) SetMoiveSource:(NSURL*)url;

@end
