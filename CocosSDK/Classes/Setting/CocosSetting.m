//
//  CocosSetting.m
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import "CocosSetting.h"

BOOL cocos_redirectNSlogToCachesFolder(NSString * path) {
    
    // If Xcode debugging has been connected, it will not be exported to the file
    if(isatty(STDOUT_FILENO)) {
        return NO;
    }
    
    // Have flag records been registered
    static BOOL sdk_did_set_log = NO;
    if (sdk_did_set_log) {
        return YES;
    }else {
        sdk_did_set_log = YES;
    }
    
    // create folder
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // Get a timestamp
    NSString *fileName = [NSString stringWithFormat:@"SYLingLog%f.log",[[NSDate date] timeIntervalSince1970]];
    
    // Create the output full path
    NSString *logFilePath = [path stringByAppendingPathComponent:fileName];
    
    // Delete existing files first
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    [defaultManager removeItemAtPath:logFilePath error:nil];
    
    // Enter log into file
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+", stdout); // printf Method
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+", stderr); // NSLog Method
    
    // Open Print Information
    UIDevice * currentDevice = [UIDevice currentDevice];
    //手机别名： 用户定义的名称  //设备名称  //手机系统版本 //手机型号
    NSLog(@"\n手机别名: %@\n设备名称: %@\n手机系统版本: %@\n手机型号: %@", [currentDevice name], [currentDevice systemName], [currentDevice systemVersion], [currentDevice model]);
    // 打印记录APP 信息
    NSLog(@"设置输出环境完毕 APP.info: \n%@\n\n\n",[NSBundle mainBundle].infoDictionary);
    
    return YES;
}

// 开启关闭 是否打印
static BOOL Cocos_SDK_LOG_EABLE = NO;
void cocos_setLogEable(BOOL isLog) {
    Cocos_SDK_LOG_EABLE = isLog;
}
BOOL cocos_logEable(void) {
    return Cocos_SDK_LOG_EABLE;
}

