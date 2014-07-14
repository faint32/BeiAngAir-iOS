//
//  BLAppDelegate.m
//  TCLAir
//
//  Created by yang on 4/11/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLAppDelegate.h"
#import "BLDeviceListViewController.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "BLNetwork.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <CommonCrypto/CommonDigest.h>
#import "SBJson.h"
#import <AVFoundation/AVFoundation.h>

@interface BLAppDelegate () <CLLocationManagerDelegate, MKMapViewDelegate>
{
    dispatch_queue_t httpQueue;
    dispatch_queue_t cityQueue;
    dispatch_queue_t networkQueue;
    int countAirQuality;
}

@property (nonatomic, strong) CLLocationManager *locManager;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;
//@property (nonatomic, strong) NSTimer *refreshLocation;
@property (nonatomic, strong) BLNetwork *network;
@end

@implementation BLAppDelegate


- (void)dealloc
{
    [super dealloc];
    dispatch_release(httpQueue);
    dispatch_release(cityQueue);
    dispatch_release(networkQueue);
}

- (void)createSharedDataFolders
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    
    NSString *directory = [documentsDirectory stringByAppendingPathComponent:@"SharedData/DeviceIcon/"];
    if ([fileManager fileExistsAtPath:directory] == NO)
    {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error)
        {
            NSLog(@"创建目录:%@ 失败:%@", directory, [error localizedDescription]);
        }
    }
}

- (void)initVariable
{
    _latitude = 0.0f;
    _longitude = 0.0f;
    _airQualityInfoClass = [[ClassAirQualityInfo alloc] init];
    /*Init network library*/
    _network = [[BLNetwork alloc] init];
    httpQueue = dispatch_queue_create("BLAppDelegateHttpQueue", DISPATCH_QUEUE_SERIAL);
    cityQueue = dispatch_queue_create("BLAppDelegateCityQueue", DISPATCH_QUEUE_SERIAL);
    networkQueue = dispatch_queue_create("BLAppDelegateNetworkQueue", DISPATCH_QUEUE_SERIAL);

    _locManager = [[CLLocationManager alloc] init];
    [_locManager setDelegate:self];
    [_locManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [_locManager setDistanceFilter:500.0f];
    [_locManager startUpdatingLocation];
    countAirQuality = 0;
    
    dispatch_async(networkQueue, ^{
		NSString *license = @"+Y3Y41U+V0tMiadtlZIbLmbFAUyNEQnpQaUHLqDJz7Xlcfks6IXYFkKT7/yKy4e8RCK6EtXcIz9NIfzDPgxK5be3RdBxHkaKwzhvA3ew4jM/D/Md2Bk=";
		NSString *typeLicense = @"B2w12IIQC+pidbD8IOavKTfjpeGbMVRubwNdGEbIn5j43nHKuwgx+/UoASwbcEEM";
		NSDictionary *dictionary = [NSDictionary dictionaryNetworkInitWithLicense:license typeLicense:typeLicense];
        NSData *sendData = [dictionary JSONData];
        NSData *response = [_network requestDispatch:sendData];
        int code = [[[response objectFromJSONData] objectForKey:@"code"] intValue];
        NSString *msg = [[response objectFromJSONData] objectForKey:@"msg"];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(code != 0)
            {
                NSString *title = NSLocalizedString(@"UIAlertViewtitleFailed", nil);
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"UIAlertViewOKButton", nil), nil];
                [alertView show];
            }
        });
    });
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self createSharedDataFolders];
    
    [self initVariable];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    BLDeviceListViewController *centerViewController = [[BLDeviceListViewController alloc] init];
    
    UINavigationController *centerNav = [[UINavigationController alloc] initWithRootViewController:centerViewController];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:centerNav];

	//TODO:先注释掉，影响我听歌了
    //加上代码后，如果你从音乐播放器切换到你的app，你会发现音乐播放器停止播放了。
//    NSError *setCategoryErr = nil;
//    NSError *activationErr  = nil;
//    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &setCategoryErr];
//    [[AVAudioSession sharedInstance] setActive: YES error: &activationErr];
	
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    UIApplication *app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - CLLocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //判断如果有数据则中断定位
    @synchronized(_airQualityInfoClass)
    {
        if(_airQualityInfoClass.weather.length > 0)
        {
            [manager stopUpdatingLocation];
            return;
        }
    }
    _geocoder = [[CLGeocoder alloc] init];
    [_geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil && [placemarks count] > 0)
        {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            _latitude = newLocation.coordinate.latitude;
            _longitude = newLocation.coordinate.longitude;
            NSLog(@"_latitude = %f",_latitude);
            NSLog(@"_longitude = %f",_longitude);
            //解析“lat:39.983424, l
            @synchronized(_airQualityInfoClass)
            {
                //城市名称
                _airQualityInfoClass.cityName = [[[placemark.addressDictionary objectForKey:@"City"] componentsSeparatedByString:@"市"] objectAtIndex:0];
                //城市code
                _airQualityInfoClass.cityCode = [[[NSString citiesCodeString] objectFromJSONString] objectForKey:[[_airQualityInfoClass.cityName componentsSeparatedByString:@"市"] objectAtIndex:0]];
                NSLog(@"cityCode = %d",_airQualityInfoClass.cityCode.length);
                //如果名称不相同则一般为英文
                //取得空气质量
                if(_airQualityInfoClass.cityCode.length > 0)
                {
                    if(_airQualityInfoClass.weather.length > 0)
                    {
                        [manager stopUpdatingLocation];
                        return;
                    }
                    //定时
					
//                    _refreshLocation = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(getWeather:) userInfo:nil repeats:YES];
//                    [_refreshLocation fire];
                }
                else
                {
                    //定时
//                    _refreshLocation = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(getCityInfo) userInfo:nil repeats:YES];
//                    [_refreshLocation fire];
                    NSLog(@"_airQualityInfoClass.cityName = %@",_airQualityInfoClass.cityName);
                }
            }
        }
        else if (error == nil && [placemarks count] == 0)
        {
            NSLog(@"No results were returned.");
        }
        else if (error != nil)
        {
            NSLog(@"An error occurred = %@", error);
        }
    }];
    [manager stopUpdatingLocation];
}

-(void)getCityInfo
{
    dispatch_async(cityQueue, ^{
        //百度接口取得地图上面的点
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.map.baidu.com/geocoder?output=json&location=%f,%f&key=37492c0ee6f924cb5e934fa08c6b1676",_latitude,_longitude]];
        NSError *error=nil;
        NSString *jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        SBJsonParser *parser = [[SBJsonParser alloc]init];
        NSDictionary *rootDic = [parser objectWithString:jsonString error:&error];
        NSDictionary *weatherInfo = [rootDic objectForKey:@"result"];
        @synchronized(_airQualityInfoClass)
        {
            _airQualityInfoClass.cityName = [[[[weatherInfo objectForKey:@"addressComponent"] objectForKey:@"city"] componentsSeparatedByString:@"市"] objectAtIndex:0];
            //城市code
            _airQualityInfoClass.cityCode = [[[NSString citiesCodeString] objectFromJSONString] objectForKey:[[_airQualityInfoClass.cityName componentsSeparatedByString:@"市"] objectAtIndex:0]];
            if(_airQualityInfoClass.cityCode.length > 0)
            {
                //定时
//                _refreshLocation = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(getWeather:) userInfo:nil repeats:YES];
//                [_refreshLocation fire];
            }
        }
    });
}

//天气接口
- (void)getWeather:(NSTimer *)timer
{
    dispatch_async(httpQueue, ^{
        @synchronized(_airQualityInfoClass)
        {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://tqapi.mobile.360.cn/app/meizu/city/%@",_airQualityInfoClass.cityCode]];
            NSError *error=nil;
            NSString *jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
            SBJsonParser *parser = [[SBJsonParser alloc]init];
            NSDictionary *rootDic = [parser objectWithString:jsonString error:&error];
            NSDictionary *weatherInfo = [rootDic objectForKey:@"pm25"];
            //空气质量
            NSString *tmp =  [NSString stringWithFormat:@"%@",[weatherInfo objectForKey:@"quality"]];
            if(tmp.length == 0 || [tmp isEqual:@"(null)"])
                _airQualityInfoClass.airQualityString = @"" ;
            else
                _airQualityInfoClass.airQualityString = tmp ;
            //温度
            NSMutableArray *dayArray = [[NSMutableArray alloc] init];
            NSMutableArray *nightArray = [[NSMutableArray alloc] init];
            //温度最低
            dayArray = [[[rootDic objectForKey:@"weather"][0] objectForKey:@"info"] objectForKey:@"night"];
            //温度最高
            nightArray = [[[rootDic objectForKey:@"weather"][0] objectForKey:@"info"] objectForKey:@"day"];
            //空气质量等级
            if([NSString stringWithFormat:@"%@",[weatherInfo objectForKey:@"level"]].length > 0)
                _airQualityInfoClass.airQualityLevel =[NSString stringWithFormat:@"%@",[weatherInfo objectForKey:@"level"]];
            else
                _airQualityInfoClass.airQualityLevel = @"";
            //温度
            NSString *tmpDay =  dayArray[2];
            //天气
            _airQualityInfoClass.weather = dayArray[1];
            NSString *tmpNight =  nightArray[2];
            if(tmpDay.length == 0 || tmpNight.length == 0 || [tmpDay isEqual:@"(null)"] || [tmpNight isEqual:@"(null)"])
                _airQualityInfoClass.temperateStrings = @"" ;
            else
                _airQualityInfoClass.temperateStrings = [NSString stringWithFormat:@"%@℃~%@℃",tmpDay,tmpNight] ;
            NSLog(@"_temperateStrings = %@",_airQualityInfoClass.temperateStrings);
            NSLog(@"_temperateStrings = %d",_airQualityInfoClass.temperateStrings.length);
            if(_airQualityInfoClass.temperateStrings.length > 0)
            {
//                [_refreshLocation invalidate];
            }
        }
    });
}
@end
