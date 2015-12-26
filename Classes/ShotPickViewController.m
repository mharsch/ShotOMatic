    //
//  ShotPickViewController.m
//  ShotOMatic
//
//  Created by Michael Harsch on 2/10/11.
//  Copyright 2011 Harsch Systems Inc. All rights reserved.
//

#import "ShotPickViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ShotDB.h"
#import "Constants.h"
#import "FlurryAnalytics.h"
#import "RootViewController.h"
#import "FavoritesViewController.h"
#import "AboutViewController.h"
#import "ShotOMaticAppDelegate.h"
#import "SBJSON.h"
#import "Twitter/Twitter.h"

@implementation ShotPickViewController
@synthesize shotName, shotDescription, shotHeading, likeButton, fbButton, tweetButton,shareLabel, headingText;
@synthesize shotRecord;
@synthesize fbParams;
@synthesize shotImage;
@synthesize subordinate;
@synthesize appDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        showingTiltedView = NO;
        subordinate = NO;
        self.appDelegate = (ShotOMaticAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)pushFavoritesView
{
    FavoritesViewController *tmpFVC = [[FavoritesViewController alloc] initWithNibName:@"FavoritesViewController" bundle:nil];
    
    [UIView transitionWithView:self.navigationController.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{ 
                        [self.navigationController pushViewController:tmpFVC animated:NO];
                    }
                    completion:NULL];
    
    [tmpFVC release];
    
    if (analyticsEnabled) {
        dispatch_queue_t tmpQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        dispatch_async(tmpQueue, ^{
            [FlurryAnalytics logEvent:@"Favorites List Mode"];
        });
    }
    
}

- (void)pushAboutView
{
    AboutViewController *tmpAVC = [[AboutViewController alloc] init];
    
    [UIView transitionWithView:self.navigationController.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{ 
                        [self.navigationController pushViewController:tmpAVC animated:NO];
                    }
                    completion:NULL];
    
    
	[tmpAVC release];
}


- (IBAction)likeButtonPressed:(UIButton *)sender
{
	if (self.shotRecord.favorite) {
		[sender setImage:[UIImage imageNamed:@"heart_off.png"] forState:UIControlStateNormal];
        [[ShotDB instance].favoriteSet removeObject:self.shotRecord.name];
        self.shotRecord.favorite = NO;
	} else {
        [sender setImage:[UIImage imageNamed:@"heart_on.png"] forState:UIControlStateNormal];
        [[ShotDB instance].favoriteSet addObject:self.shotRecord.name];
        self.shotRecord.favorite = YES;
        
        NSDictionary *tmpDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Shot Name", self.shotRecord.name, nil];
        
        if (analyticsEnabled) {
            dispatch_queue_t tmpQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
            dispatch_async(tmpQueue, ^{
                [FlurryAnalytics logEvent:@"Shot Liked" withParameters:tmpDictionary];
            });
        }
        
	}
    
    [ShotDB instance].favoritesUpdated = YES;

}

- (IBAction)tweetButtonPressed:(UIButton *)sender
{
    TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
    //skip completion handler - accept default behavior (dismiss modal view controller)
    
    NSString *tmpString = @"just had a '";
    tmpString = [tmpString stringByAppendingString:self.shotRecord.name];
    tmpString = [tmpString stringByAppendingString:@"' shot.  Thanks, @shotOmatic!"];
    [tweetSheet setInitialText:tmpString];
    
    [self presentModalViewController:tweetSheet animated:YES];
}

- (IBAction)fbButtonPressed:(UIButton *)sender
{
    if (analyticsEnabled) {
        dispatch_queue_t tmpQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        dispatch_async(tmpQueue, ^{
            [FlurryAnalytics logEvent:@"FB Button Pressed"];
        });
    }
    
    NSString *imagePath;
    
    if ([shotRecord.category isEqualToString:@"Pro Shots"]) {
        imagePath = kProImagePath;
    } else if ([shotRecord.category isEqualToString:@"Rookie Shots"]) {
        imagePath = kRookieImagePath;
    } else {
        imagePath = kDaredevilImagePath;
    }
    
    NSString *prefix = @"Just had a ";
    NSString *suffix = @" shot, courtesy of Shot-O-Matic.";
    
    if ([shotRecord.name hasPrefix:@"The "] || [shotRecord.name hasPrefix:@"A "]) {
        prefix = @"Just had ";
    }
    
    if ([shotRecord.name hasSuffix:@"Shot"]) {
        suffix = @" courtesy of Shot-O-Matic";
    }
    
    NSString *message = [NSString stringWithFormat:@"%@%@%@", prefix, shotRecord.name, suffix];
    NSString *link = @"http://itunes.apple.com/us/app/shot-o-matic/id426601901?ls=1&mt=8";
    NSString *name = shotRecord.name;
    NSString *caption = @"1 of over 400 shots available on your iPhone";
    NSString *description = [shotRecord.description stringByReplacingOccurrencesOfString:@"\n" withString:@" <center></center>"];
           
    NSString *actions = @"[{ \"name\": \"Shot-O-Matic\", \
                             \"link\": \"http://www.facebook.com/pages/Shot-O-Matic/158323317539104\"}]";
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   message,  @"message",
                                   imagePath, @"picture",
                                   link, @"link",
                                   name, @"name",
                                   caption, @"caption",
                                   description, @"description",
                                   actions, @"actions",
                                   nil];
    
    
    
    self.fbParams = params;
    
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Post on Facebook?"
                              message:@"Would you like to share this shot with your friends on facebook?"
                              delegate:self
                              cancelButtonTitle:@"Not Really"
                              otherButtonTitles:@"Yeppers", nil];

    [alertView show];
    [alertView release];
}

- (void)doFBPost {
    [self.appDelegate.facebook requestWithGraphPath:@"me/feed" andParams:self.fbParams andHttpMethod:@"POST" andDelegate:self];
}

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response
{
}

- (void)request:(FBRequest *)request didLoad:(id)result
{
    if (analyticsEnabled) {
        dispatch_queue_t tmpQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        dispatch_async(tmpQueue, ^{
            [FlurryAnalytics logEvent:@"FB Shot Posted"];
        });
    }
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    if (analyticsEnabled) {
        dispatch_queue_t tmpQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        dispatch_async(tmpQueue, ^{
            [FlurryAnalytics logEvent:@"FB Request Failure" withParameters:[error userInfo]];
        });
    }
    
    //User may have changed their fb passwd or de-authorized the SoM fb app.  If so, we must re-authorize
    NSString *errorMessage = [[error userInfo] objectForKey:@"error_msg"];
    if (([errorMessage rangeOfString:@"has not authorized application"].location != NSNotFound) ||
        ([errorMessage rangeOfString:@"session is invalid because the user logged out"].location != NSNotFound)) {
        [self.appDelegate fbAuthorize];
    }
}


// UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if (analyticsEnabled) {
            dispatch_queue_t tmpQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
            dispatch_async(tmpQueue, ^{
                [FlurryAnalytics logEvent:@"FB Button Canceled"];
            });
        }
        return;
    } else if (buttonIndex == 1) {
        if ([self.appDelegate fbSessionReady] == YES) {
            [self doFBPost];
        } else {
            [self.appDelegate fbAuthorize];
        }
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    UIButton *heartButton = [UIButton buttonWithType:UIButtonTypeCustom];
    heartButton.frame = CGRectMake(0, 0, 40, 30);
    [heartButton setImage:[UIImage imageNamed:@"heartbutton.png"] forState:UIControlStateNormal];
    [heartButton setImage:[UIImage imageNamed:@"heartbutton_clicked.png"] forState:UIControlStateHighlighted];
    
    UIBarButtonItem *heartBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:heartButton];
    [heartButton addTarget:self action:@selector(pushFavoritesView) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = heartBarButtonItem;
    
    [heartBarButtonItem release];
    
    //Custom button in titleView position
    UIButton *logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    logoButton.frame = CGRectMake(0, 0, 68, 39);
    [logoButton setImage:[UIImage imageNamed:@"logobutton.png"] forState:UIControlStateNormal];
    [logoButton setImage:[UIImage imageNamed:@"logobutton_clicked.png"] forState:UIControlStateHighlighted];
    
    [logoButton addTarget:self action:@selector(pushAboutView) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.titleView = logoButton;

    
	if (shotRecord) {
		[self.shotName setText:shotRecord.name];
        [self.shotName setTextColor:UIColorFromRGB(0xCC3813)];
		[self.shotDescription setText:shotRecord.description];
        
        UIImage *tmpImage = nil;
        
        if ([shotRecord.category isEqualToString:@"Pro Shots"]) {
            tmpImage = [UIImage imageNamed:@"proshot.png"];
        } else if ([shotRecord.category isEqualToString:@"Rookie Shots"]) {
            tmpImage = [UIImage imageNamed:@"rookieshot.png"];
        } else if ([shotRecord.category isEqualToString:@"Daredevil Shots"]) {
            tmpImage = [UIImage imageNamed:@"daredevilshot.png"];
        }
        
        if (tmpImage) {
            [self.shotImage setImage:tmpImage];
        }

	}
    
    if (self.headingText) {
        [self.shotHeading setText:self.headingText];
    }
    
    if (shotRecord.favorite) {
        [self.likeButton setImage:[UIImage imageNamed:@"heart_on.png"] forState:UIControlStateNormal];
    }
    
    if (self.appDelegate.fbSupported == NO) {
        //hide the facebook icon
        self.fbButton.hidden = YES;
    }
    
    // Twitter integration stuff
    if ([TWTweetComposeViewController canSendTweet] == NO) {
        self.tweetButton.hidden = YES;
    }
    
    if (self.fbButton.hidden && self.tweetButton.hidden)
        self.shareLabel.hidden = YES;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hasTilted:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];

}

- (void)hasTilted:(NSNotification *)notification
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation) &&
        !showingTiltedView &&
        !self.subordinate)
    {
        TiltedShotViewController *tmpTSVC = [[TiltedShotViewController alloc] init];
        tmpTSVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        tmpTSVC.nameText = self.shotRecord.name;
        tmpTSVC.recipeText = self.shotRecord.description;
        [self presentModalViewController:tmpTSVC animated:YES];
        [tmpTSVC release];

        showingTiltedView = YES;
    }
    else if (UIDeviceOrientationIsPortrait(deviceOrientation) &&
             showingTiltedView)
    {
        [self dismissModalViewControllerAnimated:NO];
        showingTiltedView = NO;
    }
}


/* Stuff for Shake Gesture Handler */
- (BOOL)canBecomeFirstResponder
{
	return YES;
}


- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    
	[self becomeFirstResponder];
    
    self.subordinate = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self resignFirstResponder]; 
    
    self.subordinate = YES;
    
	[super viewWillDisappear:animated];
}


- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSArray *tmpArray = [self.navigationController viewControllers];
    RootViewController *tmpVC = [tmpArray objectAtIndex:0];
    
    tmpVC.goAgain = YES;
    tmpVC.goAgainCategory = @"Random Shot";
    [self.navigationController popViewControllerAnimated:NO];

}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)releaseOutlets
{
	self.shotName = nil;
	self.shotDescription = nil;
	self.likeButton = nil;
    self.shotImage = nil;
    self.fbButton = nil;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

    [self releaseOutlets];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)dealloc {
    [fbParams release];
    [appDelegate release];
    [shotRecord release];
    [headingText release];
    [self releaseOutlets];
    [super dealloc];
}


@end
