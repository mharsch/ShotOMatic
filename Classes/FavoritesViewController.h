//
//  FavoritesViewController.h
//  ShotOMatic
//
//  Created by Michael Harsch on 3/14/11.
//  Copyright 2011 Harsch Systems Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FavoritesViewController : UITableViewController {
    NSArray *listContent;
}

@property (nonatomic, retain) NSArray *listContent;

@end
