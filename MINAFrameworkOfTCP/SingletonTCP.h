//
//  SingletonTCP.h
//  MINAFrameworkOfTCP
//
//  Created by lccx on 2016/12/5.
//  Copyright © 2016年 lccx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AsyncSocket.h>

#define DEFINE_SHARED_INSTANCE_USING_BLOCK(block) \
static dispatch_once_t onceToken = 0; \
__strong static id sharedInstance = nil; \
dispatch_once(&onceToken, ^{ \
sharedInstance = block(); \
}); \
return sharedInstance; \

enum{
    SocketOfflineByServer,// 服务器掉线，默认为0
    SocketOfflineByUser,  // 用户主动cut
};

@interface SingletonTCP : NSObject<AsyncSocketDelegate>

@property (nonatomic, strong) AsyncSocket    *socket;       // socket
@property (nonatomic, copy  ) NSString       *socketHost;   // socket的Host
@property (nonatomic, assign) UInt16         socketPort;    // socket的prot
@property (nonatomic, retain) NSTimer        *connectTimer; // 计时器
@property (nonatomic, strong) NSMutableData  *mutableData;  // 完整的数据

+ (SingletonTCP *)sharedInstance;           // 单例

- (void)socketConnectHost;                  // socket连接

- (void)cutOffSocket;                       // 断开socket连接

@end
