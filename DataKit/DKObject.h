//
//  DKObject.h
//  DataKit
//
//  Created by Erik Aigner on 23.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DKObject;
@class DKPointer;

typedef void (^DKObjectResultBlock)(DKObject *object, NSError *error);

@interface DKObject : NSObject
@property (nonatomic, copy, readonly) NSString *objectId;
@property (nonatomic, copy, readonly) NSString *entityName;
@property (nonatomic, copy, readonly) NSDate *updatedAt;
@property (nonatomic, copy, readonly) NSDate *createdAt;
@property (nonatomic, assign, readonly) BOOL isNew;

+ (DKObject *)objectWithEntityName:(NSString *)entityName;
+ (BOOL)saveAll:(NSArray *)objects UNIMPLEMENTED;
+ (BOOL)saveAll:(NSArray *)objects error:(NSError **)error UNIMPLEMENTED;
+ (BOOL)saveAllInBackground:(NSArray *)objects UNIMPLEMENTED;
+ (BOOL)saveAllInBackground:(NSArray *)objects withBlock:(DKObjectResultBlock)block UNIMPLEMENTED;
+ (id)new UNAVAILABLE_ATTRIBUTE;

- (id)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithEntityName:(NSString *)entityName;

- (BOOL)save UNIMPLEMENTED;
- (BOOL)save:(NSError **)error UNIMPLEMENTED;
- (void)saveInBackground UNIMPLEMENTED;
- (void)saveInBackgroundWithBlock:(DKObjectResultBlock)block UNIMPLEMENTED;
- (BOOL)refresh UNIMPLEMENTED;
- (BOOL)refresh:(NSError **)error UNIMPLEMENTED;
- (BOOL)refreshInBackgroundWithBlock:(DKObjectResultBlock)block UNIMPLEMENTED;
- (BOOL)delete UNIMPLEMENTED;
- (BOOL)delete:(NSError **)error UNIMPLEMENTED;
- (BOOL)deleteInBackgroundWithBlock:(DKObjectResultBlock)block UNIMPLEMENTED;
- (id)objectForKey:(NSString *)key UNIMPLEMENTED;
- (void)objectForKey:(NSString *)key inBackgroundWithBlock:(DKObjectResultBlock)block UNIMPLEMENTED;
- (DKPointer *)pointerForKey:(NSString *)key UNIMPLEMENTED;
- (void)setObject:(id)object forKey:(NSString *)key UNIMPLEMENTED;
- (void)removeObjectForKey:(NSString *)key UNIMPLEMENTED;
- (void)incrementKey:(NSString *)key UNIMPLEMENTED;
- (void)incrementKey:(NSString *)key byAmount:(NSNumber *)amount UNIMPLEMENTED;

@end