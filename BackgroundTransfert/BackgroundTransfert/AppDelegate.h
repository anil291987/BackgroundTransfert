//
//  AppDelegate.h
//  BackgroundTransfert
//
//  Created by Olivier on 26/06/2014.
//  Copyright (c) 2014 sqli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) void(^backgroundTransfertCompletionHandler)();

@end
