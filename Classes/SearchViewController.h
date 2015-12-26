//
//  SearchViewController.h
//  ShotOMatic
//
//  Created by Michael Harsch on 3/6/11.
//  Copyright 2011 Harsch Systems Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShotDB.h"


@interface SearchViewController : UITableViewController <UISearchDisplayDelegate,UISearchBarDelegate>
{
    NSArray			*listContent;			// The master content.
	NSMutableArray	*filteredListContent;	// The content filtered as a result of a search.
    NSMutableArray  *otherFilteredListContent;
	
	// The saved state of the search UI if a memory warning removed the view.
    NSString		*savedSearchTerm;
    BOOL			searchWasActive;
    ShotDB *model;

}
@property (nonatomic, retain) NSArray *listContent;
@property (nonatomic, retain) NSMutableArray *filteredListContent;
@property (nonatomic, retain) NSMutableArray *otherFilteredListContent;


@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) BOOL searchWasActive;


@end
