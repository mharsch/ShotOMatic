//
//  ShotPickViewController.h
//  ShotOMatic
//
//  Created by Michael Harsch on 2/10/11.
//  Copyright 2011 Harsch Systems Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShotRecord.h"
#import "TiltedShotViewController.h"
#import "ShotOMaticAppDelegate.h"

@interface ShotPickViewController : UIViewController <FBRequestDelegate,UIAlertViewDelegate> {    
	UILabel *shotName;
	UITextView *shotDescription;
	UILabel *shotHeading;
	UIButton *likeButton;
    UIButton *fbButton;
    UIButton *tweetButton;
    UILabel *shareLabel;
    NSMutableDictionary *fbParams;
	ShotRecord *shotRecord;
    NSString *headingText;
    UIImageView *shotImage;
    BOOL showingTiltedView;
    BOOL subordinate;
    ShotOMaticAppDelegate *appDelegate;
}

@property (retain) IBOutlet UILabel *shotName;
@property (retain) IBOutlet UITextView *shotDescription;
@property (retain) IBOutlet UILabel *shotHeading;
@property (retain) IBOutlet UIButton *likeButton;
@property (retain) IBOutlet UIButton *fbButton;
@property (retain) IBOutlet UIButton *tweetButton;
@property (retain) IBOutlet UILabel *shareLabel;
@property (retain) NSMutableDictionary *fbParams;
@property (retain) ShotRecord *shotRecord;
@property (retain) NSString *headingText;
@property (retain) IBOutlet UIImageView *shotImage;
@property BOOL subordinate;
@property (retain) ShotOMaticAppDelegate *appDelegate;

- (IBAction)likeButtonPressed:(UIButton *)sender;
- (IBAction)fbButtonPressed:(UIButton *)sender;

- (void)doFBPost;
@end
