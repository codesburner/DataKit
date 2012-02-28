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
@property (nonatomic, copy, readonly) NSString *entityName;
@property (nonatomic, readonly) NSString *objectId;
@property (nonatomic, readonly) NSDate *updatedAt;
@property (nonatomic, readonly) NSDate *createdAt;
@property (nonatomic, readonly) BOOL isNew;
@property (nonatomic, readonly) BOOL isDirty;

/*!
 @method objectWithEntityName:
 @param entityName The name of the entity
 @return Initialized object.
 @abstract Initialized an object with the given entity type.
 */
+ (DKObject *)objectWithEntityName:(NSString *)entityName;

+ (BOOL)saveAll:(NSArray *)objects UNIMPLEMENTED;
+ (BOOL)saveAll:(NSArray *)objects error:(NSError **)error UNIMPLEMENTED;
+ (BOOL)saveAllInBackground:(NSArray *)objects UNIMPLEMENTED;
+ (BOOL)saveAllInBackground:(NSArray *)objects withBlock:(DKObjectResultBlock)block UNIMPLEMENTED;
+ (id)new UNAVAILABLE_ATTRIBUTE;

- (id)init UNAVAILABLE_ATTRIBUTE;

/*!
 @method initWithEntityName:
 @param entityName The name of the entity
 @return Initialized object.
 @abstract Initialized an object with the given entity type.
 */
- (id)initWithEntityName:(NSString *)entityName;

/*!
 @method reset
 @abstract Resets the object to it's last saved state.
 */
- (void)reset;

/*!
 @method save
 @return YES on success, NO if an error occurred.
 @abstract Saves changes made to object.
 */
- (BOOL)save;

/*!
 @method save:
 @param error Is set to an error object if error occurred.
 @return YES on success, NO if an error occurred.
 @abstract Saves changes made to object.
 */
- (BOOL)save:(NSError **)error;

/*!
 @method saveInBackground
 @abstract Saves changes made to object in background.
 */
- (void)saveInBackground;

/*!
 @method saveInBackgroundWithBlock:
 @param block The callback block
 @abstract Saves changes made to object in background and invokes callback on completion.
 */
- (void)saveInBackgroundWithBlock:(DKObjectResultBlock)block;

/*!
 @method refresh
 @return YES on success, NO if an error occurred.
 @abstract Refreshes object with data stored on the server.
 */
- (BOOL)refresh;

/*!
 @method refresh:
 @param error Is set to an error object if error occurred.
 @return YES on success, NO if an error occurred.
 @abstract Refreshes object with data stored on the server.
 */
- (BOOL)refresh:(NSError **)error;

/*!
 @method refreshInBackground
 @abstract Refreshes object with data stored on the server in background.
 */
- (void)refreshInBackground;

/*!
 @method refreshInBackground:
 @param block The callback block
 @abstract Refreshes object with data stored on the server in background and invokes callback on completion.
 */
- (void)refreshInBackgroundWithBlock:(DKObjectResultBlock)block;

/*!
 @method delete
 @return YES on success, NO if an error occurred.
 @abstract Deletes object.
 */
- (BOOL)delete;

/*!
 @method delete:
 @param error Is set to an error object if error occurred.
 @return YES on success, NO if an error occurred.
 @abstract Deletes object.
 */
- (BOOL)delete:(NSError **)error;

/*!
 @method deleteInBackground
 @abstract Deletes object in background.
 */
- (void)deleteInBackground;

/*!
 @method deleteInBackgroundWithBlock:
 @param block The callback block
 @abstract Deletes object in background and invokes callback on completion.
 */
- (void)deleteInBackgroundWithBlock:(DKObjectResultBlock)block;

/*!
 @method objectForKey:
 @param key The key to get
 @return The object for the key or nil if not found.
 @abstract Gets the object set for a specific key. If the key does not exist in the saved object, tries to read the key from the unsaved changes.
 */
- (id)objectForKey:(NSString *)key;

- (void)objectForKey:(NSString *)key inBackgroundWithBlock:(DKObjectResultBlock)block UNIMPLEMENTED;
- (DKPointer *)pointerForKey:(NSString *)key UNIMPLEMENTED;

/*!
 @method setObject:forKey:
 @param object The object to store. Must be JSON compliant.
 @param key The key for the object.
 @abstract Sets the object for the given key.
 */
- (void)setObject:(id)object forKey:(NSString *)key;

/*!
 @method removeObjectForKey:
 @param key The key to remove
 @abstract Removes the object stored under key.
 */
- (void)removeObjectForKey:(NSString *)key;

/*!
 @method incrementKey:
 @param key The key to increment
 @abstract Increments the key by 1.
 */
- (void)incrementKey:(NSString *)key;

/*!
 @method incrementKey:
 @param key The key to increment
 @param amount The increment amount
 @abstract Increments the key by amount. Amount can also be a negative value.
 */
- (void)incrementKey:(NSString *)key byAmount:(NSNumber *)amount;

/*!
 @method generatePublicURLForFields:error:
 @param fieldKeys An array with fields of the object to show. If set to nil returns all fields.
 @param error The error object.
 @return The public URL for the object/field combination.
 @abstract Generates a public URL on the server (latency) to access the stored objects data.
 @discussion If the fields array contains one element a request to this URL will return the fields raw data, if the array is nil (select all fields) or it's count is greater than one the request will return a JSON representation of the object.
 */
- (NSURL *)generatePublicURLForFields:(NSArray *)fieldKeys error:(NSError **)error;

@end