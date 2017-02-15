//
//  ViewController.m
//  YFLCoreLocation
//
//  Created by 杨丰林 on 17/2/16.
//  Copyright © 2017年 杨丰林. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>


@interface ViewController ()<CLLocationManagerDelegate,UIAlertViewDelegate>
//声明强引用避免对象被释放   定位管理者
@property (nonatomic, strong) CLLocationManager *mgr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //注意：使用模拟器模拟定位需要设置模拟器debug--location---cutomLocation--latitude(通常设置40,天朝位置)
    //2.成为CoreLocation管理者的代理监听获取到的位置
    self.mgr.delegate=self;
    //设置多久获取一次位置信息(500米后获取一次位置信息)
    //self.mgr.distanceFilter=500;(设置此属性后，位置信息不会持续更行)
    //设置获取位置的精确度
    /*
     kCLLocationAccuracyBestForNavigation      最佳导航
     kCLLocationAccuracyBest;                  最精准
     kCLLocationAccuracyNearestTenMeters;      10米
     kCLLocationAccuracyHundredMeters;         百米
     kCLLocationAccuracyKilometer;             千米
     kCLLocationAccuracyThreeKilometers;       3千米
     */
    self.mgr.desiredAccuracy=kCLLocationAccuracyNearestTenMeters;
    /*
     注意：
     1.iOS7只要开始定位，系统就会自动要求用户对你的应用程序授权，但是iOS8开始，想要定位必须先“自己主动”要求用户授权
     2.在iOS8中，不仅仅要请求授权(如下requestAlwaysAuthorization／requestWhenInUseAuthorization)，而且要在info.plist文件中配置一项属性才能弹出授权窗口
     3.请求授权之后，根据你请求授权方式的不同，在plist文件的配置也不一样（NSLocationWhenInUseUsageDescription允许在前台获取GPS的描述/NSLocationAlwaysUsageDescription,允许在后台获取GPS的描述）,如果请求授权的时候是requestAlwaysAuthorization授权，那么在plist文件中，添加NSLocationAlwaysUsageDescription,如果请求授权是requestWhenInUseAuthorization，那么在plist文件中，添加NSLocationWhenInUseDescription。
     */
    
    //判断是否是iOS8
    if ([[UIDevice currentDevice].systemVersion doubleValue] >=8.0)
    {
        NSLog(@"ios8");
        //主动要求用户打开定位授权,授权状态改变就会通知代理
        [self.mgr requestWhenInUseAuthorization];//请求前台和后台定位权限(退出程序和打开程序,权限大一点)
        //[self.mgr requestAlwaysAuthorization];//请求前台定位(程序出狱打开状态)
        
    }else
    {
        NSLog(@"ios7");
        //3.开始监听
        [self.mgr startUpdatingLocation];
    }
    //适配iOS9+
}


#pragma mark   --懒加载
-(CLLocationManager *)mgr
{
    if (!_mgr)
    {
        //创建一个管理者
        _mgr=[[CLLocationManager alloc]init];
    }
    return _mgr;
}

#pragma mark  ----CLLocationManagerDelegate代理方法

/**该方法调用频率很高，不断更新(一直不断的刷行位置可能造成电池的损耗)
 marager:出发事件的对象
 locations:获取到的位置
 **/
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSLog(@"%s",__func__);
    
    //如果想获取一次位置，可以获取一次位置后就停掉
    //[self.mgr stopUpdatingLocation];//(设置此属性后，位置信息只会更新一次,然后停止)
    /*
     // CLLocation
     location.coordinate; 坐标, 包含经纬度
     location.altitude; 设备海拔高度 单位是米
     location.course; 设置前进方向 0表示北 90东 180南 270西
     location.horizontalAccuracy; 水平精准度
     location.verticalAccuracy; 垂直精准度
     location.timestamp; 定位信息返回的时间
     location.speed; 设备移动速度 单位是米/秒, 适用于行车速度而不太适用于不行
     */
    //获取用户最后一次位置的信息
    CLLocation *location=[locations lastObject];
    //NSLog(@"%f---%f----%f",location.coordinate,location.altitude,location.speed);
    
    
    
    //此处locations存储了持续更新的位置坐标值，取最后一个值为最新位置，如果不想让其持续更新位置，则在此方法中获取到一个值之后让locationManager stopUpdatingLocation
    CLLocation *currentLocation = [locations lastObject];
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *array, NSError *error)
     {
         if (array.count > 0)
         {
             CLPlacemark *placemark = [array objectAtIndex:0];
             
             
             NSDictionary *test = [placemark addressDictionary];
             //  Country(国家)  State(城市)  SubLocality(区/县)
             
             //  Country(国家)  State(城市)  SubLocality(区/县)
             UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:[test objectForKey:@"Country"],[test objectForKey:@"State"],[test objectForKey:@"City"],[test objectForKey:@"SubLocality"],[test objectForKey:@"SubThoroughfare"],[test objectForKey:@"Thoroughfare"],[test objectForKey:@"Street"],[test objectForKey:@"Name"],nil];
             
             [alert show];
             
             //NSLog(@"%@",placemark);
             //NSLog(@"%@",placemark);//具体位置
             //获取城市
             NSString *city = placemark.locality;
             if (!city) {
                 //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                 city = placemark.administrativeArea;
             }
             
             NSLog(@"Dictionary:%@",placemark.addressDictionary);
             NSString *detaiAddress=[NSString stringWithFormat:@"%@:%@:%@--%@--%@",[placemark.addressDictionary valueForKey:@"CountryCode"],[placemark.addressDictionary valueForKey:@"Country"],[placemark.addressDictionary valueForKey:@"City"],[placemark.addressDictionary valueForKey:@"FormattedAddressLines"],[placemark.addressDictionary valueForKey:@"Name"]];
             
             NSArray *streetArr=[placemark.addressDictionary valueForKey:@"FormattedAddressLines"];
             
             NSLog(@"详细地址：%@",detaiAddress);
             NSLog(@"streetArr:%@",streetArr);
             
             //NSLog(@"city:-->%@",city);
             
             
             //[_locationCity replaceObjectAtIndex:0 withObject:city];
             //[_tableView reloadData];
             
             //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
             [manager stopUpdatingLocation];
         }else if (error == nil && [array count] == 0)
         {
             NSLog(@"No results were returned.");
         }else if (error != nil)
         {
             NSLog(@"An error occurred = %@", error);
         }
     }];
    
    
    
    
    
    
    
    
    
}
/*
 授权状态发生变化时候，开始调用
 manager: 出发事件的对象
 status:当前授权的状态
 
 */
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    /*
     用户从未选择过权限
     kCLAuthorizationStatusNotDetermined ,
     无法使用定位服务，该状态用户无法改变
     kCLAuthorizationStatusRestricted,
     用户拒绝使用定位服务，或者定位服务总开关出狱关闭状态
     kCLAuthorizationStatusDenied,
     用户允许程序无论何时都可以使用地理位置
     kCLAuthorizationStatusAuthorizedAlways
     用户同意程序在可见时使用地理位置
     kCLAuthorizationStatusAuthorizedWhenInUse
     已经授权（已经废弃不使用）
     kCLAuthorizationStatusAuthorized
     
     */
    
    if (status==kCLAuthorizationStatusNotDetermined)
    {
        NSLog(@"等待用户授权");
        
        //提示用户无法进行定位操作
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"当前城市定位不成功 ,请打开定位功能" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }else if (status==kCLAuthorizationStatusAuthorizedAlways ||
              status==kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        NSLog(@"授权成功");
        
        
        //已经授权成功的程序，不会重复多次弹出提示授权的窗口（可以改变bundle identifier调试）
        //iOS8授权成功后，开始定位
        
        [self.mgr startUpdatingLocation];
        
        
        
        //提示用户无法进行定位操作
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"用户定位成功" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
        
    }else
    {
        NSLog(@"授权失败");
        //提示用户无法进行定位操作
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"当前城市定位不成功 ,请打开定位功能" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
