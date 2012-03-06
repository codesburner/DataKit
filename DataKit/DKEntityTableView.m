//
//  DKEntityTableView.m
//  DataKit
//
//  Created by Erik Aigner on 05.03.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKEntityTableView.h"

@implementation DKEntityTableViewController
DKSynthesize(entityClass)
DKSynthesize(entities)
DKSynthesize(displayedKey)
DKSynthesize(objectsPerPage)
DKSynthesize(numberOfDisplayedPages)
DKSynthesize(isLoading)

- (id)initWithEntityName:(Class)entityClass {
  return [self initWithStyle:UITableViewStylePlain entityClass:entityClass];
}

- (id)initWithStyle:(UITableViewStyle)style entityClass:(Class)entityClass {
  self = [super initWithStyle:style];
  if (self) {
    self.entityClass = entityClass;
  }
  return self;
}

- (DKQuery *)query {
  return nil;
}

- (void)reset {
  
}

- (void)loadAndAppendNextPage {
  
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)nextPageCellForTableView:(UITableView *)tableView {
  return nil;
}

@end
