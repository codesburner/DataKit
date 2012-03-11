//
//  DKEntity.h
//  DataKit
//
//  Created by Erik Aigner on 23.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DKEntity;
@class DKRelation;

typedef void (^DKEntityResultBlock)(DKEntity *entity, NSError *error);
typedef void (^DKEntityResultsBlock)(NSArray *entities, NSError *error);

/**
 A DKEntity represents an object stored in the collection with the given name.
 
 @warning *Important*: `$` and `.` characters cannot be used in object keys
 */
@interface DKEntity : NSObject
@property (nonatomic, copy, readonly) NSString *entityName;
@property (nonatomic, readonly) NSString *entityId;
@property (nonatomic, readonly) DKRelation *entityPointer;
@property (nonatomic, readonly) NSDate *updatedAt;
@property (nonatomic, readonly) NSDate *createdAt;
@property (nonatomic, readonly) NSInteger sequenceNumber;
@property (nonatomic, readonly) BOOL isNew;
@property (nonatomic, readonly) BOOL isDirty;

+ (id)new UNAVAILABLE_ATTRIBUTE;
- (id)init UNAVAILABLE_ATTRIBUTE;

/** @name Creating and Initializing Entities */

/**
 Create entity with given name
 @param entityName The entity name
 @return The initialized entity
 */
+ (DKEntity *)entityWithName:(NSString *)entityName;

/**
 Initialize a new entity
 @param entityName The entity name
 @return The initialized entity
 */
- (id)initWithName:(NSString *)entityName;

/** @name Saving Entities */

/**
 Batch save all entities.
 @param entities The entities to save
 @return `YES` on success, `NO` on error.
 @discussion Useful if you want to make sure everything is transmitted to the server before saving.
 */
+ (BOOL)saveAll:(NSArray *)entities;

/**
 Batch save all entities.
 @param entities The entities to save
 @param error The error object to be set on error
 @return `YES` on success, `NO` on error.
 @discussion Useful if you want to make sure everything is transmitted to the server before saving.
 */
+ (BOOL)saveAll:(NSArray *)entities error:(NSError **)error;

/**
 Batch save all entities in the background.
 @param entities The entities to save
 @discussion Useful if you want to make sure everything is transmitted to the server before saving.
 */
+ (void)saveAllInBackground:(NSArray *)entities;

/**
 Batch save all entities in the background.
 @param entities The entities to save
 @param block The save callback block
 @discussion Useful if you want to make sure everything is transmitted to the server before saving.
 */
+ (void)saveAllInBackground:(NSArray *)entities withBlock:(DKEntityResultsBlock)block;

/**
 Saves the entity
 @return `YES` on success, `NO` on error
 @exception NSInvalidArgumentException Raised if any key contains an `$` or `.` character.
 */
- (BOOL)save;

/**
 Saves the entity
 @param error The error object to be set on error
 @return `YES` on success, `NO` on error
 @exception NSInvalidArgumentException Raised if any key contains an `$` or `.` character.
 */
- (BOOL)save:(NSError **)error;

/**
 Saves the entity in the background
 @exception NSInvalidArgumentException Raised if any key contains an `$` or `.` character.
 */
- (void)saveInBackground;

/**
 Saves the entity in the background and invokes callback on completion
 @param block The save callback block
 @exception NSInvalidArgumentException Raised if any key contains an `$` or `.` character.
 */
- (void)saveInBackgroundWithBlock:(DKEntityResultBlock)block;

/** @name Refreshing Entities */

/**
 Refreshes the entity
 @return `YES` on success, `NO` on error
 @discussion Refreshes the entity with data stored on the server
 */
- (BOOL)refresh;

/**
 Refreshes the entity
 @param error The error object to be set on error
 @return `YES` on success, `NO` on error
 @discussion Refreshes the entity with data stored on the server
 */
- (BOOL)refresh:(NSError **)error;

/**
 Refreshes the entity in the background
 @discussion Refreshes the entity with data stored on the server
 */
- (void)refreshInBackground;

/**
 Refreshes the entity in the background and invokes the callback on completion
 @param block The callback block
 @discussion Refreshes the entity with data stored on the server
 */
- (void)refreshInBackgroundWithBlock:(DKEntityResultBlock)block;

/** @name Deleting Entities */

/**
 Deletes the entity
 @return `YES` on success, `NO` on error
 */
- (BOOL)delete;

/**
 Deletes the entity
 @param error The error object to be set on error
 @return `YES` on success, `NO` on error
 */
- (BOOL)delete:(NSError **)error;

/**
 Deletes the entity in the background
 */
- (void)deleteInBackground;

/**
 Deletes the entity in the background and invokes the callback block on completion
 @param block The callback block
 */
- (void)deleteInBackgroundWithBlock:(DKEntityResultBlock)block;

/** @name Getting Objects*/

/**
 Gets the object stored at `key`.
 @param key The object key
 @return The object or `nil` if no object is set for `key`
 @discussion If the key does not exist in the saved object, tries to return a value from the unsaved changes
 */
- (id)objectForKey:(NSString *)key;

/** @name Modifying Objects*/

/**
 Sets the object on a given `key`
 @param object The object to store
 @param key The object key
 @discussion The object must be of type NSString, NSNumber, NSArray, NSDictionary, NSNull, NSData or <DKRelation>
 @warning The key must not include an `$` or `.` character
 */
- (void)setObject:(id)object forKey:(NSString *)key;

/**
 Pushes (appends) the object to the list at `key`.
 @param object The object to push
 @param key The list key
 @discussion Appends the object if a list exists at `key`, otherwise sets a single elemenet list containing `object` on `key`. If the `key` exists, but is not a list, the entity save will fail. Object must be a *JSON* type.
 @warning The key must not include an `$` or `.` character
 */
- (void)pushObject:(id)object forKey:(NSString *)key;

/**
 Pushes (appends) all objects to the list at `key`
 @param objects The object list
 @param key The list key
 @discussion Appends the objects if a list exists at `key`, otherwise sets `key` to the `objects` list. If the `key` exists, but is not a list, the entity save will fail. List may only contain *JSON* types.
 @warning The key must not include an `$` or `.` character
 */
- (void)pushAllObjects:(NSArray *)objects forKey:(NSString *)key;

/**
 Adds the object to the list at `key`, if it is not already in the list
 @param object The object to add
 @param key The list key
 @discussion Appends the objects if a list exists at `key` and `object` is not already in that list, otherwise sets `key` to a single object array containing `object`. If the `key` exists, but is not a list, the entity save will fail. List may only contain *JSON* types.
 @warning The key must not include an `$` or `.` character
 */
- (void)addObjectToSet:(id)object forKey:(NSString *)key;

/**
 Adds all objects to the list at `key`, if object is not already in the list
 @param objects The object list
 @param key The list key
 @discussion Adds the objects to the list only if the objects do not already exist in the list and if `key` is a list, otherwise sets `key` to a list containting `objects`. If the `key` is present, but not a list, entity save will fail. All objects in the list must be *JSON* types.
 @warning The key must not include an `$` or `.` character
 */
- (void)addAllObjectsToSet:(NSArray *)objects forKey:(NSString *)key;

/**
 Removes the last object from the list at `key`
 @param key The list key
 @warning Pop-last will override any pop-first action
 */
- (void)popLastObjectForKey:(NSString *)key;

/**
 Removes the first object from the list at `key`
 @param key The list key
 @warning Pop-first will override any pop-last action
 */
- (void)popFirstObjectForKey:(NSString *)key;

/**
 Removes all occurrences of object from the list at `key`
 @param object The object to remove
 @param key The list key
 @discussion If the `key` exists, but is not a list, entity save will fail.
 */
- (void)pullObject:(id)object forKey:(NSString *)key;

/**
 Removes all occurrences of objects from the list at `key`
 @param objects The objects to remove
 @param key The list key
 @discussion If the `key` exists, but is not a list, entity save will fail.
 */
- (void)pullAllObjects:(NSArray *)objects forKey:(NSString *)key;

/**
 Removes the object at `key`
 @param key The object key
 */
- (void)removeObjectForKey:(NSString *)key;

/**
 Increments the number at `key` by `1`
 @param key The key to increment
 */
- (void)incrementKey:(NSString *)key;

/**
 Increments the number at `key` by `amount`
 @param key The key to increment 
 @param amount The increment amount. Can also be negative
 */
- (void)incrementKey:(NSString *)key byAmount:(NSNumber *)amount;

/** @name Indexing */

/**
 Ensures that the given `key` is indexed
 @param key The key to index
 @discussion Indexes often improve query perfomance dramatically.
 */
- (BOOL)ensureIndexForKey:(NSString *)key;

/**
 Ensures that the given `key` is indexed with options
 @param key The key to index
 @param unique Make the `key` unique
 @param dropDups Automatically drop any duplicates
 @param error The error object to be set on error
 @discussion Indexes often improve query perfomance dramatically.
 */
- (BOOL)ensureIndexForKey:(NSString *)key unique:(BOOL)unique dropDuplicates:(BOOL)dropDups error:(NSError **)error;

/** @name Public URLs */

/**
 Generates a public URL to access entity data directly
 @param fieldKeys A list of keys to expose, pass `nil` to return all object keys
 @param error The error object to be set on error
 @return The public URL for the entity data
 @discussion If the fields list contains one element, a request to the public URL will return the fields raw data. If the list has more than 1 element, a *JSON* representation of the entity will be returned.
 */
- (NSURL *)generatePublicURLForFields:(NSArray *)fieldKeys error:(NSError **)error;

/** @name Resetting State */

/**
 Resets the entity to it's last saved state
 */
- (void)reset;

@end