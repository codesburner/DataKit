//
//  DKEntityTableView.h
//  DataKit
//
//  Created by Erik Aigner on 05.03.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DKQuery.h"

@interface DKEntityTableViewController : UITableViewController
@property (nonatomic, assign) Class entityClass;
@property (nonatomic, readonly) NSArray *entities;
@property (nonatomic, copy) NSString *displayedKey;
@property (nonatomic, assign) NSUInteger objectsPerPage;
@property (nonatomic, readonly) NSUInteger numberOfDisplayedPages;
@property (nonatomic, readonly) BOOL isLoading;

- (id)initWithEntityName:(Class)entityClass;
- (id)initWithStyle:(UITableViewStyle)style entityClass:(Class)entityClass;

- (DKQuery *)query;
- (void)reset;
- (void)loadAndAppendNextPage;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)nextPageCellForTableView:(UITableView *)tableView;

@end
