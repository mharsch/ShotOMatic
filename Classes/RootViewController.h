//
//  RootViewController.h
//  ShotOMatic
//
//  Created by Michael Harsch on 2/10/11.
//  Copyright 2011 Harsch Systems Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShotDB.h"

@interface RootViewController : UIViewController <UIAlertViewDelegate>
{
	ShotDB *model;
    BOOL goAgain;
    NSString *goAgainCategory;
}

@property BOOL goAgain;
@property (retain) NSString *goAgainCategory;

- (IBAction)categoryButtonPressed:(UIButton *)sender;
- (void)loadCategory:(NSString *)category animated:(BOOL)animated;
- (void)loadRandomShot;
@end
