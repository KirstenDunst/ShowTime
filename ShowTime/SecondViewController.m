//
//  SecondViewController.m
//  ShowTime
//
//  Created by CSX on 2017/6/7.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//

#import "SecondViewController.h"
#import "SecondViewControllerOne.h"
//测试新的
#import "SecondViewControllerTwo.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *myCreateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    myCreateButton.frame = CGRectMake(0, 200, 100, 100);
    [myCreateButton setBackgroundColor:[UIColor redColor]];
    [myCreateButton setTitle:@"Choose" forState:UIControlStateNormal];
    [myCreateButton addTarget:self action:@selector(buttonChoose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:myCreateButton];
    
}
- (void)buttonChoose:(UIButton *)sender{
    
//    SecondViewControllerOne *oneVC = [[SecondViewControllerOne alloc]init];
//    [oneVC SetMoiveSource:[NSURL URLWithString:@"rtmp://live.hkstv.hk.lxdns.com/live/hks"]];
//    [self.navigationController pushViewController:oneVC animated:YES];
    
    
    //测试新的
    SecondViewControllerTwo *twoVC = [[SecondViewControllerTwo alloc]init];
    [twoVC SetMoiveSource:[NSURL URLWithString:@"rtmp://live.hkstv.hk.lxdns.com/live/hks"]];
    [self.navigationController pushViewController:twoVC animated:YES];
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
