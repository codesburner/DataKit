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
@property (nonatomic, copy, readonly) NSString *objectId;

+ (DKPointer *)pointerWithEntityName:(NSString *)entityName objectId:(NSString *)objectId;
+ (id)new UNAVAILABLE_ATTRIBUTE;

- (id)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithEntityName:(NSString *)entityName objectId:(NSString *)objectId;

@end
