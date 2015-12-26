//
//  ShotOMaticAppDelegate.m
//  ShotOMatic
//
//  Created by Michael Harsch on 2/10/11.
//  Copyright 2011 Harsch Systems Inc. All rights reserved.
//

#import "ShotOMaticAppDelegate.h"
#import "RootViewController.h"
#import "Constants.h"
#import "FlurryAnalytics.h"
#import "PagedResultsViewController.h"
#import "ShotPickViewController.h"
/*
//Override the drawRect method of UINavigationBar to use custom woodgrain background image
@interface UINavigationBar (MyCustomNavBar)
@end

@implementation UINavigationBar (MyCustomNavBar)
- (void) drawRect:(CGRect)rect {
    UIImage *barImage = [UIImage imageNamed:@"woodnavbar.png"];
    [barImage drawInRect:rect];
}
@end
 */

@implementation ShotOMaticAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize bannerView;
@synthesize currentController;
@synthesize facebook;
@synthesize fbSupported;

#pragma mark -
#pragma mark Application lifecycle

// Override getter for facebook property
- (Facebook *)facebook
{
    if (!facebook) {
        facebook = [[Facebook alloc] initWithAppId:kFBAppId andDelegate:self];
    }
    
    return facebook;
}

void uncaughtExceptionHandler(NSException *exception) {
    if (analyticsEnabled) {
        [FlurryAnalytics logError:@"Uncaught" message:@"Crash!" exception:exception];
    }
}

- (BOOL)fbSessionReady
{    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
        self.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        self.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    return ([self.facebook isSessionValid]);    
}

- (void)fbAuthorize
{
    NSArray *permissions = [NSArray arrayWithObjects:@"publish_stream", @"offline_access", nil];
    [self.facebook authorize:permissions];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Get iAd up and running
    CGRect bounds = [[UIScreen mainScreen] bounds];
    bannerView = [[ADBannerView alloc] initWithFrame:CGRectMake(0.0, bounds.size.height, 0.0, 0.0)];
    bannerView.delegate = self;
    bannerView.hidden = YES;
    currentController = nil;
    
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    // Needed for orientation change fix (update1)
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    // Add the navigation controller's view to the window and display.
    [self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];
    
	// Flurry Analytics Package
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    if (analyticsEnabled) {
        dispatch_queue_t tmpQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        dispatch_async(tmpQueue, ^{
            [FlurryAnalytics startSession:kFlurryId];
        });
    }
    
    //Detect if Facebook App is installed and usable (fast app switching requires iOS >= 4.3)
    if (([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://profile"]]) &&
        (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"4.3"))) {
        self.fbSupported = YES;        
    } else {
        self.fbSupported = NO;
    };
    
    // Custom wood grain image for navigation bar
    UIImage *barImage = [UIImage imageNamed:@"woodnavbar.png"];
    [self.navigationController.navigationBar setBackgroundImage:barImage forBarMetrics:UIBarMetricsDefault];
    
    // Add the navigation controller's view to the window and display.
    [self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];

    return YES;
}

// Required for Facebook SSO
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [self.facebook handleOpenURL:url]; 
}

// FBSessionDelegate
- (void)fbDidLogin {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[self.facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    //Post shot that was initially requested
    UIViewController *tmpvc = navigationController.topViewController;
    ShotPickViewController *spvc = nil;
    
    if ([tmpvc isKindOfClass:[ShotPickViewController class]]) {
        
        spvc = (ShotPickViewController *)tmpvc;
        
    } else if ([tmpvc isKindOfClass:[PagedResultsViewController class]]) {
        
        PagedResultsViewController *prvc = (PagedResultsViewController *)tmpvc;
        int vcIndex = prvc.customPageControl.currentPage;
        
        spvc = [prvc.viewControllers objectAtIndex:vcIndex];
    }
    
    if (spvc) {
        [spvc doFBPost];
    }
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
    if (analyticsEnabled) {
        dispatch_queue_t tmpQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        dispatch_async(tmpQueue, ^{
            [FlurryAnalytics logEvent:@"FB Session Failure"];
        });
    }
}

- (void)fbDidLogout
{
    
}

- (void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt
{
    
}

- (void)fbSessionInvalidated
{
    
}

// ADBannerViewDelegate stuff
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [currentController showBannerView:banner animated:YES];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [currentController hideBannerView:bannerView animated:YES];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    [[NSUserDefaults standardUserDefaults] setObject:[[ShotDB instance].favoriteSet allObjects] forKey:@"favorites"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
    NSLog(@"Memory warning recieved by app delegate");
}


- (void)dealloc {
	[navigationController release];
    [facebook release];
	[window release];
	[super dealloc];
}


@end

