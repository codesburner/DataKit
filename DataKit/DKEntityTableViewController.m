//
//  DKEntityTableViewController.m
//  DataKit
//
//  Created by Erik Aigner on 05.03.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKEntityTableViewController.h"

#import "DKEntity.h"

@interface DKEntityTableViewController ()
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) NSUInteger currentOffset;
@property (nonatomic, strong, readwrite) NSMutableArray *entities;
@end

@interface DKEntityTableNextPageCell : UITableViewCell
@property (nonatomic, strong) UIActivityIndicatorView *activityAccessoryView;
@end

@implementation DKEntityTableViewController
DKSynthesize(entityName)
DKSynthesize(displayedKey)
DKSynthesize(query)
DKSynthesize(objectsPerPage)
DKSynthesize(numberOfDisplayedPages)
DKSynthesize(isLoading)
DKSynthesize(entities)
DKSynthesize(hasMore)
DKSynthesize(currentOffset)

- (id)initWithEntityName:(NSString *)entityName {
  return [self initWithStyle:UITableViewStylePlain entityName:entityName];
}

- (id)initWithStyle:(UITableViewStyle)style entityName:(NSString *)entityName {
  self = [super initWithStyle:style];
  if (self) {
    self.hasMore = YES;
    self.objectsPerPage = 25;
    self.currentOffset = 0;
    self.entityName = entityName;
    self.entities = [NSMutableArray new];
    
    // Init query
    DKQuery *q = [DKQuery queryWithEntityName:entityName];
    [q orderDescendingByKey:@"_id"];
    
    self.query = q;
  }
  return self;
}

- (void)appendNextPageWithFinishCallback:(void (^)(void))callback {
  DKQuery *q = self.query;
  q.skip = self.currentOffset;
  q.limit = self.objectsPerPage;
  
  [q findAllInBackgroundWithBlock:^(NSArray *results, NSError *error) {
    if (results.count > 0) {
      [self.entities addObjectsFromArray:results];
      self.currentOffset += results.count;
      self.hasMore = (results.count == self.objectsPerPage);
    }
    
    if (error != nil) {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                      message:error.localizedDescription
                                                     delegate:nil
                                            cancelButtonTitle:nil
                                            otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
      [alert show];
    }
    
    [self.tableView reloadData];
    
    if (callback != NULL) {
      callback();
    }
  }];
}

- (void)reload {
  self.hasMore = YES;
  self.currentOffset = 0;
  [self.entities removeAllObjects];
  [self appendNextPageWithFinishCallback:NULL];
}

- (BOOL)isNextPageCellIndexPath:(NSIndexPath *)indexPath {
  return (self.hasMore && (indexPath.row == self.entities.count));
}

- (void)loadNextPageWithNextPageCell:(DKEntityTableNextPageCell *)cell {
  [cell.activityAccessoryView startAnimating];
  [cell setNeedsDisplay];
  [cell setNeedsLayout];
  
  [self appendNextPageWithFinishCallback:^{
    [cell.activityAccessoryView stopAnimating];
  }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.entities.count + (self.hasMore ? 1 : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([self isNextPageCellIndexPath:indexPath]) {
    return [self nextPageCellForTableView:tableView];
  }
  
  static NSString *identifier = @"DKEntityTableCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  
  if (self.displayedKey != nil) {
    DKEntity *entity = [self.entities objectAtIndex:indexPath.row];
    cell.textLabel.text = [entity objectForKey:self.displayedKey];
  }
  
  return cell;
}

- (UITableViewCell *)nextPageCellForTableView:(UITableView *)tableView {
  static NSString *identifier = @"DKEntityTableNextPageCell";
  DKEntityTableNextPageCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  if (cell == nil) {
    cell = [[DKEntityTableNextPageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  
  cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%i more ...", nil), self.objectsPerPage];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([self isNextPageCellIndexPath:indexPath]) {
    DKEntityTableNextPageCell *cell = (id)[tableView cellForRowAtIndexPath:indexPath];
    [self loadNextPageWithNextPageCell:cell];
  }
}

@end

@implementation DKEntityTableNextPageCell
DKSynthesize(activityAccessoryView)

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    UIActivityIndicatorView *accessoryView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    accessoryView.hidesWhenStopped = YES;
    
    self.activityAccessoryView = accessoryView;
    self.accessoryView = self.activityAccessoryView;
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  UIFont *font = self.textLabel.font;
  NSString *text = self.textLabel.text;
  
  CGRect bounds = self.bounds;
  CGSize textSize = [text sizeWithFont:font
                              forWidth:CGRectGetWidth(bounds)
                         lineBreakMode:UILineBreakModeTailTruncation];
  
  CGRect frame = CGRectMake((CGRectGetWidth(bounds) - textSize.width) / 2.0,
                            (CGRectGetHeight(bounds) - textSize.height) / 2.0,
                            textSize.width,
                            textSize.height);
  
  self.textLabel.frame = frame;
}

@end