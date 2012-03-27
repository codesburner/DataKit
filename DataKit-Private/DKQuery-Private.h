//
//  DKQuery-Private.h
//  DataKit
//
//  Created by Erik Aigner on 29.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKQuery.h"

@interface DKQuery () // CLS_EXT
@property (nonatomic, copy, readwrite) NSString *entityName;
@property (nonatomic, strong) NSMutableDictionary *queryMap;
@property (nonatomic, strong) NSMutableDictionary *sort;
@property (nonatomic, strong) NSMutableArray *ors;
@property (nonatomic, strong) NSMutableArray *ands;
@property (nonatomic, strong) NSMutableArray *referenceIncludes;
@property (nonatomic, strong) NSMutableDictionary *fieldInclExcl;
@property (nonatomic, strong) DKMapReduce *mapReduce;

- (id)find:(NSError **)error one:(BOOL)findOne count:(NSUInteger *)countOut;

@end

@interface DKQuery (Private)

- (NSMutableDictionary*)queryDictForKey:(NSString *)key;
- (NSString *)makeRegexSafeString:(NSString *)string;

@end