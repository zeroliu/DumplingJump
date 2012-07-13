//
//  AppDelegate.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-7-9.
//  Copyright INSA 2012年. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
