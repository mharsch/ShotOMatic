//
//  RootViewController.m
//  ShotOMatic
//
//  Created by Michael Harsch on 2/10/11.
//  Copyright 2011 Harsch Systems Inc. All rights reserved.
//

#import "RootViewController.h"
#import "SplashViewController.h"
#import "ShotPickViewController.h"
#import "PagedResultsViewController.h"
#import "Constants.h"
#import "ShotDB.h"
#import "SearchViewController.h"
#import "AboutViewController.h"
#import "FlurryAnalytics.h"
#import "DoubleFlipViewController.h"
#import "FavoritesViewController.h"


@implementation RootViewController

@synthesize goAgain,goAgainCategory;

#pragma mark -
#pragma mark View lifecycle

- (void)splashTakeDown
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)pushSearchView
{
    SearchViewController *tmpSVC = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
    
    [UIView transitionWithView:self.navigationController.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{ 
                        [self.navigationController pushViewController:tmpSVC animated:NO];
                    }
                    completion:NULL];
    
    [tmpSVC release];
    
    if (analyticsEnabled) {
        dispatch_queue_t tmpQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        dispatch_async(tmpQueue, ^{
            [FlurryAnalytics logEvent:@"Search Mode"];
        });
    }
    
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        exit(1);
    } else if (buttonIndex == 1) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:@"AgeConfirmed"];
        [defaults synchronize];
        [self performSelector:@selector(splashTakeDown) withObject:nil afterDelay:1.25];
        return;
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

- (void)viewDidLoad {
	
	[super viewDidLoad];
    
    // This will customize our Navigation bar background if we're running iOS5 
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"woodnavbar.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
    UIBarButtonItem *searchButtonItem = [[UIBarButtonItem alloc] 
                                         initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(pushSearchView)];
    self.navigationItem.leftBarButtonItem = searchButtonItem;
    [searchButtonItem release];
/*
    UIButton *heartButton = [UIButton buttonWithType:UIButtonTypeCustom];
    heartButton.frame = CGRectMake(0, 0, 42, 30);
    [heartButton setImage:[UIImage imageNamed:@"heartbutton.png"] forState:UIControlStateNormal];
    [heartButton setImage:[UIImage imageNamed:@"heartbutton_clicked.png"] forState:UIControlStateHighlighted];
    
    UIBarButtonItem *heartBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:heartButton];
    [heartButton addTarget:self action:@selector(pushFavoritesView) forControlEvents:UIControlEventTouchUpInside];
 */
    UIBarButtonItem *heartButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"alphasearch.png"] style:UIBarButtonItemStylePlain target:self action:@selector(pushFavoritesView)];
    
    
    self.navigationItem.rightBarButtonItem = heartButton;
    // self.navigationItem.rightBarButtonItem = heartBarButtonItem;
    
    [heartButton release];
    
    //Custom button in titleView (center) position
    UIButton *logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    logoButton.frame = CGRectMake(0, 0, 68, 39);
    [logoButton setImage:[UIImage imageNamed:@"logobutton.png"] forState:UIControlStateNormal];
    [logoButton setImage:[UIImage imageNamed:@"logobutton_clicked.png"] forState:UIControlStateHighlighted];
    
    [logoButton addTarget:self action:@selector(pushAboutView) forControlEvents:UIControlEventTouchUpInside];
        
    self.navigationItem.titleView = logoButton;
    
    self.navigationItem.title = nil;
    
	SplashViewController *splashvc = [[SplashViewController alloc] init];
	splashvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentModalViewController:splashvc animated:NO];
	[splashvc release];
	
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"App Contains Alcohol-Related Content"
                              message:@"I attest to being 21 or of legal drinking age"
                              delegate:self
                              cancelButtonTitle:@"Quit App"
                              otherButtonTitles:@"Confirm", nil];

	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"AgeConfirmed"]) {
		[alertView show];
	} else {
        [self performSelector:@selector(splashTakeDown) withObject:nil afterDelay:1.75];
    }
    
    [alertView release];
    
	if (!model) {
		model = [ShotDB instance];
	}

}

- (void)loadCategory:(NSString *)category animated:(BOOL)animated
{
    
	NSSet *tmpSet = [model pickShotGroup:numPages withCategory:category];
	
	PagedResultsViewController *prvc = [[PagedResultsViewController alloc] initWithNibName:nil bundle:nil];
    prvc.category = category;
	prvc.resultSet = tmpSet;
    if (animated) {
        [UIView transitionWithView:self.navigationController.view duration:0.35 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{ 
                            [self.navigationController pushViewController:prvc animated:NO];
                        }
                        completion:NULL
         ];
    } else {
        [self.navigationController pushViewController:prvc animated:NO];
    }
	[prvc release];
}

- (void)loadRandomShot
{
    ShotRecord *tmpRecord = [model pickAShot];
    UIImage *tmpImage = nil;
    
    if ([[ShotDB instance].favoriteSet containsObject:tmpRecord.name]) {
        tmpRecord.favorite = YES;
    }
	
	ShotPickViewController *spvc = [[ShotPickViewController alloc] init];
	spvc.shotRecord = tmpRecord;
	
	spvc.headingText = @"Your Random Shot";
    
    if ([tmpRecord.category isEqualToString:@"Pro Shots"]) {
        tmpImage = [UIImage imageNamed:@"proshot.png"];
    } else if ([tmpRecord.category isEqualToString:@"Rookie Shots"]) {
        tmpImage = [UIImage imageNamed:@"rookieshot.png"];
    } else if ([tmpRecord.category isEqualToString:@"Daredevil Shots"]) {
        tmpImage = [UIImage imageNamed:@"daredevilshot.png"];
    }
    
    [spvc.shotImage setImage:tmpImage];
    [spvc.shotImage  setNeedsDisplay];
    
    //Nested Flip animations for 'double flip' effect
    DoubleFlipViewController *tmpDFVC = [[DoubleFlipViewController alloc] init];
    
    [UIView transitionWithView:self.navigationController.view duration:0.35 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{ 
                        [self.navigationController setNavigationBarHidden:YES];
                        [self.navigationController pushViewController:tmpDFVC animated:NO];
                    }
                    completion:^(BOOL completed){
                        [self.navigationController setNavigationBarHidden:NO];
                        [self.navigationController popViewControllerAnimated:NO];
                        [UIView transitionWithView:self.navigationController.view duration:0.35 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionTransitionFlipFromRight
                                        animations:^{
                                            [self.navigationController pushViewController:spvc animated:NO];
                                        }
                                        completion:NULL
                            ];
    }];

    [tmpDFVC release];
    [spvc release];    

}

- (IBAction)categoryButtonPressed:(UIButton *)sender
{
    NSString *tmpMessage = [NSString stringWithFormat:@"Category Picked - %@",[sender currentTitle]];
    
    if (analyticsEnabled) {
        dispatch_queue_t tmpQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        dispatch_async(tmpQueue, ^{
            [FlurryAnalytics logEvent:tmpMessage];
        });
    }
    
    
    [self loadCategory:[sender currentTitle] animated:YES];
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
    
    if (self.goAgain) {
        self.goAgain = NO;
        // Don't animate this transition if we're 'going again'
        if ([self.goAgainCategory isEqualToString:@"Random Shot"]) {
            [self loadRandomShot];
        } else {
            [self loadCategory:self.goAgainCategory animated:NO];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self resignFirstResponder];
	[super viewWillDisappear:animated];
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (analyticsEnabled) {
        dispatch_queue_t tmpQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        dispatch_async(tmpQueue, ^{
            [FlurryAnalytics logEvent:@"Shook for Random Shot"];
        });
    }
    
    [self loadRandomShot];
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

