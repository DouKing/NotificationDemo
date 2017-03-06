//
//  NSData+HEX.m
//  NotificationDemo
//
//  Created by iosci on 2017/3/6.
//  Copyright © 2017年 secoo. All rights reserved.
//

#import "NSData+HEX.h"

@implementation NSData (HEX)

- (NSString *)hexString {
  if (0 == [self length]) {
    return @"";
  }
  NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[self length]];
  
  [self enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
    unsigned char *dataBytes = (unsigned char*)bytes;
    for (NSInteger i = 0; i < byteRange.length; i++) {
      NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
      if ([hexStr length] == 2) {
        [string appendString:hexStr];
      } else {
        [string appendFormat:@"0%@", hexStr];
      }
    }
  }];
  
  return string;
}

@end
