//
//  SingletonTCP.m
//  MINAFrameworkOfTCP
//
//  Created by lccx on 2016/12/5.
//  Copyright © 2016年 lccx. All rights reserved.
//

#import "SingletonTCP.h"

@implementation SingletonTCP

+ (SingletonTCP *)sharedInstance
{
    static SingletonTCP *sharedInstace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstace = [[self alloc] init];
    });
    
    return sharedInstace;
}

// socket连接
- (void)socketConnectHost{
    
    self.socket = [[AsyncSocket alloc] initWithDelegate:self];
    
    NSError *error = nil;
    
    [self.socket connectToHost:self.socketHost onPort:self.socketPort withTimeout:3 error:&error];
    
}

// 心跳连接
- (void)longConnectToSocket{
    
    // 根据服务器要求发送固定格式的数据，假设为指令@"active"，但是一般不会是这么简单的指令
    
    //    NSString *longConnect = @"action";
    //
    //    NSData *dataStream = [longConnect dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *dictionary = @{@"action":@"active"};
    MyLog(@"数据字典:%@", dictionary);
    NSString *message = [NSString stringWithFormat:@"%@\r\n",[[[self anyDataToJsonString:dictionary] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]];
    NSData *dataStream = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.socket writeData:dataStream withTimeout:30 tag:999];
    [self.socket readDataWithTimeout:30 tag:222];
}

// 切断socket
- (void)cutOffSocket{
    
    self.socket.userData = SocketOfflineByUser;// 声明是由用户主动切断
    
    [self.connectTimer invalidate];
    
    [self.socket disconnect];
}

// 将任何类型转换为JsonString
- (NSString*)anyDataToJsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
    if (! jsonData) {
        MyLog(@"Got an error:%@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        MyLog(@"JsonString:%@", jsonString);
    }
    return jsonString;
}

#pragma mark  - 代理方法
// 连接成功后的代理方法
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"socket连接成功");
    
    // 每隔30s像服务器发送心跳包
    self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(longConnectToSocket) userInfo:nil repeats:YES];// 在longConnectToSocket方法中进行长连接需要向服务器发送的讯息
    
    [self.connectTimer fire];
    
}
// 断开连接后的代理方法
- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    NSLog(@"sorry the connect is failure %ld",sock.userData);
    if (sock.userData == SocketOfflineByServer) {
        // 服务器掉线，重连
        [self socketConnectHost];
    }
    else if (sock.userData == SocketOfflineByUser) {
        // 如果由用户断开，不进行重连
        return;
    }
    
}
// 发送完消息的代理方法
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    MyLog(@"发送了%ld", tag);
}

// 判断报文是否接收完整，并且完整接收数据
- (BOOL)GoOnReceiveDatagramWithData:(NSData *)data
{
    [self.mutableData appendData:data];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([str hasSuffix:@"\r\n"]) {
        NSData *base64Data = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
        NSString *s = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
        MyLog(@"s: %@", s);
        return false;
    } else {
        return true;
    }
}

// 读取完消息的代理方法
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"getData" object:data];
    if ([self GoOnReceiveDatagramWithData:data]) {
        [self.socket readDataWithTimeout:-1 tag:0];
    } else {
        // 如果接收完所有服务器数据，用通知中心返回mutableData
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getData" object:self.mutableData];
    }
}


@end
