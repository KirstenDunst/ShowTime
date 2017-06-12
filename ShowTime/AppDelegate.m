//
//  AppDelegate.m
//  ShowTime
//
//  Created by CSX on 2017/6/9.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewControllerFirst.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    
    //1.创建Window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
    //a.初始化一个tabBar控制器
    UITabBarController *tb=[[UITabBarController alloc]init];
    //设置控制器为Window的根控制器
    self.window.rootViewController=tb;
    
    //b.创建子控制器
    ViewControllerFirst *c1=[[ViewControllerFirst alloc]init];
    UINavigationController *nav1 = [[UINavigationController alloc]initWithRootViewController:c1];
    //    nav1.view.backgroundColor=[UIColor whiteColor];
    nav1.tabBarItem.title=@"消息";
    nav1.tabBarItem.image=[UIImage imageNamed:@"tab_recent_nor"];
    nav1.tabBarItem.badgeValue=@"123";//tabbar的右上角显示样式
    
    SecondViewController *c2=[[SecondViewController alloc]init];
    UINavigationController *nav2 = [[UINavigationController alloc]initWithRootViewController:c2];
    //    nav2.view.backgroundColor=[UIColor brownColor];
    nav2.tabBarItem.title=@"联系人";
    nav2.tabBarItem.image=[UIImage imageNamed:@"tab_buddy_nor"];
    
    ThirdViewController *c3 = [[ThirdViewController alloc]init];
    UINavigationController *nav3 = [[UINavigationController alloc]initWithRootViewController:c3];
    //    nav3.view.backgroundColor = [UIColor orangeColor];
    nav3.tabBarItem.title = @"本地播";
    nav3.tabBarItem.image = [UIImage imageNamed:@"tab_play_side"];
    
    tb.viewControllers=@[nav1,nav2,nav3];
    
    //2.设置Window为主窗口并显示出来
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
