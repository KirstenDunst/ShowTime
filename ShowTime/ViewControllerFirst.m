//
//  ViewControllerFirst.m
//  ShowTime
//
//  Created by CSX on 2017/6/8.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//

#import "ViewControllerFirst.h"
#import "AlivcLiveViewController.h"
#import "ViewControllerOne.h"

@interface ViewControllerFirst ()

@end

@implementation ViewControllerFirst

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *myCreateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    myCreateButton.frame = CGRectMake(0, 100, 100, 100);
    [myCreateButton setBackgroundColor:[UIColor cyanColor]];
    [myCreateButton setTitle:@"Choose" forState:UIControlStateNormal];
    [myCreateButton addTarget:self action:@selector(buttonChoose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:myCreateButton];
    
}

- (void)buttonChoose:(UIButton *)sender{
    
//    AlivcLiveViewController *live = [[AlivcLiveViewController alloc] initWithNibName:@"AlivcLiveViewController" bundle:nil url:@"rtmp://" isScreenHorizontal:NO];
    
    ViewControllerOne *live = [[ViewControllerOne alloc]initWithUrl:@"rtmp://" isScreenHorizontal:YES];
    
    [self.navigationController pushViewController:live animated:YES];
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
