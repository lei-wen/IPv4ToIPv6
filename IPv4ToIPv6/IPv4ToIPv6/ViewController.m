//
//  ViewController.m
//  IPv4ToIPv6
//
//  Created by lei-wen on 2019/4/18.
//  Copyright © 2019 lei-wen. All rights reserved.
//

#import "ViewController.h"
#import "IPConvert.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *serverIP = @"118.190.95.172";
    NSString *iPv4Port = @"8888";

    NSLog(@"手机连接地址: %@", [IPConvert getIPAddresses]);
    
    /**
     *使用的时候通过这个方法+(BOOL)isIpv6Net判断手机连接的是不是ipv6的网络
     *如果是ipv6的网络那就用这个+(NSString)getProperIPWithAddress:(NSString)ipAddr port:(UInt32)port把ipv4的ip地址转换成ipv6地址，注意端口号
     */
    
    if ([IPConvert isIpv6Net]) {
        NSString *iPV6Address = [IPConvert getProperIPWithAddress:serverIP port:(UInt32)[iPv4Port intValue]];
        NSLog(@"iPV6Address:%@",iPV6Address);
    }
}

@end
