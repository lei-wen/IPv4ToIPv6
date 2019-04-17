//
//  IPConvert.h
//  IPv4ToIPv6
//
//  Created by lei-wen on 2019/4/18.
//  Copyright © 2019 lei-wen. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <err.h>

NS_ASSUME_NONNULL_BEGIN

@interface IPConvert : NSObject

/**
 1，用于ip地址ipv4和ipv6之间的转换(如果手机连接的是ipv6的wifi可用这个方法传入ipv4获取ipv6地址)
 2，根据传入的ip地址，获取你想要的IP地址，比如手机连接的是ipv6的wifi，你传入的是ipv4的地址则返回一个ipv6的地址，前提是你的手机链接的是外网。
 3，怎么判断手机连接的是不是ipv6的Wi-Fi，可根据+(BOOL)isIpv6Net这个方法判断
 @param ipAddr 传入的ip地址，主要是传入ipv4的ip地址
 @param port 端口号，要和你传入的ip地址的端口号一直
 @return 返回和手机连接的Wi-Fi的ip类型相同的ip，比如手机连接的是ipv6的Wi-Fi，则返回一个ipv6的地址
 */
+(NSString*)getProperIPWithAddress:(NSString*)ipAddr port:(UInt32)port;

//获取手机当前连接地址
+ (NSDictionary *)getIPAddresses;

//判断是否是ipv6（判断手机连接的是不是ipv6的WiFi）
+ (BOOL)isIpv6Net;

@end

NS_ASSUME_NONNULL_END
