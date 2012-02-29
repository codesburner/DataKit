//
//  DKEntity.h
//  DataKit
//
//  Created by Erik Aigner on 23.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DKEntity;
@class DKPointer;

typedef void (^DKEntityResultBlock)(DKEntity *object, NSError *error);

@interface DKEntity : NSObject
@property (nonatomic, copy, readonly) NSString *entityName;
@property (nonatomic, readonly) NSString *entityId;
@property (nonatomic, readonly) DKPointer *entityPointer;
@property (nonatomic, readonly) NSDate *updatedAt UNIMPLEMENTED;
@property (nonatomic, readonly) NSDate *createdAt UNIMPLEMENTED;
@property (nonatomic, readonly) BOOL isNew;
@property (nonatomic, readonly) BOOL isDirty;

/*!
 @method entityWithName:
 @param entityName The name of the entity
 @return Initialized object.
 @abstract Initialized an object with the given entity type.
 */
+ (DKEntity *)entityWithName:(NSString *)entityName;

+ (BOOL)saveAll:(NSArray *)objects UNIMPLEMENTED;
+ (BOOL)saveAll:(NSArray *)objects error:(NSError **)error UNIMPLEMENTED;
+ (BOOL)saveAllInBackground:(NSArray *)objects UNIMPLEMENTED;
+ (BOOL)saveAllInBackground:(NSArray *)objects withBlock:(DKEntityResultBlock)block UNIMPLEMENTED;
+ (id)new UNAVAILABLE_ATTRIBUTE;

- (id)init UNAVAILABLE_ATTRIBUTE;

/*!
 @method initWithName:
 @param entityName The name of the entity
 @return Initialized object.
 @abstract Initialized an object with the given entity type.
 */
- (id)initWithName:(NSString *)entityName;

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
- (void)saveInBackgroundWithBlock:(DKEntityResultBlock)block;

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
- (void)refreshInBackgroundWithBlock:(DKEntityResultBlock)block;

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
- (void)deleteInBackgroundWithBlock:(DKEntityResultBlock)block;

/*!
 @method objectForKey:
 @param key The key to get
 @return The object for the key or nil if not found.
 @abstract Gets the object set for a specific key. If the key does not exist in the saved object, tries to read the key from the unsaved changes.
 */
- (id)objectForKey:(NSString *)key;

- (void)objectForKey:(NSString *)key inBackgroundWithBlock:(DKEntityResultBlock)block UNIMPLEMENTED;
- (DKPointer *)pointerForKey:(NSString *)key UNIMPLEMENTED;

/*!
 @method setObject:forKey:
 @param object The object to store. Must be JSON compliant.
 @param key The key for the object.
 @abstract Sets the object for the given key.
 */
- (void)setObject:(id)object forKey:(NSString *)key;

/*!
 @method pushObject:forKey:
 @param object The object to push
 @param key The key for the object.
 @abstract Appends the object to the field with |key| if it is an existing array, otherwise sets field to a single element array containing the object if field is not present.
 @discussion Push has only an effect if the object already exists in the database (not new, has an object ID). If field is present but not an array, object save will fail.
 */
- (void)pushObject:(id)object forKey:(NSString *)key;

/*!
 @method pushAllObjects:forKey:
 @param objects The object array to push
 @param key The key for the objects.
 @abstract Appends each object to the field with |key| if it is an existing array, otherwise sets field to a new array containing the objects if field is not present.
 @discussion Push-all has only an effect if the object already exists in the database (not new, has an object ID). If field is present but not an array, object save will fail.
 */
- (void)pushAllObjects:(NSArray *)objects forKey:(NSString *)key;

/*!
 @method addObjectToSet:forKey:
 @param object The object to add.
 @param key The key for the object
 @abstract Adds the object to the array only if the object is not already present and if field |key| is an existing array, otherwise sets field |key| to a single object array containing |object| if field not present.
 @discussion Add-to-set has only an effect if the object already exists in the database (not new, has an object ID). If field is present but not an array, object save will fail.
 */
- (void)addObjectToSet:(id)object forKey:(NSString *)key;

/*!
 @method addAllObjectsToSet:forKey:
 @param objects The objects to add.
 @param key The key for the objects
 @abstract Adds the objects to the array only if the objects are not already present and if field |key| is an existing array, otherwise sets field |key| to the object array containing |objects| if field not present.
 @discussion Add-to-set has only an effect if the object already exists in the database (not new, has an object ID). If field is present but not an array, object save will fail.
 */
- (void)addAllObjectsToSet:(NSArray *)objects forKey:(NSString *)key;

/*!
 @method popLastObjectForKey:
 @param key The object key
 @abstract Removes the last object from the array at |key|.
 @discussion Pop has only an effect if the object already exists in the database (not new, has an object ID).
 */
- (void)popLastObjectForKey:(NSString *)key;

/*!
 @method popFirstObjectForKey:
 @param key The object key
 @abstract Removes the first object from the array at |key|.
 @discussion Pop has only an effect if the object already exists in the database (not new, has an object ID).
 */
- (void)popFirstObjectForKey:(NSString *)key;

/*!
 @method pullObject:forKey:
 @param object The object to pull
 @param key The object key
 @abstract Removes all occurrences of object from field |key|, if field is an array.
 @discussion Pull has only an effect if the object already exists in the database (not new, has an object ID). If field is present, but not an array save will fail.
 */
- (void)pullObject:(id)object forKey:(NSString *)key;

/*!
 @method pullAllObjects:forKey:
 @param objects The objects to pull
 @param key The object key
 @abstract Removes all occurrences of |objects| from field |key|, if field is an array.
 @discussion Pull has only an effect if the object already exists in the database (not new, has an object ID). If field is present, but not an array save will fail.
 */
- (void)pullAllObjects:(NSArray *)objects forKey:(NSString *)key;

/*!
 @method removeObjectForKey:
 @param key The key to remove
 @abstract Removes the object stored under key.
 @discussion Increment has only an effect if the object already exists in the database (not new, has an object ID).
 */
- (void)removeObjectForKey:(NSString *)key;

/*!
 @method incrementKey:
 @param key The key to increment
 @abstract Increments the key by 1.
 @discussion Increment has only an effect if the object already exists in the database (not new, has an object ID).
 */
- (void)incrementKey:(NSString *)key;

/*!
 @method incrementKey:
 @param key The key to increment
 @param amount The increment amount
 @abstract Increments the key by amount. Amount can also be a negative value.
 @discussion Increment has only an effect if the object already exists in the database (not new, has an object ID).
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