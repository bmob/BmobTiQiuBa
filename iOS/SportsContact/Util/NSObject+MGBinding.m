//
//  NSObject+MGBinding.m
//  Ticketing-OEM
//
//  Created by MiNG on 12-7-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSObject+MGBinding.h"
#import <objc/runtime.h>

const int kMGBindingPolicyAssign = OBJC_ASSOCIATION_ASSIGN;
const int kMGBindingPolicyRetainNonatomic = OBJC_ASSOCIATION_RETAIN_NONATOMIC;
const int kMGBindingPolicyCopyNonatomic = OBJC_ASSOCIATION_COPY_NONATOMIC;
const int kMGBindingPolicyRetain = OBJC_ASSOCIATION_RETAIN;
const int kMGBindingPolicyCopy = OBJC_ASSOCIATION_COPY;

@implementation NSObject (MGBinding)
- (id)bindingForKey:(MGBindingKey)key
{
	return objc_getAssociatedObject(self, key);	
}
- (void)setBinding:(id)object forKey:(MGBindingKey)key
{
	[self setBinding:object forKey:key bindingPolicy:kMGBindingPolicyRetainNonatomic];
}
- (void)setBinding:(id)object forKey:(MGBindingKey)key bindingPolicy:(kMGBindingPolicy)bindingPolicy
{
	objc_setAssociatedObject(self, key, object, (objc_AssociationPolicy)bindingPolicy);
}
- (void)removeBinding:(MGBindingKey)key
{
	objc_setAssociatedObject(self, key, nil, OBJC_ASSOCIATION_ASSIGN);
}
@end
