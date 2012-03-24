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

/**
 A table view to display a specified entity paginated
 */
@interface DKEntityTableViewController : UITableViewController

/** @name Initializing Entity Tables */

/**
 Initializes a new entity table for the specified entity
 @param entityName The entity name displayed in the table
 @return The initialized entity table
 */
- (id)initWithEntityName:(NSString *)entityName;

/**
 Initializes a new entity table for the specified entity
 @param style The table view style
 @param entityName The entity name displayed in the table
 @return The initialized entity table
 */
- (id)initWithStyle:(UITableViewStyle)style entityName:(NSString *)entityName;

/** @name Configuration */

/**
 The entity name used for the table
 */
@property (nonatomic, copy) NSString *entityName;

/**
 The entity key to use for the cell title text
 */
@property (nonatomic, copy) NSString *displayedTitleKey;

/**
 The entity key to use for the cell image data
 */
@property (nonatomic, copy) NSString *displayedImageKey;

/**
 The number of objects displayed per page
 */
@property (nonatomic, assign) NSUInteger objectsPerPage;

/**
 If the table view is currently fetching a page
 */
@property (nonatomic, assign, readonly) BOOL isLoading;

/**
 The currently loaded objects
 
 Objects can be either of type <DKEntity> or NSDictionary
 */
@property (nonatomic, strong, readonly) NSMutableArray *objects;

/** @name Reloading */

/**
 Reloads the table in the background
 */
- (void)reloadInBackground;

/**
 Reloads the table in the background
 @param block The block that is called when the reload finished.
 */
- (void)reloadInBackgroundWithBlock:(void (^)(NSError *error))block;

/** @name Methods to Override */

/**
 Specify a custom query by overriding this method
 @return The query to use for the tables objects
 */
- (DKQuery *)tableQuery;

/**
 Specify a map reduce operation for the query by overriding this method
 
 Make sure the map reduce returns an array of NSDictionaries so the entity table can interprete the results as entities. You can do so by setting an appropriate result processor block on the map reduce. If <tableQuery> returns `nil` this method won't be called.
 @return The map reduce to use to display the table objects
 */
- (DKMapReduce *)tableQueryMapReduce;

/**
 Determines if the cell at the index path is a next-page cell
 @param indexPath The cell index path to check.
 @return NO if the cell represents a <DKEntity>, YES if it is the next-page cell.
 */
- (BOOL)tableViewCellIsNextPageCellAtIndexPath:(NSIndexPath *)indexPath;

/**
 Returns the cell for the given index path
 @param tableView The calling table view
 @param indexPath The index path for the cell
 @return The initialized or dequeued table cell
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 Returns the cell used as the next-page cell
 @param tableView The calling table view
 @return The initialized or dequeued next-page cell
 */
- (UITableViewCell *)tableViewNextPageCell:(UITableView *)tableView;

/**
 Called when a table row is selected
 @param tableView The calling table view
 @param indexPath The index path of the selected row
 @param object The selected object. Can be of type <DKEntity> or NSDictionary.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath object:(id)object;

@end
