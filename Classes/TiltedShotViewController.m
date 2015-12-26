//
//  TiltedShotViewController.m
//  ShotOMatic
//
//  Created by Michael Harsch on 2/28/11.
//  Copyright 2011 Harsch Systems Inc. All rights reserved.
//

#import "TiltedShotViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"


@implementation TiltedShotViewController
@synthesize nameText, recipeText, textView, label;
//@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.label setText:self.nameText];
    [self.label setTextColor:UIColorFromRGB(0xCC3813)];
    [self.textView setText:self.recipeText];    
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        return YES;
    } else {
        return NO;
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.textView = nil;
    self.label = nil;
}

@end
