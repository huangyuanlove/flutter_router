//
//  ViewController.m
//  FlutterRouter
//
//  Created by huangyuan on 2019/10/8.
//  Copyright © 2019 huangyuan. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import <Flutter/Flutter.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self
               action:@selector(handleButtonAction)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Press me" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor blueColor]];
    button.frame = CGRectMake(80.0, 210.0, 160.0, 40.0);
    [self.view addSubview:button];
     
}
- (void)handleButtonAction {
    FlutterEngine *flutterEngine = [(AppDelegate *)[[UIApplication sharedApplication] delegate] flutterEngine];
    FlutterViewController *flutterViewController = [[FlutterViewController alloc] initWithEngine:flutterEngine nibName:nil bundle:nil];
    [flutterViewController setInitialRoute:@"main"];
    
  
       FlutterMethodChannel* batteryChannel = [FlutterMethodChannel
                                               methodChannelWithName:@"my_flutter/plugin"
                                               binaryMessenger:flutterViewController];
       
       [batteryChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
           NSLog([@"方法名" stringByAppendingFormat:call.method]);
           
          
       }];
       
    [self presentViewController:flutterViewController animated:false completion:nil];
}

@end
