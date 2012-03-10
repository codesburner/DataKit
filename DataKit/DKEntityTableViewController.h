//
//  DKEntityTableViewController.h
//  DataKit
//
//  Created by Erik Aigner on 05.03.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DKQuery.h"
#import "DKEntity.h"

@interface DKEntityTableViewController : UITableViewController
@property (nonatomic, copy) NSString *entityName;
@property (nonatomic, copy) NSString *displayedTitleKey;
@property (nonatomic, copy) NSString *displayedImageKey;
@property (nonatomic, assign) NSUInteger objectsPerPage;
@property (nonatomic, readonly) NSUInteger numberOfDisplayedPages;
@property (nonatomic, assign, readonly) BOOL isLoading;
@property (nonatomic, strong, readonly) NSMutableArray *entities;

- (id)initWithEntityName:(NSString *)entityName;
- (id)initWithStyle:(UITableViewStyle)style entityName:(NSString *)entityName;

- (void)reloadInBackground;
- (void)reloadInBackgroundWithBlock:(void (^)(NSError *error))block;
- (DKQuery *)tableQuery;

- (BOOL)tableViewCellIsNextPageCellAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)tableViewNextPageCell:(UITableView *)tableView;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end
