//
//  ViewController.m
//  百度地图
//
//  Created by mac on 17/5/12.
//  Copyright © 2017年 cai. All rights reserved.
//

#import "ViewController.h"

#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件

#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件

#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件

#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>//引入云检索功能所有的头文件

#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件

#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>//引入计算工具所有的头文件

#import <BaiduMapAPI_Radar/BMKRadarComponent.h>//引入周边雷达功能所有的头文件

#import <BaiduMapAPI_Map/BMKMapView.h>//只引入所需的单个头文件

@interface ViewController ()<BMKMapViewDelegate, BMKPoiSearchDelegate>
{
    BMKMapView *_mapView;
    
    BMKPoiSearch *_searcher;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _mapView = [[BMKMapView alloc]init];
    self.view = _mapView;
    
    //切换为卫星图
//    _mapView.mapType = BMKMapTypeSatellite;
    
//    // 添加一个PointAnnotation
//    BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
//    CLLocationCoordinate2D coor;
//    coor.latitude = 39.915;
//    coor.longitude = 116.404;
//    annotation.coordinate = coor;
//    annotation.title = @"这里是北京";
//    [_mapView addAnnotation:annotation];
    
    //POI检索代码  延迟时间检索  因为有时未鉴权成功就去检索 会报错误码10
    [self performSelector:@selector(poiSearch) withObject:nil afterDelay:2];
    
    //设置地图显示层级  /// 地图比例尺级别，在手机上当前可使用的级别为3-21级  3最大  16比较合适
    [_mapView setZoomLevel:16];
}

//poi检索代码
- (void)poiSearch
{
    //初始化检索对象
    _searcher =[[BMKPoiSearch alloc]init];
    _searcher.delegate = self;
    //发起检索-- > 拼接参数
    BMKNearbySearchOption *option = [[BMKNearbySearchOption alloc]init];
    
    ///分页索引，可选，默认为0
    option.pageIndex = 0;
    ///分页数量，可选，默认为10，最多为50
    option.pageCapacity = 10;
    option.location = CLLocationCoordinate2DMake(39.915, 116.404);
    option.keyword = @"小吃";
    BOOL flag = [_searcher poiSearchNearBy:option];
    if(flag)
    {
        NSLog(@"周边检索发送成功");
    }
    else
    {
        NSLog(@"周边检索发送失败");
    }
    
}

//实现PoiSearchDeleage处理回调结果
- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPoiResult*)poiResultList errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        
        NSLog(@"成功");
        
        //添加大头针 给用户一个列表
        
        for (BMKPoiInfo *info in poiResultList.poiInfoList) {
            BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
            annotation.coordinate = info.pt;
            annotation.title = info.name;
            [_mapView addAnnotation:annotation];
        }
        
    }
    else if (error == BMK_SEARCH_AMBIGUOUS_KEYWORD){
        //当在设置城市未找到结果，但在其他城市找到结果时，回调建议检索城市列表
        // result.cityList;
        NSLog(@"起始点有歧义");
    } else {
        NSLog(@"抱歉，未找到结果 error: %zd", error);//有时成功 有时失败，BMK_SEARCH_PERMISSION_UNFINISHED,///还未完成鉴权，请在鉴权通过后重试
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    
    //不使用时将delegate设置为 nil
    _searcher.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
