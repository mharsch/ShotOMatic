//
//  PagedResultsViewController.m
//  ShotOMatic
//
//  Created by Michael Harsch on 2/10/11.
//  Copyright 2011 Harsch Systems Inc. All rights reserved.
//

#import "ShotPickViewController.h"
#import "PagedResultsViewController.h"
#import "Constants.h"
#import "ShotDB.h"
#import "GoAgainViewController.h"
#import "RootViewController.h"
#import "TiltedShotViewController.h"
#import "FlurryAnalytics.h"
#import "AboutViewController.h"
#import "FavoritesViewController.h"

@implementation PagedResultsViewController
@synthesize scrollView, resultSet;
@synthesize viewControllers;
@synthesize category;
@synthesize customPageControl;
@synthesize subordinate;
@synthesize _bannerView;
@synthesize appDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        showingTiltedView = NO;
        subordinate = NO;
    }
    return self;
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

- (void)hasTilted:(NSNotification *)notification
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation) &&
        !showingTiltedView &&
        !self.subordinate &&
        !(self.customPageControl.currentPage >= numPages))
    {
        
        TiltedShotViewController *tmpTSVC = [[TiltedShotViewController alloc] init];
        ShotPickViewController *tmpVC = [self.viewControllers objectAtIndex:self.customPageControl.currentPage];
        tmpTSVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        tmpTSVC.nameText = tmpVC.shotRecord.name;
        tmpTSVC.recipeText = tmpVC.shotRecord.description;
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
    
    self.navigationItem.title = nil;

    
	[self setupMainView];
	[self loadScrollView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hasTilted:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    self.appDelegate = (ShotOMaticAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.appDelegate.currentController = self;
    
    if (self.appDelegate.bannerView.bannerLoaded) {
        [self showBannerView:self.appDelegate.bannerView animated:YES];
    }
    
    [super viewDidLoad];
}


- (void)setupMainView
{

	// a page is the width of the scroll view
	scrollView.pagingEnabled = YES;
	scrollView.showsHorizontalScrollIndicator = NO;
	scrollView.showsVerticalScrollIndicator = NO;
	scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * (numPages+1), scrollView.frame.size.height);
    
    CGRect f = CGRectMake(0, 366, 320, 20); 
    customPageControl = [[PageControl alloc] initWithFrame:f];
    customPageControl.numberOfPages = numPages+1;
    customPageControl.currentPage = 0;
    customPageControl.dotColorCurrentPage = [UIColor whiteColor];
    customPageControl.dotColorOtherPage = [UIColor blackColor];
    customPageControl.delegate = self;
    [self.view addSubview:customPageControl];
}

- (void)loadScrollView
{
	ShotPickViewController *tmpSPVC = nil;
	NSUInteger pageOffset = 0;
	
	NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:numPages+1];
    
	for (ShotRecord *tmpRecord in self.resultSet)
	{
        if ([[ShotDB instance].favoriteSet containsObject:tmpRecord.name]) {
            tmpRecord.favorite = YES;
        }
		tmpSPVC = [[ShotPickViewController alloc] init];
		tmpSPVC.shotRecord = tmpRecord;
        tmpSPVC.headingText = [NSString stringWithFormat:@"Your %@", category];

		CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * pageOffset;
        frame.origin.y = 0;
        tmpSPVC.view.frame = frame;
        
        //Needed so the PRVC will handle rotation
        tmpSPVC.subordinate = YES;
        
        [scrollView addSubview:tmpSPVC.view];
		
		[tmpArray addObject:tmpSPVC];
		[tmpSPVC release];
		
		pageOffset++;
	}
    
    //Go Again View controller goes here
    GoAgainViewController *tmpGAVC = [[GoAgainViewController alloc] init];
	
    tmpGAVC.headingText = [NSString stringWithFormat:@"Your %@", category];
    tmpGAVC.category = category;
    tmpGAVC.buttonText = [NSString stringWithFormat:@"More %@", category];
    tmpGAVC.delegate = self;
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * pageOffset;
    frame.origin.y = 0;
    tmpGAVC.view.frame = frame;
    [scrollView addSubview:tmpGAVC.view];
    
    [tmpArray addObject:tmpGAVC];
    [tmpGAVC release];
    
	self.viewControllers = [NSArray arrayWithArray:tmpArray];

}

- (void)pageControlPageDidChange:(PageControl *)pageControl
{
    int page = pageControl.currentPage;
	
	// update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the PageControl. See scrollViewDidScroll: below.
    pageControlUsed = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)inputScrollView
{
	// We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed)
    {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
	
	// Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = inputScrollView.frame.size.width;
    int page = floor((inputScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    customPageControl.currentPage = page;
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

- (void)layoutAnimated:(BOOL)animated
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGRect bannerFrame = _bannerView.frame;
    if (_bannerView && _bannerView.bannerLoaded) {
        bannerFrame.origin.y = bounds.size.height - 94;
        [UIView animateWithDuration:animated ? 0.75 : 0.0 animations:^{
            _bannerView.frame = bannerFrame;
        }];
        _bannerView.hidden = NO;
    } else {
        bannerFrame.origin.y = bounds.size.height;
        [UIView animateWithDuration:animated ? 0.75 : 0.0 animations:^{
            _bannerView.frame = bannerFrame;
        }];
        _bannerView.hidden = YES;
    }
    

}

- (void)showBannerView:(ADBannerView *)bannerView animated:(BOOL)animated
{
    _bannerView = bannerView;
    _bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    [self.view addSubview:_bannerView];
    [self layoutAnimated:animated];
}

- (void)hideBannerView:(ADBannerView *)bannerView animated:(BOOL)animated
{
    //_bannerView = nil;
    [self layoutAnimated:NO];
}

- (void)viewWillUnload
{
    if (self.appDelegate)
        self.appDelegate.currentController = nil;
    
    if (_bannerView) {
        _bannerView.hidden = YES;
    }
}

- (void)goAgainWithCategory:(NSString *)_category;
{
    NSArray *tmpArray = [self.navigationController viewControllers];
    RootViewController *tmpVC = [tmpArray objectAtIndex:0];

    tmpVC.goAgain = YES;
    tmpVC.goAgainCategory = _category;
    
    if (self.appDelegate)
        self.appDelegate.currentController = nil;
    
    if (_bannerView) {
        _bannerView.hidden = YES;
    }
    
    [self.navigationController popViewControllerAnimated:NO];
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
    //Only allow shaking on 'Go Again' page
    if (self.customPageControl.currentPage >= numPages) {
        
        if (analyticsEnabled) {
            dispatch_queue_t tmpQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
            dispatch_async(tmpQueue, ^{
                [FlurryAnalytics logEvent:@"Shook at 'Go Again' Page"];
            });
        }
        
        [self goAgainWithCategory:@"Random Shot"];
    }
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)releaseOutlets
{
	self.scrollView = nil;
    //self._bannerView = nil;
}

- (void)dealloc {
	[self releaseOutlets];
    [resultSet release];
    [viewControllers release];
    [customPageControl release];
    [category release];
    //[_bannerView release];
    [super dealloc];
}


@end
