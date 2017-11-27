//
//  ViewController.m
//  NotificationDemo
//
//  Created by iosci on 2017/3/6.
//  Copyright © 2017年 secoo. All rights reserved.
//

#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *timeIntervalField;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (IBAction)_triggerNotification:(UIButton *)sender {
  NSTimeInterval ti = (NSTimeInterval)[self.timeIntervalField.text doubleValue];
  UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
  content.title = @"First notification title";
  content.subtitle = @"First notification subtitle";
  content.body = @"First notification body";
  content.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
  content.sound = [UNNotificationSound soundNamed:@"beep.wav"];
  
  NSURL *path = [[NSBundle mainBundle] URLForResource:@"IMG_0557.JPG" withExtension:nil];
  NSError *error = nil;
  NSDictionary *options = @{
                            UNNotificationAttachmentOptionsTypeHintKey : (__bridge NSString *)kUTTypeJPEG,
                            UNNotificationAttachmentOptionsThumbnailClippingRectKey : (__bridge id)CGRectCreateDictionaryRepresentation(CGRectMake(0, 0, 0.5, 0.5))
                            };
  UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"com.secoo.notification.attachment" URL:path options:options error:&error];
  if (error) {
    NSLog(@"error: %@", error);
    return;
  }
  content.attachments = @[attachment];
  UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:ti repeats:NO];
  NSString *requestIdentifier = @"com.secoo.notification.first.send";
  UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier content:content trigger:trigger];
  [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
    NSLog(@"id: %@, error: %@", requestIdentifier, error.description);
  }];
}

- (IBAction)_cancelNotification:(id)sender {
  NSTimeInterval ti = (NSTimeInterval)[self.timeIntervalField.text doubleValue];
  UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
  content.title = @"First cancel notification title";
  content.subtitle = @"First cancel notification subtitle";
  content.body = @"First cancel notification body";
  content.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
  UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:ti repeats:NO];
  NSString *requestIdentifier = @"com.secoo.notification.first.cancel";
  UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier content:content trigger:trigger];
  [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
    NSLog(@"id: %@, error: %@", requestIdentifier, error.description);
  }];
  
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((ti + 1) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [[UNUserNotificationCenter currentNotificationCenter] removeDeliveredNotificationsWithIdentifiers:@[requestIdentifier]];
    [UIApplication sharedApplication].applicationIconBadgeNumber -= 1;
  });
}

- (IBAction)_pushSound:(UIButton *)sender {
  NSTimeInterval ti = (NSTimeInterval)[self.timeIntervalField.text doubleValue];
  UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
  content.title = @"push sound";
  content.subtitle = @"push sound subtitle";
  content.body = @"push sound body";
  content.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);

  NSURL *path = [[NSBundle mainBundle] URLForResource:@"music_001.mp3" withExtension:nil];
  NSError *error = nil;
  NSDictionary *options = @{
                            UNNotificationAttachmentOptionsTypeHintKey : (__bridge id)kUTTypeMP3,
                            };
  UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"com.secoo.notification.attachment.audio" URL:path options:options error:&error];
  if (error) {
    NSLog(@"error: %@", error);
    return;
  }

  content.attachments = @[attachment];
  UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:ti repeats:NO];
  NSString *requestIdentifier = @"com.secoo.notification.sound";
  UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier content:content trigger:trigger];
  [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
    NSLog(@"id: %@, error: %@", requestIdentifier, error.description);
  }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [self.view endEditing:YES];
}

@end
