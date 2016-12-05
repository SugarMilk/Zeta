//
//  GTLocationViewCtrl.m
//  Zeta
//
//  Created by GOOT on 16/3/23.
//  Copyright © 2016年 GOOT. All rights reserved.
//

#import "GTLocationViewCtrl.h"

@interface GTLocationViewCtrl () <UITableViewDataSource, UITableViewDelegate, GTLocationViewCellDelegate, MAMapViewDelegate, AMapSearchDelegate>
{
    MAMapView       *_mapView;
    AMapSearchAPI   *_search;
    CLLocation      *_currentLocation;
    
    UIButton        *_locationButton;
    
    
    UIImageView     *_imageView;
    
    GTLocationViewCell *_showedCell;       // 已经被显示下拉菜单的单元格
    NSIndexPath     *_showedCellIndex;  // 已经被显示下拉菜单的单元格的索引
    
    NSMutableArray  *_dataSource;
}

@property (nonatomic, retain) UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *backMapView;

@end

@implementation GTLocationViewCtrl

#pragma mark - request
- (void)startRequestData
{
    _dataSource = [NSMutableArray array];
    
    [GTURLSession sessionWithString:@"map" method:GET params:@{} response:^(id responseObject) {
        
        if ([responseObject[@"code"] isEqualToString:@"200"]) {
            NSDictionary *locations = responseObject[@"data"];
            
            for (NSDictionary *location in locations) {
                GTLocationModel *loc = [[GTLocationModel alloc] init];
                [loc setValuesForKeysWithDictionary:location];
                if (loc.latitude.length > 0 && loc.longitude.length > 0) {
                    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([loc.latitude doubleValue], [loc.longitude doubleValue]);
                    int distance = [self distanceWithPoint:coordinate];
                    loc.distance = distance;
                } else {
                    loc.distance = 100000000000000;
                }
                [_dataSource addObject:loc];
            }
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
            NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
            [_dataSource sortUsingDescriptors:sortDescriptors];
            
            int i = 0;
            NSArray *tempArray = [NSArray arrayWithArray:_dataSource];
            for (GTLocationModel *loc in tempArray) {
                if ([loc.user_name isEqualToString:@"苏州泽它网络科技有限公司"]) {
                    [_dataSource removeObjectAtIndex:i];
                    [_dataSource insertObject:loc atIndex:0];
                }
                i++;
            }
            
//            [_dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                GTLocationModel *loc = obj;
//                if ([loc.user_name isEqualToString:@"苏州泽它网络科技有限公司"]) {
//                    NSLog(@"#address:  %@", loc.address);
//                    *stop = YES;
//                }
//            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
        }
    } error:^(id error) {
        ERROR(YES, error);
    }];
}

#pragma mark - init
- (void)initWithTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 200, screenW, screenH - 64 - 44 - 200) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(30, 0, 0, 0);
    [self.view addSubview:_tableView];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)initWithAMapView
{
    [MAMapServices sharedServices].apiKey = AMapKey;

    _mapView = [[MAMapView alloc] initWithFrame:_backMapView.bounds];
    _mapView.showsUserLocation = YES;
    _mapView.showsCompass = NO;
    _mapView.showsScale = NO;
    _mapView.delegate = self;
    [_backMapView addSubview:_mapView];
    
    [_mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
    
    _locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_locationButton setFrame:CGRectMake(CGRectGetWidth(_mapView.bounds) - 40 - 20, CGRectGetHeight(_mapView.bounds) - 40 - 20, 40, 40)];
    [_locationButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin];
    [_locationButton setBackgroundColor:[UIColor whiteColor]];
    [_locationButton setImage:[UIImage imageNamed:@"location_yes"] forState:UIControlStateNormal];
    [_locationButton addTarget:self action:@selector(locateAction) forControlEvents:UIControlEventTouchUpInside];
    [_locationButton.layer setCornerRadius:5];
    [_mapView addSubview:_locationButton];
}

- (void)locateAction
{
    /**
     *  4. 设置定位模式
     *  MAUserTrackingModeNone：仅在地图上显示，不跟随用户位置。
     *  MAUserTrackingModeFollow：跟随用户位置移动，并将定位点设置成地图中心点。
     *  MAUserTrackingModeFollowWithHeading：跟随用户的位置和角度移动。
     */
    if (_mapView.userTrackingMode != MAUserTrackingModeFollow) {
        [_mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
    }
}

- (void)initWithAMapViewSearch
{
    [[AMapSearchServices sharedServices] setApiKey:AMapKey];
    
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
}

#pragma mark - action

- (void)tapAction:(UITapGestureRecognizer *)tap
{
    _imageView = (UIImageView *)tap.view;
    
    CGFloat y = _tableView.frame.origin.y;
    
    if (y == 0) {
        _imageView.transform = CGAffineTransformMakeRotation(0);
        [UIView animateWithDuration:0.25 animations:^{
            [_tableView setFrame:CGRectMake(0, 200, screenW, screenH - 64 - 44 - 200)];
        }];
    } else {
        _imageView.transform = CGAffineTransformMakeRotation(M_PI);
        [UIView animateWithDuration:0.25 animations:^{
            [_tableView setFrame:self.view.bounds];
        }];
    }
}

/**
 *  逆地理编码的搜索请求
 */
- (void)reGeoAction
{
    if (_currentLocation) {
        AMapReGeocodeSearchRequest *request = [[AMapReGeocodeSearchRequest alloc] init];
        [request setLocation:[AMapGeoPoint locationWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude]];
        [_search AMapReGoecodeSearch:request];
    }
}

#pragma mark - amap deleage
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    NSString *title = response.regeocode.addressComponent.city;
    
    if (title.length == 0) {
        title = response.regeocode.addressComponent.province;
    }
    
    _mapView.userLocation.title = title;
    _mapView.userLocation.subtitle = response.regeocode.formattedAddress;
}

/**
 *  位置更新时调用的方法
 */
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    
    if (updatingLocation) {
//        NSLog(@"当前位置latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
//        NSLog(@"当前位置：%@", userLocation.location);
        _currentLocation = [userLocation.location copy];
//        _mapView.centerCoordinate = _currentLocation.coordinate; // 地图位置居中显示
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [_tableView reloadData];
        });
    }
    
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self startRequestData];
    });
}

/**
 *  选中定位的annotation时进行逆地理编码查询
 */
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[MAUserLocation class]]) {
        [self reGeoAction];
    }
}

/**
 *  用户定位模式被改变时调用的方法
 */
- (void)mapView:(MAMapView *)mapView didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated
{
    /**
     *  5. 修改定位按钮状态
     */
    if (mode == MAUserTrackingModeNone) {
        [_locationButton setImage:[UIImage imageNamed:@"location_no"] forState:UIControlStateNormal];
    } else {
        [_locationButton setImage:[UIImage imageNamed:@"location_yes"] forState:UIControlStateNormal];
    }
}

#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"GTLocationViewCell";
    
    GTLocationViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"GTLocationViewCell" owner:nil options:nil][0];
    }
    
    cell.delegate   = self;
    cell.button.tag = indexPath.row;
    
    if (_dataSource.count > 0) {
        
        GTLocationModel *location = _dataSource[indexPath.row];
        
        cell.location = location;
        
//        NSLog(@"第%ld行 #%@   la: %@   lo: %@", indexPath.row, location.user_name, location.latitude, location.longitude);

        if (location.latitude.length > 0 && location.longitude.length > 0) {
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([location.latitude doubleValue], [location.longitude doubleValue]);
            
            int distance = [self distanceWithPoint:coordinate];
            
            location.distance = distance;
            
//            NSLog(@"第%ld行 #%@ 相距： %d", indexPath.row, location.user_name, distance);
            
            if (distance != 0) {
                
                if (distance < 10000) {
                    cell.distanceLabel.text = [NSString stringWithFormat:@"%dm", distance];
                } else if (distance < 10000000) {
                    cell.distanceLabel.text = [NSString stringWithFormat:@"%dkm", distance/1000];
                } else if (distance > 10000000) {
                    cell.distanceLabel.text = [NSString stringWithFormat:@"%dMm", distance/1000000];
                }
                
            }
        } else {
            cell.distanceLabel.text = @"未提供";
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((_showedCell != nil) && (_showedCell.isShowMenuView = YES) && (_showedCellIndex.row == indexPath.row)) {
        return 130;
    }
    return 80;
}

// 全屏显示或部分显示表格视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    _imageView = [[UIImageView alloc] init];
    [_imageView setFrame:CGRectMake(0, 0, screenW, 30)];
    [_imageView setBackgroundColor:WAColor(0.98, 1)];
    [_imageView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [_imageView addGestureRecognizer:tap];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    CGFloat x = screenW / 2 - 18 / 2;
    [imageView setFrame:CGRectMake(x, 6, 18, 18)];
    [imageView setImage:[UIImage imageNamed:@"up"]];
    [_imageView addSubview:imageView];
    
    return _imageView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
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

#pragma mark - locationViewCell delegate
- (void)locationViewCell:(GTLocationViewCell *)cell didShowMenuViewWithButton:(UIButton *)button
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

- (void)locationViewCell:(GTLocationViewCell *)cell didClickedNavigateButton:(UIButton *)button
{
    GTRouteViewController *route = [[GTRouteViewController alloc] init];
    
    route.location = _dataSource[cell.button.tag];
    
    [self.navigationController pushViewController:route animated:YES];
}

- (void)locationViewCell:(GTLocationViewCell *)cell didSelectMentItemAtIndex:(NSInteger)index
{
    
}

#pragma mark - tool
- (CLLocationDistance)distanceWithPoint:(CLLocationCoordinate2D) coordinate
{
    if (_currentLocation) {
        //1.将两个经纬度点转成投影点
        
        MAMapPoint point1 = MAMapPointForCoordinate(_currentLocation.coordinate);
        
        MAMapPoint point2 = MAMapPointForCoordinate(coordinate);
        
        //2.计算距离
        
        CLLocationDistance distance = MAMetersBetweenMapPoints(point1,point2);
        
        return distance;
    }
    return 0;
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initWithTableView];
    [self startRequestData];
    [self initWithAMapView];
    [self initWithAMapViewSearch];
}

- (void)viewDidLayoutSubviews
{
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

@end
