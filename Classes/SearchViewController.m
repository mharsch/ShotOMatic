//
//  SearchViewController.m
//  ShotOMatic
//
//  Created by Michael Harsch on 3/6/11.
//  Copyright 2011 Harsch Systems Inc. All rights reserved.
// 

#import "SearchViewController.h"
#import "ShotDB.h"
#import "ShotRecord.h"
#import "ShotPickViewController.h"
#import "Constants.h"
#import "FlurryAnalytics.h"
#import "AboutViewController.h"
#import "FavoritesViewController.h"


@implementation SearchViewController

@synthesize listContent,filteredListContent,otherFilteredListContent,savedSearchTerm,searchWasActive;


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

- (void)dealloc
{
    self.searchDisplayController.delegate = nil;
    self.searchDisplayController.searchResultsDelegate = nil;
    self.searchDisplayController.searchResultsDataSource = nil;
    [listContent release];
	[filteredListContent release];
    [otherFilteredListContent release];
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

    
    if (!model)
        model = [ShotDB instance];
    
    self.listContent = model.shotRecordList;
    
    self.filteredListContent = [NSMutableArray arrayWithCapacity:[self.listContent count]];
    self.otherFilteredListContent = [NSMutableArray arrayWithCapacity:[self.listContent count]];
    
    // restore search settings if they were saved in didReceiveMemoryWarning.
    if (self.savedSearchTerm)
	{
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setText:savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
	
	[self.tableView reloadData];
	self.tableView.scrollEnabled = YES;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.filteredListContent = nil;
    //self.listContent = nil;
    self.otherFilteredListContent = nil;
    self.savedSearchTerm = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    //[self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	/*
	 If the requesting table view is the search display controller's table view, return the count of
     the filtered list, otherwise return the count of the main list.
	 */
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        if (section == 0) {
            return [self.filteredListContent count];
        } else {
            return [self.otherFilteredListContent count];
        }
    }
	else
	{
        return [self.listContent count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellID = @"cellID";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	/*
	 If the requesting table view is the search display controller's table view, configure the cell using the filtered content, otherwise use the main list.
	 */
	ShotRecord *record = nil;
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        if (indexPath.section == 0) {
            record = [self.filteredListContent objectAtIndex:indexPath.row];
        } else {
            record = [self.otherFilteredListContent objectAtIndex:indexPath.row];
        }
    }
	else
	{
        record = [self.listContent objectAtIndex:indexPath.row];
    }
	
	cell.textLabel.text = record.name;
	return cell;

}


- (void)filterContentForSearchText:(NSString *)searchText
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	
	[self.filteredListContent removeAllObjects]; // First clear the filtered array.
    [self.otherFilteredListContent removeAllObjects];
	
	/*
	 Search the main list for products whose name matches searchText; add items that match to the filtered array.
	 */
	for (ShotRecord *record in listContent)
	{
        if (!([[record.name lowercaseString] rangeOfString:[searchText lowercaseString]].location == NSNotFound))
        {
            [self.filteredListContent addObject:record];
        }
        
        if (!([[record.description lowercaseString] rangeOfString:[searchText lowercaseString]].location == NSNotFound)) {
            [self.otherFilteredListContent addObject:record];
        }

	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Returns section title based on physical state: [solid, liquid, gas, artificial]

    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (section == 0) {
            return @"Shot Names";
        } else {
            return @"Shot Contents";
        }
    } else {
        return @"All Shots";
    }

}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString];    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    ShotRecord *tmpRecord = nil;
    
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (indexPath.section == 0) {
            tmpRecord = [self.filteredListContent objectAtIndex:indexPath.row];
        } else {
            tmpRecord = [self.otherFilteredListContent objectAtIndex:indexPath.row];
        }
        
    } else {
        tmpRecord = [self.listContent objectAtIndex:indexPath.row];
    }

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
        NSLog(@"Couldn't match shot category for shot image");
    }
    
    [spvc.shotImage setImage:tmpImage];
    [spvc.shotImage  setNeedsDisplay];
    
    
	[self.navigationController pushViewController:spvc animated:YES];
	[spvc release];
    
    NSDictionary *tmpDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Shot Name", tmpRecord.name, nil];
    
    if (analyticsEnabled) {
        dispatch_queue_t tmpQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        dispatch_async(tmpQueue, ^{
            [FlurryAnalytics logEvent:@"Shot Found" withParameters:tmpDictionary];
        });
    }
    
}

@end
