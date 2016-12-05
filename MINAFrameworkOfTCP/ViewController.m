//
//  ViewController.m
//  MINAFrameworkOfTCP
//
//  Created by lccx on 2016/12/5.
//  Copyright © 2016年 lccx. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableData *bigData; // 当前页面所接收的完整数据

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(100, 100, 200, 30);
    [button setTitle:@"点击" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    // RAC模式设置button事件监听
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSData *dataStream = [[self creatData] dataUsingEncoding:NSUTF8StringEncoding];
        NSString *str = [[NSString alloc] initWithData:dataStream encoding:NSJSONReadingMutableContainers];
        MyLog(@"str:%@", str);
        // 发送数据到服务端
        [[SingletonTCP sharedInstance].socket writeData:dataStream withTimeout:TIMEOUT tag:10];
    }];
    [self.view addSubview:button];
    
    // 通知中心收到服务器返回的数据后，进行解析数据，这里的通知中心接收消息采用的是RAC模式
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"getData" object:nil] subscribeNext:^(NSNotification *notification) {
        NSLog(@"%@", notification.name);
        NSLog(@"%@", notification.object);
        self.bigData = (NSMutableData *)notification.object;
        // 接收服务器返回数据
        NSString *serverMessage = [[NSString alloc] initWithData:self.bigData encoding:NSUTF8StringEncoding];
        // 进行base64解码
        NSData *serverData = [[NSData alloc] initWithBase64EncodedString:serverMessage options:NSDataBase64DecodingIgnoreUnknownCharacters];
        // 解析数据
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:serverData options:NSJSONReadingMutableContainers error:nil];
        MyLog(@"解析数据dictionary:%@", dictionary);
        MyLog(@"解析数据serverMessage:%@", serverMessage);
    }];
}

// 模拟数据
- (NSString *)creatData
{
    NSDictionary *dictionary = @{@"action":@"login", @"user":@"admin", @"password":@"123456"};
    MyLog(@"数据字典:%@", dictionary);
    NSString *message = [NSString stringWithFormat:@"%@\r\n",[[[NSString anyDataToJsonString:dictionary] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]];
    return message;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
