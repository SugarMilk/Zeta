//
//  AppDelegate.m
//  Zeta
//
//  Created by GOOT on 16/3/21.
//  Copyright © 2016年 GOOT. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate () <XTPageViewControllerDataSource> {
    NSInteger _numberOfPages;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self checkAccount];
    
    GTLeftViewCtrl *left        = [[GTLeftViewCtrl alloc] init];
    
    _numberOfPages = 3;
    XTPageViewController *page = [[XTPageViewController alloc] initWithTabBarStyle:XTTabBarStyleCursorUnderline];
//    page.tabBarBackgroundColor = [UIColor yellowColor]; // 背景颜色
    page.tabBarCursorColor = RGBColor(18, 26, 42);        // 浮动横条颜色
//    page.tabBarTitleColorNormal = [UIColor blueColor];  // 文字正常颜色
    page.tabBarTitleColorSelected = RGBColor(18, 26, 42);   // 文字选中颜色
    [page setDataSource:self];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:page];
    [nav.navigationBar setBarTintColor:RGBColor(18, 26, 42)];
    [nav.navigationBar setTranslucent:NO];
    [nav.navigationBar setTintColor:RGBColor(246, 245, 236)];
    
    _ddMenu                     = [[DDMenuController alloc] init];
    [_ddMenu setLeftViewController:left];
    [_ddMenu setRootViewController:nav];
    
    [self.window makeKeyAndVisible];
    [self.window setRootViewController:_ddMenu];
    [self.window setBackgroundColor:GWhiteColor];
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    // 设置状态栏的字体颜色模式
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UIImageView *titleImageView = [[UIImageView alloc] init];
    [titleImageView setFrame:CGRectMake(0, 0, 97, 22)];
    [titleImageView setImage:[UIImage imageNamed:@"zetadata"]];
    [page.navigationItem setTitleView:titleImageView];
    
    return YES;
}

- (void)checkAccount
{
    if ([[GTAccountManager sharedManager] isLogined]) {
        GTCustomer *currentUser  = [[GTAccountManager sharedManager] currentUser];
        
        NSDictionary *params = @{@"act":@"signin",
                                 @"user_name":currentUser.user_name,
                                 @"password" :currentUser.password};
        
        [GTURLSession sessionWithString:@"check_login" method:POST params:params response:^(id responseObject) {
            if ([responseObject[@"code"] isEqualToString:@"200"]) {
                NSDictionary *userInfo = responseObject[@"data"];
                
                GTCustomer *user = [[GTCustomer alloc] init];
                [user setPassword:currentUser.password];
                [user setValuesForKeysWithDictionary:userInfo];
                [[GTAccountManager sharedManager] setCurrentUser:user];
                
                NSLog(@"已经登录");
            } else {
                [[GTAccountManager sharedManager] resetUser];
                
                NSLog(@"登录失败，密码可能被修改，注销本地保存的账号！");
            }
        } error:^(id error) {
            ERROR(YES, error);
        }];
    } else {NSLog(@"尚未登录");}
}

- (NSInteger)numberOfPages {
    return _numberOfPages;
}

- (NSString*)titleOfPage:(NSInteger)page {
    
    switch (page) {
        case 0:
            return @"首页";
            break;
        case 1:
            return @"位置";
            break;
            
        default:
            return @"项目";
            break;
    }
}

- (UIViewController*)constrollerOfPage:(NSInteger)page {
    
    switch (page) {
        case 0:
            return [[GTIndexViewCtrl alloc] init];
            break;
        case 1:
            return [[GTLocationViewCtrl alloc] init];
            break;
        default:
            return [[GTProjectViewCtrl alloc] init];
            break;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
