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
@property (nonatomic, assign, readwrite) BOOL isLoading;
@property (nonatomic, assign) NSUInteger currentOffset;
@property (nonatomic, strong, readwrite) NSMutableArray *entities;
@end

@interface DKEntityTableNextPageCell : UITableViewCell
@property (nonatomic, strong) UIActivityIndicatorView *activityAccessoryView;
@end

@implementation DKEntityTableViewController
DKSynthesize(entityName)
DKSynthesize(displayedTitleKey)
DKSynthesize(displayedImageKey)
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
  }
  return self;
}

- (void)appendNextPageWithFinishCallback:(void (^)(NSError *error))callback {
  DKQuery *q = [self tableQuery];
  q.skip = self.currentOffset;
  q.limit = self.objectsPerPage;
  
  self.isLoading = YES;
  self.tableView.userInteractionEnabled = NO;
  
  [q findAllInBackgroundWithBlock:^(NSArray *results, NSError *error) {
    if (results.count > 0) {
      [self.entities addObjectsFromArray:results];  
    }
    
    self.currentOffset += results.count;
    self.hasMore = (results.count == self.objectsPerPage);
    self.isLoading = NO;
    self.tableView.userInteractionEnabled = YES;
    
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
      callback(error);
    }
  }];
}

- (void)reloadInBackground {
  [self reloadInBackgroundWithBlock:NULL];
}

- (void)reloadInBackgroundWithBlock:(void (^)(NSError *))block {
  self.hasMore = YES;
  self.currentOffset = 0;
  [self.entities removeAllObjects];
  [self appendNextPageWithFinishCallback:block];
}

- (DKQuery *)tableQuery {
  DKQuery *q = [DKQuery queryWithEntityName:self.entityName];
  [q orderDescendingByKey:@"_id"];
  
  return q;
}

- (BOOL)isNextPageCellIndexPath:(NSIndexPath *)indexPath {
  return (self.hasMore && (indexPath.row == self.entities.count));
}

- (void)loadNextPageWithNextPageCell:(DKEntityTableNextPageCell *)cell {
  if (self.isLoading) {
    return;
  }
  [cell.activityAccessoryView startAnimating];
  [cell setNeedsLayout];
  
  [self appendNextPageWithFinishCallback:^(NSError *error){
    [cell.activityAccessoryView stopAnimating];
    [cell setNeedsLayout];
  }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.entities.count + (self.hasMore ? 1 : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([self isNextPageCellIndexPath:indexPath]) {
    return [self nextPageCellForTableView:tableView];
  }
  
  DKEntity *entity = [self.entities objectAtIndex:indexPath.row];
  
  static NSString *identifier = @"DKEntityTableCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  if (cell == nil) {
    cell = [self tableView:tableView setupTableViewCellForEntity:entity reuseIdentifier:identifier];
  }
  
  if (self.displayedTitleKey.length > 0) {
    cell.textLabel.text = [entity objectForKey:self.displayedTitleKey];
  }
  if (self.displayedImageKey.length > 0) {
    cell.imageView.image = [UIImage imageWithData:[entity objectForKey:self.displayedImageKey]];
  }
  
  return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView setupTableViewCellForEntity:(DKEntity *)entity reuseIdentifier:(NSString *)identifier {
  UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
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
  else {
    [self tableView:tableView didSelectRowAtIndexPath:indexPath entity:[self.entities objectAtIndex:indexPath.row]];
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath entity:(DKEntity *)entity {
  // stub
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
    
    [self.contentView addSubview:self.activityAccessoryView];
    
    self.textLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1.0];
    self.textLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    self.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    self.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  // Center text label
  UIFont *font = self.textLabel.font;
  NSString *text = self.textLabel.text;
  
  CGRect bounds = self.bounds;
  CGSize textSize = [text sizeWithFont:font
                              forWidth:CGRectGetWidth(bounds)
                         lineBreakMode:UILineBreakModeTailTruncation];
  CGSize spinnerSize = self.activityAccessoryView.frame.size;
  CGFloat padding = 10.0;
  
  BOOL isAnimating = self.activityAccessoryView.isAnimating;
  
  CGRect textFrame = CGRectMake((CGRectGetWidth(bounds) - textSize.width - (isAnimating ? spinnerSize.width - padding : 0)) / 2.0,
                                (CGRectGetHeight(bounds) - textSize.height) / 2.0,
                                textSize.width,
                                textSize.height);
  
  self.textLabel.frame = CGRectIntegral(textFrame);
  
  if (isAnimating) {
    CGRect spinnerFrame = CGRectMake(CGRectGetMaxX(textFrame) + padding,
                                     (CGRectGetHeight(bounds) - spinnerSize.height) / 2.0,
                                     spinnerSize.width,
                                     spinnerSize.height);
    
    self.activityAccessoryView.frame = spinnerFrame;
  }
}

@end