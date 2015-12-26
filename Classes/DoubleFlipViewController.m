    //
//  DoubleFlipViewController.m
//  ShotProto
//
//  Created by Michael Harsch on 2/3/11.
//  Copyright 2011 Harsch Systems Inc. All rights reserved.
//

#import "DoubleFlipViewController.h"


@implementation DoubleFlipViewController

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	UIImage *image = [UIImage imageNamed:@"splash.png"];
	imageView = [[UIImageView alloc] initWithImage:image];
	self.view = imageView;
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


- (void)dealloc {
	[imageView release];
    [super dealloc];
}


@end
