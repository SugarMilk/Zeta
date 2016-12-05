//
//  GTIndexViewCtrl.m
//  Zeta
//
//  Created by GOOT on 16/3/23.
//  Copyright © 2016年 GOOT. All rights reserved.
//

#import "GTIndexViewCtrl.h"

@interface GTIndexViewCtrl ()<UITableViewDataSource, UITableViewDelegate, GTIndexViewCellDelegate>
{
    GTIndexViewCell *_showedCell;       // 已经被显示下拉菜单的单元格
    
    NSIndexPath *_showedCellIndex;      // 已经被显示下拉菜单的单元格的索引
    
    NSMutableArray *_dataSource;
    
    int _currentPage;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation GTIndexViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Bundle Id : %@", [[NSBundle mainBundle] bundleIdentifier]);
    
    _dataSource                = [NSMutableArray array];
    _tableView.tableFooterView = [UIView new];
    _tableView.mj_header       = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        _currentPage = 1;
        [_dataSource removeAllObjects];
        [self dataSourceAndRefreshTableView];
        
    }];
    
    _currentPage = 1;
    [self dataSourceAndRefreshTableView];
}

- (void)dataSourceAndRefreshTableView
{
    NSDictionary *params = @{@"page":@(_currentPage).stringValue,
                             @"page_size":@"5"};
    
    [GTURLSession sessionWithString:@"index" method:GET params:params response:^(id responseObject) {
        
        if ([responseObject[@"code"] isEqualToString:@"200"]) {
            NSDictionary *news = responseObject[@"data"];
            
            for (NSDictionary *new in news) {
                GTIndexModel *index = [[GTIndexModel alloc] init];
                [index setValuesForKeysWithDictionary:new];
                [_dataSource addObject:index];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
                [_tableView.mj_header endRefreshing];
            });
        }
    } error:^(id error) {
        ERROR(YES, error);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"GTIndexViewCell";
    
    GTIndexViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"GTIndexViewCell" owner:nil options:nil][0];
    }
    
    cell.delegate   = self;
    cell.button.tag = indexPath.row;
    
    cell.index = _dataSource[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((_showedCell != nil) && (_showedCell.isShowMenuView = YES) && (_showedCellIndex.row == indexPath.row)) {
        return 220;
    }
    return 140;
}

-(void)viewDidLayoutSubviews
{
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
}

- (void)indexViewCell:(GTIndexViewCell *)cell didShowMenuViewWithButton:(UIButton *)button
{
    NSIndexPath *openedIndexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
    
    if ((_showedCell != nil) && (_showedCell.isShowMenuView = YES) && (_showedCellIndex.row == openedIndexPath.row)) {
        _showedCell      = nil;
        [_tableView reloadRowsAtIndexPaths:@[_showedCellIndex] withRowAnimation:UITableViewRowAnimationNone];
        _showedCellIndex = nil;
        return;
    }
    
    // 刷新新的Cell
    
    _showedCell      = cell;
    _showedCellIndex = openedIndexPath;
    
    [_tableView reloadRowsAtIndexPaths:@[_showedCellIndex] withRowAnimation:UITableViewRowAnimationNone];
    [_tableView scrollToRowAtIndexPath:_showedCellIndex atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

- (void)indexViewCell:(GTIndexViewCell *)cell didSelectMentItemAtIndex:(NSInteger)index
{
//    GTLoginViewCtrl *l = [[GTLoginViewCtrl alloc] init];
//    [self.navigationController pushViewController:l animated:YES];
}

@end
