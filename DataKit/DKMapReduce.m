//
//  DKMapReduce.m
//  DataKit
//
//  Created by Erik Aigner on 11.03.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKMapReduce.h"

@interface DKMapReduce ()
@property (nonatomic, copy, readwrite) NSString *mapFunction;
@property (nonatomic, copy, readwrite) NSString *reduceFunction;
@property (nonatomic, copy, readwrite) NSString *finalizeFunction;
@end

@implementation DKMapReduce
DKSynthesize(context)
DKSynthesize(resultProcessor)
DKSynthesize(mapFunction)
DKSynthesize(reduceFunction)
DKSynthesize(finalizeFunction)

+ (DKMapReduce *)randomizeResultsWithLimit:(NSUInteger)limit {
  DKMapReduce *mr = [DKMapReduce new];
  [mr map:@"function map() {"
           "  emit(0, {k: this, v: Math.random()});"
           "}"
   reduce:@"function reduce(k, v) {"
           "  var a, s;"
           "  a = [];"
           "  v.forEach(function (x) {"
           "    a = a.concat(x.a || x);"
           "  });"
           "  s = a.sort(function (a, b) {"
           "    return a.v - b.v;"
           "  });"
           "  if (limit > 0) {"
           "    s = s.slice(0, limit);"
           "  }"
           "  return {a: s};"
           "}"
 finalize:@"function finalize(k, v) {"
           "  return v.a ? v.a.map(function (x) {"
           "    return x.k;"
           "  }) : [v.k];"
           "}"];
  mr.context = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInteger:limit]
                                           forKey:@"limit"];
  mr.resultProcessor = ^(id result){
    if ([result isKindOfClass:[NSArray class]]) {
      NSDictionary *dict = [result objectAtIndex:0];
      if ([dict isKindOfClass:[NSDictionary class]]) {
        return [dict objectForKey:@"value"];
      }
    }
    return nil;
  };
  
  return mr;
}

+ (DKMapReduce *)countForKeys:(NSArray *)keys {
  DKMapReduce *mr = [DKMapReduce new];
  mr.context = [NSDictionary dictionaryWithObject:keys forKey:@"keys"];
  [mr map:@"function () { var m, k, i; m = {}; for (i in keys) { k = keys[i]; m[k] = this[k].length; } emit(this._id, m) }"];
  mr.resultProcessor = ^(id results){
    if ([results isKindOfClass:[NSArray class]]) {
      NSMutableArray *ary = [NSMutableArray new];
      
      for (NSDictionary *dict in results) {
        NSMutableDictionary *counts = [[dict objectForKey:@"value"] mutableCopy];
        [counts setObject:[dict objectForKey:@"_id"] forKey:@"entityId"];
        
        [ary addObject:counts];
      }
      return ary;
    }
    return nil;
  };
  
  return mr;
}

- (id)init {
  self = [super init];
  if (self) {
    self.resultProcessor = ^(id result) { return result; };
  }
  return self;
}

- (void)map:(NSString *)mapFunc {
  [self map:mapFunc reduce:@"function () {}"];
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
  NSCharacterSet *trimSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  
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
  
  self.mapFunction = trim(mapFunc);
  self.reduceFunction = trim(reduceFunc);
  self.finalizeFunction = trim(finalizeFunc);
}

@end
