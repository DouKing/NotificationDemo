//
//  AppDelegate.m
//  NotificationDemo
//
//  Created by iosci on 2017/3/6.
//  Copyright © 2017年 secoo. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import "NSData+HEX.h"
#import "NotificationCategoryId.h"

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@property (nonatomic, strong) UNNotificationCategory *category;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  application.applicationIconBadgeNumber = 0;
  
  //请求通知权限
  [UNUserNotificationCenter currentNotificationCenter].delegate = self;
  [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
    if (granted) {
      NSLog(@"用户同意");
    }
    NSLog(@"error: %@", error.description);
  }];
  
  //发送远程通知需要请求token
  [application registerForRemoteNotifications];

  //Actions
  [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithObject:self.category]];
  
  if (application.isRegisteredForRemoteNotifications) {
    // 检查用户权限设置
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
      NSLog(@"authorizationStatus: %ld", (long)settings.authorizationStatus);
    }];
  }

  NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"silentData"];
  NSLog(@"silent data: %@", date);
  NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"silent-userInfo"];
  NSLog(@"silent userInfo: %@", userInfo);
  return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
  if (options) {
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"tt" message:[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:options options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding ] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:action];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
    });
  }

  return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  NSString *hexStr = [deviceToken hexString];
  NSLog(@"token: %@", hexStr);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
  //receive silent notification
  [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"silentData"];
  [[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:@"silent-userInfo"];
}

#pragma mark - UNUserNotificationCenterDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
  completionHandler(UNNotificationPresentationOptionAlert |
                    UNNotificationPresentationOptionBadge |
                    UNNotificationPresentationOptionSound);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
  NSString *categoryId = response.notification.request.content.categoryIdentifier;
  if ([categoryId isEqualToString:kReplyNotificationCategoryId]) {
    [self _reply:response];
  }
  completionHandler();
}

- (void)_reply:(UNNotificationResponse *)response {
  NSString *actionId = response.actionIdentifier;
  NSString *text = @"";
  if ([actionId isEqualToString:kReplyNotificationActionInputId]) {
    text = [(UNTextInputNotificationResponse *)response userText];
  } else if ([actionId isEqualToString:kReplyNotificationActionReplyId]) {
    text = @"已收到";
  } else if ([actionId isEqualToString:kReplyNotificationActionCancelId]) {
    
  }
  if (text.length) {
    NSLog(@"回复:%@", text);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:text preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
  }
}

- (UNNotificationCategory *)category {
  if (!_category) {
    UNTextInputNotificationAction *action1 = [UNTextInputNotificationAction actionWithIdentifier:kReplyNotificationActionInputId title:@"Input" options:UNNotificationActionOptionForeground textInputButtonTitle:@"Send" textInputPlaceholder:@"placeholder"];
    UNNotificationAction *action2 = [UNNotificationAction actionWithIdentifier:kReplyNotificationActionReplyId title:@"Reply" options:UNNotificationActionOptionForeground];
    UNNotificationAction *action3 = [UNNotificationAction actionWithIdentifier:kReplyNotificationActionCancelId title:@"Cancel" options:UNNotificationActionOptionDestructive];
    _category = [UNNotificationCategory categoryWithIdentifier:kReplyNotificationCategoryId actions:@[action1, action2, action3] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
  }
  return _category;
}

@end
