//
//  NotificationActionViewController.m
//  NotificationDemo
//
//  Created by iosci on 2017/3/6.
//  Copyright © 2017年 secoo. All rights reserved.
//

#import "NotificationActionViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "NotificationCategoryId.h"

@interface NotificationActionViewController ()


@end

@implementation NotificationActionViewController

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (IBAction)_sendNotification:(UIButton *)sender {
  NSTimeInterval ti = 6;
  UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
  content.title = @"您收到一封邮件";
  content.subtitle = @"来自Apple";
  content.body = @"Hello world";
  content.categoryIdentifier = kReplyNotificationCategoryId;
  content.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
  UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:ti repeats:NO];
  NSString *requestIdentifier = @"com.secoo.notification.action";
  UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier content:content trigger:trigger];
  [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
    NSLog(@"id: %@, error: %@", requestIdentifier, error.description);
  }];
}

@end
