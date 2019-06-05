//
//  CocosSetting.h
//  CocosSDK
//
//  Created by SYLing on 2019/3/6.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

// 调试Log
#define SDKLog(...) !cocos_logEable() ? : NSLog(@"file:%s line:%d func:%s logInfo:\n%@\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],__LINE__,__FUNCTION__,[NSString stringWithFormat:__VA_ARGS__]);

#if defined(__cplusplus)
#define CocosLOG_EXTERN extern "C"
#else
#define CocosLOG_EXTERN extern
#endif

/**
 Setting Print Output File Path without Connecting Xcode
 
 Must be invoked at program startup
 
 @param folderPath Output Sandbox Path of Printed Information （Folder）
 @return Successful setup
 */
CocosLOG_EXTERN BOOL cocos_redirectNSlogToCachesFolder(NSString * folderPath);

/** Whether to print debugging information */
CocosLOG_EXTERN BOOL cocos_logEable(void);


/** set print debug log */
CocosLOG_EXTERN void cocos_setLogEable(BOOL islog);

NS_ASSUME_NONNULL_END
