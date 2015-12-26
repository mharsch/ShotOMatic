//
//  FavoritesViewController.m
//  ShotOMatic
//
//  Created by Michael Harsch on 3/14/11.
//  Copyright 2011 Harsch Systems Inc. All rights reserved.
//

#import "FavoritesViewController.h"
#import "ShotRecord.h"
#import "ShotDB.h"
#import "ShotPickViewController.h"
#import "Constants.h"
#import "FlurryAnalytics.h"
#import "AboutViewController.h"
#import "FavoritesViewController.h"

@implementation FavoritesViewController

@synthesize listContent;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [listContent release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];    
    
    //Custom button in titleView position
    UIButton *logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    logoButton.frame = CGRectMake(0, 0, 68, 39);
    [logoButton setImage:[UIImage imageNamed:@"logobutton.png"] forState:UIControlStateNormal];
    [logoButton setImage:[UIImage imageNamed:@"logobutton_clicked.png"] forState:UIControlStateHighlighted];
    
    [logoButton addTarget:self action:@selector(pushAboutView) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.titleView = logoButton;
    
    self.navigationItem.title = nil;

    NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:15];
    
    for (ShotRecord *tmpRecord in [ShotDB instance].shotRecordList) {
        if (tmpRecord.favorite)
            [tmpArray addObject:tmpRecord];
    }
    
    self.listContent = [NSArray arrayWithArray:tmpArray];
    
    [self.tableView reloadData];
	self.tableView.scrollEnabled = YES;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.listContent = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.listContent count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    ShotRecord *record = nil;
    record = [self.listContent objectAtIndex:indexPath.row];
	
	cell.textLabel.text = record.name;

	return cell;

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Returns section title based on physical state: [solid, liquid, gas, artificial]
    
    return @"Your Favorites";
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShotRecord *tmpRecord = nil;
    
	tmpRecord = [self.listContent objectAtIndex:indexPath.row];

    UIImage *tmpImage = nil;
    
    if ([[ShotDB instance].favoriteSet containsObject:tmpRecord.name]) {
        tmpRecord.favorite = YES;
    }
	
	ShotPickViewController *spvc = [[ShotPickViewController alloc] init];
	spvc.shotRecord = tmpRecord;
	
	spvc.headingText = @"Your Selected Shot";
    
    if ([tmpRecord.category isEqualToString:@"Pro Shots"]) {
        tmpImage = [UIImage imageNamed:@"proshot.png"];
    } else if ([tmpRecord.category isEqualToString:@"Rookie Shots"]) {
        tmpImage = [UIImage imageNamed:@"rookieshot.png"];
    } else if ([tmpRecord.category isEqualToString:@"Daredevil Shots"]) {
        tmpImage = [UIImage imageNamed:@"daredevilshot.png"];
    } else {
        //Couldn't match category - shouldn't reach here
    }
    
    [spvc.shotImage setImage:tmpImage];
    [spvc.shotImage  setNeedsDisplay];
    
    
	[self.navigationController pushViewController:spvc animated:YES];
	[spvc release];
    
    NSDictionary *tmpDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Shot Name", tmpRecord.name, nil];
    
    if (analyticsEnabled) {
        dispatch_queue_t tmpQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        dispatch_async(tmpQueue, ^{
            [FlurryAnalytics logEvent:@"Favorite Shot Viewed" withParameters:tmpDictionary];
        });
    }
    
}

@end
