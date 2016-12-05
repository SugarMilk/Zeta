//
//  GTProjectRightViewCtrl.m
//  Zeta
//
//  Created by GOOT on 16/3/26.
//  Copyright © 2016年 GOOT. All rights reserved.
//

#import "GTProjectRightViewCtrl.h"

@interface GTProjectRightViewCtrl () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *_dataSource;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation GTProjectRightViewCtrl

- (void)viewDidLoad
{
    //    logOutNotify
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanView) name:@"logOutNotify" object:nil];
}

- (void)cleanView
{
    NSLog(@"用户退出登录%d%s", __LINE__, __FUNCTION__);
    
    [_dataSource removeAllObjects];
    [_tableView reloadData];
    _tableView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _tableView.hidden = NO;
    
    _dataSource = [NSMutableArray array];
    
    [_tableView setContentInset:UIEdgeInsetsMake(-31, 0, -17, 0)];
    
    GTAccountManager *mgr = [GTAccountManager sharedManager];
    
    if (!mgr.isLogined) {
        [_tableView setHidden:YES]; return;
    } else {
        [_tableView setHidden:NO];
    }
    
    NSDictionary *params = @{@"user_id":mgr.currentUser.user_id,
                             @"type":@"1"};
    
    [GTURLSession sessionWithString:@"personal" method:POST params:params response:^(id responseObject) {
        
        if ([responseObject[@"code"] isEqualToString:@"200"]) {
            NSDictionary *projects = responseObject[@"data"];
            
            for (NSDictionary *project in projects) {
                GTProductModel *proj = [[GTProductModel alloc] init];
                [proj setValuesForKeysWithDictionary:project];
                [_dataSource addObject:proj];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
        }
    } error:^(id error) {
        ERROR(YES, error);
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"GTProjectRightViewCell";
    
    GTProjectRightViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"GTProjectRightViewCell" owner:nil options:nil][0];
    }
    
    if (_dataSource.count > 0) {
        cell.product = _dataSource[indexPath.section];
    }
    
    return cell;
}

@end
