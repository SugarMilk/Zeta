//
//  GTRouteViewController.m
//  Zeta
//
//  Created by GOOT on 16/4/1.
//  Copyright © 2016年 GOOT. All rights reserved.
//

#import "GTRouteViewController.h"

@interface GTRouteViewController () <MAMapViewDelegate, AMapSearchDelegate, UIGestureRecognizerDelegate>
{
    MAMapView       *_mapView;
    AMapSearchAPI   *_search;
    CLLocation      *_currentLocation;
    
    UILongPressGestureRecognizer *_longPressGesture;
    
    MAPointAnnotation *_destinationPoint;
    
    NSArray *_pathPolylines;
}

@property (weak, nonatomic) IBOutlet UIView *backMapView;

@end

@implementation GTRouteViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initWithAMapView];
    [self initWithAMapViewSearch];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self handleLongPress:nil];
    });
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
}

- (void)initWithAMapViewSearch
{
    [[AMapSearchServices sharedServices] setApiKey:AMapKey];
    
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    
    _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    
    _longPressGesture.delegate = self;
    
    [_mapView addGestureRecognizer:_longPressGesture];
    
    _longPressGesture.minimumPressDuration = 1.0;//1.0秒响应方法
    _longPressGesture.allowableMovement = 50.0;
    
}

- (void)pathAction
{
    NSLog(@"%@ - %@ - %@", _search, _currentLocation, _destinationPoint);
    
    
    if (_destinationPoint == nil)
    {
        NSLog(@"path search failed");
        return;
    }
    
    AMapDrivingRouteSearchRequest *request = [[AMapDrivingRouteSearchRequest alloc] init];
    
    request.origin = [AMapGeoPoint locationWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude];
    
    request.destination = [AMapGeoPoint locationWithLatitude:_destinationPoint.coordinate.latitude longitude:_destinationPoint.coordinate.longitude];
    
    [_search AMapDrivingRouteSearch:request];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture
{
//    if (gesture.state == UIGestureRecognizerStateBegan)
//    {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([_location.latitude doubleValue], [_location.longitude doubleValue]);
        
        if (_destinationPoint != nil)
        {
            [_mapView removeAnnotation:_destinationPoint];
            
            _destinationPoint = nil;
        }
        
        _destinationPoint            = [[MAPointAnnotation alloc] init];
        _destinationPoint.coordinate = coordinate;
        _destinationPoint.title      = _location.user_name;
        _destinationPoint.subtitle   = _location.address;
    
        [_mapView addAnnotation:_destinationPoint];
        
        [self pathAction];
//    }
}

#pragma mark - gestureRecognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - amap delegate

- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
{
    if (response.count > 0) {
        [_mapView removeOverlays:_pathPolylines];
        _pathPolylines = nil;
        
        _pathPolylines = [self polylinesForPath:response.route.paths[0]];
        [_mapView addOverlays:_pathPolylines];
        
        [_mapView showAnnotations:@[_destinationPoint, _mapView.userLocation] animated:YES];
    }
}

- (NSArray *)polylinesForPath:(AMapPath *)path
{
    if (path == nil || path.steps.count == 0)
    {
        return nil;
    }
    
    NSMutableArray *polylines = [NSMutableArray array];
    
    [path.steps enumerateObjectsUsingBlock:^(AMapStep *step, NSUInteger idx, BOOL *stop) {
        
        NSUInteger count = 0;
        CLLocationCoordinate2D *coordinates = [self coordinatesForString:step.polyline
                                                         coordinateCount:&count
                                                              parseToken:@";"];
        
        MAPolyline *polyline = [MAPolyline polylineWithCoordinates:coordinates count:count];
        [polylines addObject:polyline];
        
        free(coordinates), coordinates = NULL;
    }];
    
    return polylines;
}

- (CLLocationCoordinate2D *)coordinatesForString:(NSString *)string
                                 coordinateCount:(NSUInteger *)coordinateCount
                                      parseToken:(NSString *)token
{
    if (string == nil)
    {
        return NULL;
    }
    
    if (token == nil)
    {
        token = @",";
    }
    
    NSString *str = @"";
    if (![token isEqualToString:@","])
    {
        str = [string stringByReplacingOccurrencesOfString:token withString:@","];
    }
    
    else
    {
        str = [NSString stringWithString:string];
    }
    
    NSArray *components = [str componentsSeparatedByString:@","];
    NSUInteger count = [components count] / 2;
    if (coordinateCount != NULL)
    {
        *coordinateCount = count;
    }
    CLLocationCoordinate2D *coordinates = (CLLocationCoordinate2D*)malloc(count * sizeof(CLLocationCoordinate2D));
    
    for (int i = 0; i < count; i++)
    {
        coordinates[i].longitude = [[components objectAtIndex:2 * i]     doubleValue];
        coordinates[i].latitude  = [[components objectAtIndex:2 * i + 1] doubleValue];
    }
    
    return coordinates;
}

- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineView *polylineView = [[MAPolylineView alloc] initWithPolyline:overlay];
        
        polylineView.lineWidth   = 5;
        polylineView.strokeColor = [UIColor magentaColor];
        
        return polylineView;
    }
    
    return nil;
}

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
        
        NSLog(@"_currentLocation :  %@", _currentLocation);
    }
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

- (void)reGeoAction
{
    if (_currentLocation) {
        AMapReGeocodeSearchRequest *request = [[AMapReGeocodeSearchRequest alloc] init];
        [request setLocation:[AMapGeoPoint locationWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude]];
        [_search AMapReGoecodeSearch:request];
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if (annotation == _destinationPoint)
    {
        static NSString *identify = @"annatationIdentify";
        
        MAPinAnnotationView *annotationView = (MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identify];
        
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identify];
        }
        
        annotationView.canShowCallout = YES; // 弹出气泡
        
        annotationView.animatesDrop = YES;
        
        return annotationView;
    }
    return nil;
}

@end
