//
//  ShotOMaticAppDelegate.h
//  ShotOMatic
//
//  Created by Michael Harsch on 2/10/11.
//  Copyright 2011 Harsch Systems Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "FBConnect.h"

@protocol BannerViewContainer <NSObject>
- (void)showBannerView:(ADBannerView *)bannerView animated:(BOOL)animated;
- (void)hideBannerView:(ADBannerView *)bannerView animated:(BOOL)animated;
@end

@interface ShotOMaticAppDelegate : NSObject <UIApplicationDelegate,UIAlertViewDelegate,ADBannerViewDelegate,FBSessionDelegate> {
    UIWindow *window;
    UINavigationController *navigationController;
    ADBannerView *bannerView;
    UIViewController<BannerViewContainer> *currentController;
    Facebook *facebook;
    BOOL fbSupported;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) ADBannerView *bannerView;
@property (nonatomic, retain) UIViewController *currentController;
@property (nonatomic, retain) Facebook *facebook;
@property BOOL fbSupported;

- (BOOL)fbSessionReady;
- (void)fbAuthorize;
@end

