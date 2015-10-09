//
//  NSObject+MGBinding.h
//  Ticketing-OEM
//
//  Created by MiNG on 12-7-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef const int kMGBindingPolicy;
extern const int kMGBindingPolicyAssign;
extern const int kMGBindingPolicyRetainNonatomic;
extern const int kMGBindingPolicyCopyNonatomic;
extern const int kMGBindingPolicyRetain;
extern const int kMGBindingPolicyCopy;

typedef const char *const MGBindingKey;
#define MG_DEFINE_BINDING_KEY(key) static MGBindingKey key = #key;

@interface NSObject (MGBinding)
- (void)setBinding:(id)object forKey:(MGBindingKey)key;
- (void)setBinding:(id)object forKey:(MGBindingKey)key bindingPolicy:(kMGBindingPolicy)bindingPolicy;
- (id)bindingForKey:(MGBindingKey)key;
- (void)removeBinding:(MGBindingKey)key;
@end
