//
//  ThirdViewControllerOne.m
//  ShowTime
//
//  Created by CSX on 2017/6/8.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//

#import "ThirdViewControllerOne.h"
#import "XSMediaPlayer.h"

@interface ThirdViewControllerOne ()
@property(nonatomic,retain)XSMediaPlayer *player;

@end

@implementation ThirdViewControllerOne


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *path = [[NSBundle mainBundle]pathForResource:arc4random_uniform(2)? @"login_video":@"loginmovie" ofType:@"mp4"];
    
    _player = [[XSMediaPlayer alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    //    _player.videoURL = [NSURL fileURLWithPath:path];
    _player.videoURL = [NSURL fileURLWithPath:path];
    [self.view addSubview:_player];
   
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        self.view.backgroundColor = [UIColor whiteColor];
    }else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        self.view.backgroundColor = [UIColor blackColor];
    }
}
// 哪些页面支持自动转屏
- (BOOL)shouldAutorotate{
    
    return YES;
}

// viewcontroller支持哪些转屏方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    // MoviePlayerViewController这个页面支持转屏方向
    return UIInterfaceOrientationMaskAllButUpsideDown;
    
}


-(void)dealloc
{
    NSLog(@"%s",__func__);
    
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
