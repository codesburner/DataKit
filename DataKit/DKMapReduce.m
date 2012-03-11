//
//  DKMapReduce.m
//  DataKit
//
//  Created by Erik Aigner on 11.03.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKMapReduce.h"

@interface DKMapReduce ()
@property (nonatomic, copy, readwrite) NSString *entityName;
@property (nonatomic, copy) NSString *mapFunc;
@property (nonatomic, copy) NSString *reduceFunc;
@property (nonatomic, copy) NSString *finalizeFunc;
@end

@implementation DKMapReduce
DKSynthesize(entityName)
DKSynthesize(context)
DKSynthesize(mapFunc)
DKSynthesize(reduceFunc)
DKSynthesize(finalizeFunc)

static dispatch_queue_t kDKMapReduceQueue_;

+ (void)initialize {
  kDKMapReduceQueue_ = dispatch_queue_create("mapreduce queue", DISPATCH_QUEUE_SERIAL);
}

+ (DKMapReduce *)mapReduceWithEntityName:(NSString *)entityName {
  return [[self alloc] initWithEntityName:entityName];
}

- (id)initWithEntityName:(NSString *)entityName {
  self = [super init];
  if (self) {
    self.entityName = entityName;
  }
  return self;
}

- (void)map:(NSString *)mapFunc reduce:(NSString *)reduceFunc {
  [self map:mapFunc reduce:reduceFunc finalize:nil];
}

- (void)map:(NSString *)mapFunc reduce:(NSString *)reduceFunc finalize:(NSString *)finalizeFunc {
  if (mapFunc.length == 0) {
    return [NSException raise:NSInternalInconsistencyException format:@"Map function missing"];
  }
  if (reduceFunc.length == 0) {
    return [NSException raise:NSInternalInconsistencyException format:@"Reduce function missing"];
  }
  
  // Define the trim set
  NSMutableCharacterSet *trimSet = [[NSCharacterSet whitespaceCharacterSet] mutableCopy];
  [trimSet formUnionWithCharacterSet:[NSCharacterSet newlineCharacterSet]];
  
  NSString *(^trim)(NSString *) = ^(NSString *func) {
    if (func.length > 0) {
      NSArray *comp = [func componentsSeparatedByString:@"\n"];
      NSMutableArray *assemble = [NSMutableArray new];
      for (NSString *line in comp) {
        NSString *trimmed = [line stringByTrimmingCharactersInSet:trimSet];
        if (trimmed.length > 0) {
          [assemble addObject:trimmed];
        }
      }
      return [assemble componentsJoinedByString:@"\n"];
    }
    return nil;
  };
  
  self.mapFunc = trim(mapFunc);
  self.reduceFunc = trim(reduceFunc);
  self.finalizeFunc = trim(finalizeFunc);
}

- (id)perform {
  return [self perform:NULL];
}

- (id)perform:(NSError **)error {
  // TODO: implement
  
  return nil;
}

- (void)performInBackgroundWithBlock:(DKMapReduceResultBlock)block {
  dispatch_queue_t q = dispatch_get_current_queue();
  dispatch_async(kDKMapReduceQueue_, ^{
    NSError *error = nil;
    id result = [self perform:&error];
    if (block != NULL) {
      dispatch_async(q, ^{
        block(result, error);
      });
    }
  });
}

@end
