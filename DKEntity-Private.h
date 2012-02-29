//
//  DKObject+Private.h
//  DataKit
//
//  Created by Erik Aigner on 26.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKEntity.h"

@interface DKEntity () // CLS_EXT
@property (nonatomic, copy, readwrite) NSString *entityName;
@property (nonatomic, strong) NSMutableDictionary *setMap;
@property (nonatomic, strong) NSMutableDictionary *unsetMap;
@property (nonatomic, strong) NSMutableDictionary *incMap;
@property (nonatomic, strong) NSMutableDictionary *pushMap;
@property (nonatomic, strong) NSMutableDictionary *pushAllMap;
@property (nonatomic, strong) NSMutableDictionary *addToSetMap;
@property (nonatomic, strong) NSMutableDictionary *popMap;
@property (nonatomic, strong) NSMutableDictionary *pullAllMap;
@property (nonatomic, strong) NSDictionary *resultMap;
@end

@interface DKEntity (Private)

- (BOOL)hasEntityId:(NSError **)error;
- (BOOL)hasEntityName:(NSError **)error;
- (BOOL)commitObjectResultMap:(NSDictionary *)resultMap error:(NSError **)error;

@end
