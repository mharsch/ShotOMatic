//
//  GoAgainViewController.m
//  ShotOMatic
//
//  Created by Michael Harsch on 2/27/11.
//  Copyright 2011 Harsch Systems Inc. All rights reserved.
//

#import "GoAgainViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "FlurryAnalytics.h"

@implementation GoAgainViewController
@synthesize headingText;
@synthesize headingLabel;
@synthesize delegate;
@synthesize category;
@synthesize goAgainButton,buttonText;

- (IBAction)goAgainButtonPressed:(UIButton *)sender
{
    NSString *tmpMessage = [NSString stringWithFormat:@"Go Again w/Category - %@", self.category];
    
    if (analyticsEnabled) {
        dispatch_queue_t tmpQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        dispatch_async(tmpQueue, ^{
            [FlurryAnalytics logEvent:tmpMessage];
        });
    }
    
    [self.delegate goAgainWithCategory:self.category];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.headingLabel setText:self.headingText];

    self.goAgainButton.contentMode = UIViewContentModeScaleToFill;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)releaseOutlets
{
    self.headingLabel = nil;
    self.goAgainButton = nil;
}

- (void)viewDidUnload
{
    [self releaseOutlets];
    [super viewDidUnload];
}

- (void)dealloc
{
    [buttonText release];
    [headingText release];
    [category release];
    [self releaseOutlets];
    [super dealloc];
}
@end
