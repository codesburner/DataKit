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
@property (nonatomic, strong, readwrite) NSMutableArray *objects;
@end

@interface DKEntityTableNextPageCell : UITableViewCell
@property (nonatomic, strong) UIActivityIndicatorView *activityAccessoryView;
@end

@implementation DKEntityTableViewController
DKSynthesize(entityName)
DKSynthesize(displayedTitleKey)
DKSynthesize(displayedImageKey)
DKSynthesize(objectsPerPage)
DKSynthesize(isLoading)
DKSynthesize(objects)
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
    self.objects = [NSMutableArray new];
  }
  return self;
}

- (void)processQueryResults:(NSArray *)results error:(NSError *)error callback:(void (^)(NSError *error))callback {
  if (results != nil && ![results isKindOfClass:[NSArray class]]) {
    [NSException raise:NSInternalInconsistencyException
                format:NSLocalizedString(@"Query did not return a result NSArray or nil", nil)];
    return;
  } else if ([results isKindOfClass:[NSArray class]]) {
    for (id object in results) {
      if (!([object isKindOfClass:[DKEntity class]] || [object isKindOfClass:[NSDictionary class]])) {
        [NSException raise:NSInternalInconsistencyException
                    format:NSLocalizedString(@"Query results contained invalid objects", nil)];
        return;
      }
    }
  }
  
  if (results.count > 0) {
    [self.objects addObjectsFromArray:results];  
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
}

- (void)appendNextPageWithFinishCallback:(void (^)(NSError *error))callback {
  callback = [callback copy];
  DKQuery *q = [self tableQuery];
  q.skip = self.currentOffset;
  q.limit = self.objectsPerPage;
  
  self.isLoading = YES;
  self.tableView.userInteractionEnabled = NO;
  
  DKMapReduce *mr = [self queryMapReduce];
  if (mr != nil) {
    [q performMapReduce:mr inBackgroundWithBlock:^(id result, NSError *error) {
      [self processQueryResults:result error:error callback:callback];
    }];
  }
  else {
    [q findAllInBackgroundWithBlock:^(NSArray *results, NSError *error) {
      [self processQueryResults:results error:error callback:callback];
    }];
  }
}

- (void)reloadInBackground {
  [self reloadInBackgroundWithBlock:NULL];
}

- (void)reloadInBackgroundWithBlock:(void (^)(NSError *))block {
  self.hasMore = YES;
  self.currentOffset = 0;
  [self.objects removeAllObjects];
  [self appendNextPageWithFinishCallback:block];
}

- (DKQuery *)tableQuery {
  DKQuery *q = [DKQuery queryWithEntityName:self.entityName];
  [q orderDescendingByCreationDate];
  
  return q;
}

- (DKMapReduce *)queryMapReduce {
  return nil;
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

- (BOOL)tableViewCellIsNextPageCellAtIndexPath:(NSIndexPath *)indexPath {
  return (self.hasMore && (indexPath.row == self.objects.count));
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.objects.count + (self.hasMore ? 1 : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([self tableViewCellIsNextPageCellAtIndexPath:indexPath]) {
    return [self tableViewNextPageCell:tableView];
  }
  
  id object = [self.objects objectAtIndex:indexPath.row];
  
  static NSString *identifier = @"DKEntityTableCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  
  if (self.displayedTitleKey.length > 0) {
    // DKEntity and NSDictionary both implement objectForKey
    cell.textLabel.text = [object objectForKey:self.displayedTitleKey];
  }
  if (self.displayedImageKey.length > 0) {
    // DKEntity and NSDictionary both implement objectForKey
    cell.imageView.image = [UIImage imageWithData:[object objectForKey:self.displayedImageKey]];
  }
  
  return cell;
}

- (UITableViewCell *)tableViewNextPageCell:(UITableView *)tableView {
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
  if ([self tableViewCellIsNextPageCellAtIndexPath:indexPath]) {
    DKEntityTableNextPageCell *cell = (id)[tableView cellForRowAtIndexPath:indexPath];
    [self loadNextPageWithNextPageCell:cell];
  }
  else {
    [self tableView:tableView didSelectRowAtIndexPath:indexPath object:[self.objects objectAtIndex:indexPath.row]];
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath object:(id)object {
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