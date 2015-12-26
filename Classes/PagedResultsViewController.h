//
//  PagedResultsViewController.h
//  ShotOMatic
//
//  Created by Michael Harsch on 2/10/11.
//  Copyright 2011 Harsch Systems Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "GoAgainViewController.h"
#import "TiltedShotViewController.h"
#import "PageControl.h"

@interface PagedResultsViewController : UIViewController <UIScrollViewDelegate,GoAgainDelegate,PageControlDelegate,BannerViewContainer>
{
	UIScrollView *scrollView;
	NSSet *resultSet;
	NSArray *viewControllers;
	BOOL pageControlUsed;
    NSString *category;
    PageControl *customPageControl;
    BOOL showingTiltedView;
    BOOL subordinate;
    ADBannerView *_bannerView;
    ShotOMaticAppDelegate *appDelegate;
}
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) NSSet *resultSet;
@property (retain) NSString *category;
@property (nonatomic, retain) PageControl *customPageControl;
@property (retain) NSArray *viewControllers;
@property BOOL subordinate;
@property (nonatomic, retain) ADBannerView *_bannerView;
@property (nonatomic, retain) ShotOMaticAppDelegate *appDelegate;

- (void)loadScrollView;
- (void)setupMainView;
- (void)goAgainWithCategory:(NSString *)category;
- (void)pageControlPageDidChange:(PageControl *)pageControl;
@end
