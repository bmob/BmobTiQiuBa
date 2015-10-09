#import "Jastor.h"
#import "JastorRuntimeHelper.h"
#import <BmobSDK/Bmob.h>

@implementation Jastor

@synthesize objectId;
static NSString *idPropertyName = @"id";
static NSString *idPropertyNameOnObject = @"objectId";

Class nsDictionaryClass;
Class nsArrayClass;
Class bmobObjectClass;

+ (id)objectFromDictionary:(NSDictionary*)dictionary {
    id item = [[self alloc] initWithDictionary:dictionary];
    return item;
}

- (id)initWithDictionary:(id)dictionary {
	if (!nsDictionaryClass) nsDictionaryClass = [NSDictionary class];
	if (!nsArrayClass) nsArrayClass = [NSArray class];
    if (!bmobObjectClass) bmobObjectClass = [BmobObject class];
	
	if ((self = [super init])) {
        
        id objectIdValue;
		if ((objectIdValue = [dictionary valueForKey:idPropertyNameOnObject]) && objectIdValue != [NSNull null]) {
			if (![objectIdValue isKindOfClass:[NSString class]]) {
				objectIdValue = [NSString stringWithFormat:@"%@", objectIdValue];
			}
			[self setValue:objectIdValue forKey:idPropertyNameOnObject];
		}
		for (NSString *key in [JastorRuntimeHelper propertyNames:[self class]]) {
			
			id value = [dictionary objectForKey:[[self map] valueForKey:key]];
			
			if (value == [NSNull null] || value == nil) {
                continue;
            }
            
            if ([JastorRuntimeHelper isPropertyReadOnly:[self class] propertyName:key]) {
                continue;
            }
			
			// handle dictionary
			if ([value isKindOfClass:nsDictionaryClass] || [value isKindOfClass:[BmobObject class]]) {
				Class klass = [JastorRuntimeHelper propertyClassForPropertyName:key ofClass:[self class]];
				if ([NSStringFromClass(klass) isEqualToString:@"BmobRelation"]) {
                    [self setValue:value forKey:key];
                }else
                {
                    value = [[klass alloc] initWithDictionary:value];
                }
			}
			// handle array
			else if ([value isKindOfClass:nsArrayClass]) {
				
				NSMutableArray *childObjects = [NSMutableArray arrayWithCapacity:[(NSArray*)value count]];
				
				for (id child in value) {
                    if ([[child class] isSubclassOfClass:nsDictionaryClass]) {
                        Class arrayItemType = [[self class] performSelector:NSSelectorFromString([NSString stringWithFormat:@"%@_class", key])];
                        if ([arrayItemType isSubclassOfClass:[NSDictionary class]]) {
                            [childObjects addObject:child];
                        } else if ([arrayItemType isSubclassOfClass:[Jastor class]]) {
                            Jastor *childDTO = [[arrayItemType alloc] initWithDictionary:child];
                            [childObjects addObject:childDTO];
                        }
					} else {
						[childObjects addObject:child];
					}
				}
				
				value = childObjects;
			}
			// handle all others
			[self setValue:value forKey:key];
		}
		
		
	}
	return self;	
}

- (void)encodeWithCoder:(NSCoder*)encoder {
	[encoder encodeObject:self.objectId forKey:idPropertyNameOnObject];
	for (NSString *key in [JastorRuntimeHelper propertyNames:[self class]]) {
		[encoder encodeObject:[self valueForKey:key] forKey:key];
	}
}

- (id)initWithCoder:(NSCoder *)decoder {
	if ((self = [super init])) {
		[self setValue:[decoder decodeObjectForKey:idPropertyNameOnObject] forKey:idPropertyNameOnObject];
		
		for (NSString *key in [JastorRuntimeHelper propertyNames:[self class]]) {
            if ([JastorRuntimeHelper isPropertyReadOnly:[self class] propertyName:key]) {
                continue;
            }
			id value = [decoder decodeObjectForKey:key];
			if (value != [NSNull null] && value != nil) {
				[self setValue:value forKey:key];
			}
		}
	}
	return self;
}

- (NSMutableDictionary *)toDictionary {
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.objectId) {
        [dic setObject:self.objectId forKey:idPropertyName];
    }
	
	for (NSString *key in [JastorRuntimeHelper propertyNames:[self class]]) {
		id value = [self valueForKey:key];
        if (value && [value isKindOfClass:[Jastor class]]) {
			[dic setObject:[value toDictionary] forKey:[[self map] valueForKey:key]];
        } else if (value && [value isKindOfClass:[NSArray class]] && ((NSArray*)value).count > 0) {
            id internalValue = [value objectAtIndex:0];
            if (internalValue && [internalValue isKindOfClass:[Jastor class]]) {
                NSMutableArray *internalItems = [NSMutableArray array];
                for (id item in value) {
                    [internalItems addObject:[item toDictionary]];
                }
				[dic setObject:internalItems forKey:[[self map] valueForKey:key]];
            } else {
				[dic setObject:value forKey:[[self map] valueForKey:key]];
            }
        } else if (value != nil) {
			[dic setObject:value forKey:[[self map] valueForKey:key]];
        }
	}
    return dic;
}

- (NSDictionary *)map {
	NSArray *properties = [JastorRuntimeHelper propertyNames:[self class]];
	NSMutableDictionary *mapDictionary = [[NSMutableDictionary alloc] initWithCapacity:properties.count];
	for (NSString *property in properties) {
		[mapDictionary setObject:property forKey:property];
	}
	return [NSDictionary dictionaryWithDictionary:mapDictionary];
}

- (NSString *)description {
    NSMutableDictionary *dic = [self toDictionary];
	
	return [NSString stringWithFormat:@"#<%@: id = %@ %@>", [self class], self.objectId, [dic description]];
}

- (BOOL)isEqual:(id)object {
	if (object == nil || ![object isKindOfClass:[Jastor class]]) return NO;
	
	Jastor *model = (Jastor *)object;
	
	return [self.objectId isEqualToString:model.objectId];
}

@end
