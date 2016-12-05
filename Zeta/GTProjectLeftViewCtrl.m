//
//  GTProjectLeftViewCtrl.m
//  Zeta
//
//  Created by GOOT on 16/3/26.
//  Copyright © 2016年 GOOT. All rights reserved.
//

#import "GTProjectLeftViewCtrl.h"

@interface GTProjectLeftViewCtrl () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *_dataSource;
    
    NSDictionary *_dic;
    
    int count;
    
    UILabel *customNameLabel;
    UILabel *finalPayLabel;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation GTProjectLeftViewCtrl

- (void)viewDidLoad
{
    //    logOutNotify
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanView) name:@"logOutNotify" object:nil];
}

- (void)cleanView
{
    NSLog(@"用户退出登录%d%s", __LINE__, __FUNCTION__);
    
    [customNameLabel removeFromSuperview];
    [finalPayLabel removeFromSuperview];
    
    [_dataSource removeAllObjects];
    [_tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self initControls];
    
    _dataSource = [NSMutableArray array];
    
    GTAccountManager *mgr = [GTAccountManager sharedManager];
    
    if (!mgr.isLogined) {
        [_tableView setHidden:YES]; return;
    } else {
        [_tableView setHidden:NO];
    }
    
    NSDictionary *params = @{@"user_id":mgr.currentUser.user_id,
                             @"type":@"0"};
    
    [GTURLSession sessionWithString:@"personal" method:POST params:params response:^(id responseObject) {
        
        if ([responseObject[@"code"] isEqualToString:@"200"]) {
            NSDictionary *projects = responseObject[@"data"];
            
            for (NSDictionary *project in projects) {
                
                GTProjectModel *proj = [[GTProjectModel alloc] init];
                [proj setValuesForKeysWithDictionary:project];
                
                NSDictionary *params2 = @{@"project_id":proj.id};
                
                [GTURLSession sessionWithString:@"phase" method:GET params:params2 response:^(id responseObject) {
                    if ([responseObject[@"code"] isEqualToString:@"200"]) {
                        NSDictionary *milestones = responseObject[@"data"];
                        
                        NSMutableArray *msDataSource = [NSMutableArray array];
                        
                        for (NSDictionary *milestone in milestones) {
                            GTMilestoneModel *ms = [[GTMilestoneModel alloc] init];
                            [ms setValuesForKeysWithDictionary:milestone];
                            [msDataSource addObject:ms];
                        }
                        proj.milestones = msDataSource;
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [_dataSource addObject:proj];
                            [_tableView reloadData];
                        });
                    }
                } error:^(id error) {
                    ERROR(YES, error);
                }];
            }
        } else {
//            finalPayLabel.hidden = YES;
        }
    } error:^(id error) {
        ERROR(YES, error);
    }];
}

- (void)initControls
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 80)];
    //    [headerView setBackgroundColor:GOrangeColor];
    [_tableView setTableHeaderView:headerView];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 30)];
    //    [footerView setBackgroundColor:GCyanColor];
    [_tableView setTableFooterView:footerView];
    
    CGFloat width = screenW - 2 * 30;
    
    customNameLabel = [[UILabel alloc] init];
    [customNameLabel setFrame:CGRectMake(20, 10, width, 20)];
    NSString *userName = [[[GTAccountManager sharedManager] currentUser] user_name];
    [customNameLabel setText:[NSString stringWithFormat:@"尊敬的 %@ 客户您好！", userName]];
    //    [customNameLabel setBackgroundColor:GRedColor];
    [headerView addSubview:customNameLabel];
    
    finalPayLabel = [[UILabel alloc] init];
    [finalPayLabel setFrame:CGRectMake(20, 35, width, 20)];
    [finalPayLabel setText:@"项目尾款金额："];
    //    [finalPayLabel setBackgroundColor:GGreenColor];
    [headerView addSubview:finalPayLabel];
//    finalPayLabel.hidden = YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_dataSource[section] milestones] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"GTMilestoneViewCell";
    
    GTMilestoneViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"GTMilestoneViewCell" owner:nil options:nil][0];
    }
    
    if (_dataSource.count > 0) {
        cell.milestone = [_dataSource[indexPath.section] milestones][indexPath.row];
    }
    
    return cell;
}




@end
