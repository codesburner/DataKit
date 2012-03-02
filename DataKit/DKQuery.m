//
//  DKQuery.m
//  DataKit
//
//  Created by Erik Aigner on 23.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKQuery.h"

#import "DKQuery-Private.h"
#import "DKRequest.h"
#import "DKEntity.h"
#import "DKEntity-Private.h"

@interface DKQueryConditionProxy : NSProxy

+ (id)proxyForQuery:(DKQuery *)query conditionArray:(NSMutableArray *)array;

@end

@implementation DKQuery
DKSynthesize(entityName)
DKSynthesize(limit)
DKSynthesize(skip)
DKSynthesize(cachePolicy)
DKSynthesize(queryMap)
DKSynthesize(sort)
DKSynthesize(ors)
DKSynthesize(ands)

+ (DKQuery *)queryWithEntityName:(NSString *)entityName {
  return [[self alloc] initWithEntityName:entityName];
}

+ (DKEntity *)getEntity:(NSString *)entityName withId:(NSString *)entityId {
  return nil;
}

+ (DKEntity *)getEntity:(NSString *)entityName withId:(NSString *)entityId error:(NSError **)error {
  return nil;
}

+ (void)clearAllCachedResults {
  
}

- (id)initWithEntityName:(NSString *)entityName {
  self = [super init];
  if (self) {
    self.entityName = entityName;
    self.queryMap = [NSMutableDictionary new];
    self.sort = [NSMutableDictionary new];
    self.ors = [NSMutableArray new];
    self.ands = [NSMutableArray new];
    self.cachePolicy = DKCachePolicyIgnoreCache;
  }
  return self;
}

- (void)reset {
  [self.queryMap removeAllObjects];
  [self.sort removeAllObjects];
  [self.ors removeAllObjects];
  [self.ands removeAllObjects];
}

- (DKQuery *)or {
  return [DKQueryConditionProxy proxyForQuery:self conditionArray:self.ors];
}

- (DKQuery *)and {
  return [DKQueryConditionProxy proxyForQuery:self conditionArray:self.ands];
}

- (void)orderAscendingByKey:(NSString *)key {
  [self.sort setObject:[NSNumber numberWithInteger:1] forKey:key];
}

- (void)orderDescendingByKey:(NSString *)key {
  [self.sort setObject:[NSNumber numberWithInteger:-1] forKey:key];
}

- (void)whereKey:(NSString *)key equalTo:(id)object {
  [self.queryMap setObject:object forKey:key];
}

- (void)whereKey:(NSString *)key lessThan:(id)object {
  [[self queryDictForKey:key] setObject:object forKey:@"$lt"];
}

- (void)whereKey:(NSString *)key lessThanOrEqualTo:(id)object {
  [[self queryDictForKey:key] setObject:object forKey:@"$lte"];
}

- (void)whereKey:(NSString *)key greaterThan:(id)object {
  [[self queryDictForKey:key] setObject:object forKey:@"$gt"];
}

- (void)whereKey:(NSString *)key greaterThanOrEqualTo:(id)object {
  [[self queryDictForKey:key] setObject:object forKey:@"$gte"];
}

- (void)whereKey:(NSString *)key notEqualTo:(id)object {
  [[self queryDictForKey:key] setObject:object forKey:@"$ne"];
}

- (void)whereKey:(NSString *)key containedIn:(NSArray *)array {
  [[self queryDictForKey:key] setObject:array forKey:@"$in"];
}

- (void)whereKey:(NSString *)key notContainedIn:(NSArray *)array {
  [[self queryDictForKey:key] setObject:array forKey:@"$nin"];
}

- (void)whereKey:(NSString *)key containsAllIn:(NSArray *)array {
  [[self queryDictForKey:key] setObject:array forKey:@"$all"];
}

- (void)whereKey:(NSString *)key matchesRegex:(NSString *)regex {
  [self whereKey:key matchesRegex:regex options:0];
}

- (void)whereKey:(NSString *)key matchesRegex:(NSString *)regex options:(DKRegexOption)options {
  NSMutableString *optionString = [NSMutableString new];
  if ((options & DKRegexOptionCaseInsensitive) == DKRegexOptionCaseInsensitive) {
    [optionString appendString:@"i"];
  }
  else if ((options & DKRegexOptionMultiline) == DKRegexOptionMultiline) {
    [optionString appendString:@"m"];
  }
  else if ((options & DKRegexOptionDotall) == DKRegexOptionDotall) {
    [optionString appendString:@"s"];
  }
  NSMutableDictionary *queryDict = [self queryDictForKey:key];
  [queryDict setObject:regex forKey:@"$regex"];
  if (optionString.length > 0) {
    [queryDict setObject:optionString forKey:@"$options"];
  }
}

- (void)whereKey:(NSString *)key containsString:(NSString *)string {
  NSString *safeString = [self makeRegexSafeString:string];
  [self whereKey:key matchesRegex:safeString];
}

- (void)whereKey:(NSString *)key hasPrefix:(NSString *)prefix {
  NSString *safeString = [self makeRegexSafeString:prefix];
  NSString *regex = [NSString stringWithFormat:@"^%@", safeString];
  [self whereKey:key matchesRegex:regex];
}

- (void)whereKey:(NSString *)key hasSuffix:(NSString *)suffix {
  NSString *safeString = [self makeRegexSafeString:suffix];
  NSString *regex = [NSString stringWithFormat:@"%@$", safeString];
  [self whereKey:key matchesRegex:regex];
}

- (void)whereKeyExists:(NSString *)key {
  [[self queryDictForKey:key] setObject:[NSNumber numberWithBool:YES] forKey:@"$exists"];
}

- (void)whereKeyDoesNotExist:(NSString *)key {
  [[self queryDictForKey:key] setObject:[NSNumber numberWithBool:NO] forKey:@"$exists"];
}

- (void)includeKey:(NSString *)key {
  
}

- (NSArray *)findAll {
  return [self findAll:NULL];
}

- (NSArray *)findAll:(NSError **)error {
  // Create request dict
  NSMutableDictionary *requestDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      self.entityName, @"entity", nil];
  if (self.queryMap.count > 0) {
    [requestDict setObject:self.queryMap forKey:@"q"];
  }
  if (self.ors.count > 0) {
    [requestDict setObject:self.ors forKey:@"or"];
  }
  if (self.ands.count > 0) {
    [requestDict setObject:self.ands forKey:@"and"];
  }
  if (self.sort.count > 0) {
    [requestDict setObject:self.sort forKey:@"sort"];
  }
  if (self.limit > 0) {
    [requestDict setObject:[NSNumber numberWithUnsignedInteger:self.limit] forKey:@"limit"];
  }
  if (self.skip > 0) {
    [requestDict setObject:[NSNumber numberWithUnsignedInteger:self.skip] forKey:@"skip"];
  }
  
  // Send request synchronously
  DKRequest *request = [DKRequest request];
  request.cachePolicy = self.cachePolicy;
  
  NSError *requestError = nil;
  NSArray *results = [request sendRequestWithObject:requestDict method:@"query" error:&requestError];
  if (requestError != nil) {
    if (error != nil) {
      *error = requestError;
    }
    return nil;
  }
  
  if ([results isKindOfClass:[NSArray class]]) {
    NSMutableArray *entities = [NSMutableArray new];
    for (NSDictionary *objDict in results) {
      if ([objDict isKindOfClass:[NSDictionary class]]) {
        DKEntity *entity = [[DKEntity alloc] initWithName:self.entityName];
        entity.resultMap = objDict;
        
        [entities addObject:entity];
      }
    }
    
    return [NSArray arrayWithArray:entities];
  }
  else {
#ifdef CONFIGURATION_Debug
    NSLog(@"warning: query did not return object list");
#endif
  }
  return nil;
}

- (void)findObjectsInBackgroundWithBlock:(DKQueryResultBlock)block {
  
}

- (id)getFirstObject {
  return nil;
}

- (id)getFirstObject:(NSError **)error {
  return nil;
}

- (void)getFirstObjectInBackgroundWithBlock:(DKQueryResultBlock)block {
  
}

- (NSInteger)countObjects {
  return -1;
}

- (NSInteger)countObjects:(NSError **)error {
  return -1;
}

- (void)countObjectsInBackgroundWithBlock:(DKQueryResultBlock)block {
  
}

- (DKEntity *)getEntityById:(NSString *)entityId {
  return nil;
}

- (DKEntity *)getEntityById:(NSString *)entityId error:(NSError **)error {
  return nil;
}

- (void)getEntityById:(NSString *)entityId inBackgroundWithBlock:(DKQueryResultBlock)block {
  
}

- (void)cancel {
  
}

- (BOOL)hasCachedResult {
  return NO;
}

- (void)clearCachedResult {
  
}

@end

@implementation DKQueryConditionProxy {
@private
  DKQuery         *query_;
  NSMutableArray  *conditions_;
}

+ (id)proxyForQuery:(DKQuery *)query conditionArray:(NSMutableArray *)array {
  DKQueryConditionProxy *proxy = [self alloc];
  proxy->query_ = query;
  proxy->conditions_ = array;
  return proxy;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
  NSMutableDictionary *queryMap = query_.queryMap;
  query_.queryMap = [NSMutableDictionary new];

  [invocation invokeWithTarget:query_];

  if (query_.queryMap.count > 0) {
    [conditions_ addObject:query_.queryMap];
  }
  query_.queryMap = queryMap;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
  return [query_ methodSignatureForSelector:sel];
}

@end

@implementation DKQuery (Private)

- (NSMutableDictionary*)queryDictForKey:(NSString *)key {
  NSMutableDictionary *dict = [self.queryMap objectForKey:key];
  if (dict == nil) {
    dict = [NSMutableDictionary new];
    [self.queryMap setObject:dict forKey:key];
  }
  
  return dict;
}

- (NSString *)makeRegexSafeString:(NSString *)string {
  // There are 11 special regex characters we need to escape!
  // 1: the opening square bracket [
  // 2: the backslash \
  // 3: the caret ^
  // 4: the dollar sign $
  // 5: the period or dot .
  // 6: the vertical bar or pipe symbol |
  // 7: the question mark ?
  // 8: the asterisk or star *
  // 9: the plus sign +
  // 10: the opening round bracket (
  // 11: and the closing round bracket )  
  CFStringRef strIn = (__bridge CFStringRef)string;
  CFMutableStringRef accu = CFStringCreateMutable(NULL, string.length * 2);
  
  for (NSUInteger loc=0; loc<string.length; loc++) {
    unichar c =  CFStringGetCharacterAtIndex(strIn, loc);
    BOOL escape = NO;
    switch (c) {
      case '[':
      case '\\':
      case '^':
      case '$':
      case '.':
      case '|':
      case '?':
      case '*':
      case '+':
      case '(':
      case ')': escape = YES; break;
    }
    if (escape) {
      CFStringAppend(accu, CFSTR("\\"));
    }
    CFStringRef s = CFStringCreateWithCharacters(NULL, &c, 1);
    CFStringAppend(accu, s);
    CFRelease(s);
  };
  
  return CFBridgingRelease(accu);
}

@end
