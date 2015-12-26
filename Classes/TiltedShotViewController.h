//
//  TiltedShotViewController.h
//  ShotOMatic
//
//  Created by Michael Harsch on 2/28/11.
//  Copyright 2011 Harsch Systems Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TiltedShotViewController : UIViewController {
    NSString *nameText;
    NSString *recipeText;
    UITextView *textView;
    UILabel *label;
}

@property (retain) NSString *nameText;
@property (retain) NSString *recipeText;
@property (retain) IBOutlet UITextView *textView;
@property (retain) IBOutlet UILabel *label;


@end
