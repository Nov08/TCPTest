//
//  NSString+JsonString.m
//  MINAFrameworkOfTCP
//
//  Created by lccx on 2016/12/5.
//  Copyright © 2016年 lccx. All rights reserved.
//

#import "NSString+JsonString.h"

@implementation NSString (JsonString)

+ (NSString*)anyDataToJsonString:(id)object
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

@end
