//
//  DKPointer.h
//  DataKit
//
//  Created by Erik Aigner on 23.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DKPointer : NSObject
@property (nonatomic, copy, readonly) NSString *entityName;
@property (nonatomic, copy, readonly) NSString *entityId;

+ (DKPointer *)pointerWithEntityName:(NSString *)entityName entityId:(NSString *)entityId;
+ (id)new UNAVAILABLE_ATTRIBUTE;

- (id)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithEntityName:(NSString *)entityName entityId:(NSString *)entityId;

@end
