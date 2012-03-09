//
//  DKEntityTableViewController.h
//  DataKit
//
//  Created by Erik Aigner on 05.03.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DKQuery.h"

@interface DKEntityTableViewController : UITableViewController
@property (nonatomic, copy) NSString *entityName;
@property (nonatomic, copy) NSString *displayedKey;
@property (nonatomic, strong) DKQuery *query;
@property (nonatomic, assign) NSUInteger objectsPerPage;
@property (nonatomic, readonly) NSUInteger numberOfDisplayedPages;
@property (nonatomic, assign, readonly) BOOL isLoading;
@property (nonatomic, strong, readonly) NSMutableArray *entities;

- (id)initWithEntityName:(NSString *)entityName;
- (id)initWithStyle:(UITableViewStyle)style entityName:(NSString *)entityName;

- (void)reload;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)nextPageCellForTableView:(UITableView *)tableView;

@end
