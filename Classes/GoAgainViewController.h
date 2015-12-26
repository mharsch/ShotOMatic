//
//  GoAgainViewController.h
//  ShotOMatic
//
//  Created by Michael Harsch on 2/27/11.
//  Copyright 2011 Harsch Systems Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GoAgainDelegate
- (void)goAgainWithCategory:(NSString *)category;
@end

@interface GoAgainViewController : UIViewController {
    NSString *headingText;
    UILabel *headingLabel;
    id <GoAgainDelegate> delegate;
    NSString *category;
    UIButton *goAgainButton;
    NSString *buttonText;
}

@property (retain) IBOutlet NSString *headingText;
@property (retain) IBOutlet UILabel *headingLabel;
@property (assign) id <GoAgainDelegate> delegate;
@property (retain) NSString *category;
@property (retain) IBOutlet UIButton *goAgainButton;
@property (retain) NSString *buttonText;

- (IBAction)goAgainButtonPressed:(UIButton *)sender;
@end
