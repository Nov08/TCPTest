//
//  NSString+JsonString.h
//  MINAFrameworkOfTCP
//
//  Created by lccx on 2016/12/5.
//  Copyright © 2016年 lccx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (JsonString)

+ (NSString*)anyDataToJsonString:(id)object;

@end
