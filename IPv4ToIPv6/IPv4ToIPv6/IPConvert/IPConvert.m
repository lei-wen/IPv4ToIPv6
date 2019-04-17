//
//  IPConvert.m
//  IPv4ToIPv6
//
//  Created by lei-wen on 2019/4/18.
//  Copyright © 2019 lei-wen. All rights reserved.
//

#import "IPConvert.h"
#import "GCDAsyncSocket.h"

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>

@implementation IPConvert

/**
 1，用于ip地址ipv4和ipv6之间的转换(如果手机连接的是ipv6的wifi可用这个方法传入ipv4获取ipv6地址)
 2，根据传入的ip地址，获取你想要的IP地址，比如手机连接的是ipv6的wifi，你传入的是ipv4的地址则返回一个ipv6的地址，前提是你的手机链接的是外网。
 3，怎么判断手机连接的是不是ipv6的Wi-Fi，可根据+(BOOL)isIpv6Net这个方法判断
 @param ipAddr 传入的ip地址，主要是传入ipv4的ip地址
 @param port 端口号，要和你传入的ip地址的端口号一直
 @return 返回和手机连接的Wi-Fi的ip类型相同的ip，比如手机连接的是ipv6的Wi-Fi，则返回一个ipv6的地址
 */
+ (NSString*)getProperIPWithAddress:(NSString*)ipAddr port:(UInt32)port {
    NSError *addresseError = nil;
    NSArray *addresseArray = [GCDAsyncSocket lookupHost:ipAddr
                                                   port:port
                                                  error:&addresseError];
    if (addresseError) {
        NSLog(@"");
    }
    NSString *ipv6Addr = @"";
    for (NSData *addrData in addresseArray) {
        if ([GCDAsyncSocket isIPv6Address:addrData]) {
            ipv6Addr = [GCDAsyncSocket hostFromAddress:addrData];
        }
    }
    if (ipv6Addr.length == 0) {
        ipv6Addr = ipAddr;
    }
    return ipv6Addr;
}


//判断是否是ipv6（判断手机连接的是不是ipv6的WiFi）
+ (BOOL)isIpv6Net {
    NSArray *searchArray =
    @[ IOS_VPN @"/" IP_ADDR_IPv6,
       IOS_VPN @"/" IP_ADDR_IPv4,
       IOS_WIFI @"/" IP_ADDR_IPv6,
       IOS_WIFI @"/" IP_ADDR_IPv4,
       IOS_CELLULAR @"/" IP_ADDR_IPv6,
       IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    NSDictionary *addresses = [self getIPAddresses];
    __block BOOL isIpv6 = NO;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         if ([key rangeOfString:@"ipv6"].length > 0  && ![[NSString stringWithFormat:@"%@",addresses[key]] hasPrefix:@"(null)"] ) {
             
             if ( ![addresses[key] hasPrefix:@"fe80"]) {
                 isIpv6 = YES;
             }
         }
     } ];
    return isIpv6;
}

//获取手机连接的ip地址（包括ipv4地址和ipv6地址）
+ (NSDictionary *)getIPAddresses {
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                        
                        //                        NSLog(@"ipv4 %@",name);
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                        //                        NSLog(@"ipv6 %@",name);
                        
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

@end
