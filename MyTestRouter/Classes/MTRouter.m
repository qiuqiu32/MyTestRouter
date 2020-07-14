//
//  MTRouter.m
//  MyComponentA_Example
//
//  Created by mac on 2020/7/14.
//  Copyright © 2020 1442687881@qq.com. All rights reserved.
//

#import "MTRouter.h"
#import <objc/runtime.h>


@interface MTRouter()

@property (nonatomic, strong) NSMutableDictionary *cachedTarget;

@end

@implementation MTRouter
static MTRouter *mtRouter;

+(instancetype)sharedInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mtRouter = [[MTRouter alloc] init];
    });
    return mtRouter;
}


-(NSMutableDictionary *)cachedTarget{
    if (_cachedTarget == nil) {
        _cachedTarget = [[NSMutableDictionary alloc] init];
        
    }
    return _cachedTarget;
    
}

- (id)performInstance:(NSString *)targetName isCacheTarget:(BOOL)isCacheTarget;{
    Class targetClass;

    NSObject *target = self.cachedTarget[targetName];
    if (target == nil) {
       targetClass = NSClassFromString(targetName);
       target = [[targetClass alloc] init];
    }

    if (target == nil) {
       
       return nil;
    }
    if (isCacheTarget) {
        self.cachedTarget[targetName] = target;
    }
    return target;
}

- (id)performTarget:(NSString *)targetName action:(NSString *)actionName arguments:(NSArray *)arguments isCacheTarget:(BOOL)isCacheTarget{
    
    Class targetClass;
    
    NSObject *target = self.cachedTarget[targetName];
    if (target == nil) {
        targetClass = NSClassFromString(targetName);
        target = [[targetClass alloc] init];
    }
    
    SEL action =  NSSelectorFromString(actionName);
    
    if (target == nil) {
        
        return nil;
    }
    
    if (isCacheTarget) {
        self.cachedTarget[targetName] = target;
    }
    
    if ([target respondsToSelector:action]) {
        return [self safePerformAction:action target:target arguments:arguments];
    }
    
    
    
    return nil;
}

- (id)safePerformAction:(SEL)action target:(NSObject *)target arguments:(NSArray *)arguments{
    
    //获取实例方法签名 或用 [ [target class] instanceMethodSignatureForSelector]
    NSMethodSignature *methodSig = [target methodSignatureForSelector:action];
    
    if (methodSig == nil) {
        //获取类方法签名
        methodSig = [[target class] methodSignatureForSelector:action];
        if (methodSig == nil) {
           return nil;
        }
    }
    
    Method method = class_getClassMethod([target class], action);
    int argumentCount = method_getNumberOfArguments(method);
    if (argumentCount > (arguments.count + 2)) return nil;
    
    const char *retType = [methodSig methodReturnType];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
    
    [invocation setTarget:target];
    [invocation setSelector:action];
    
    for (int i = 2; i < argumentCount; i ++) {
        id valObj = arguments[i - 2];
        const char *argumentType = [methodSig getArgumentTypeAtIndex:i];
        switch (argumentType[0] == 'r' ? argumentType[1] : argumentType[0]) {
            case 'i':{
                int val = [valObj intValue];
                [invocation setArgument:&val atIndex:i];
            }
            case '#':{
                [invocation setArgument:&valObj atIndex:i];
            }
            break;
           
                
        }
    }
    [invocation invoke];
    
    NSString *selName = NSStringFromSelector(action);
    if (strncmp(retType, "v", 1) != 0 ) {
      if (strncmp(retType, "@", 1) == 0) {
          void *result;
          [invocation getReturnValue:&result];
          
          if (result == NULL) {
              return nil;
          }
          
          id returnValue;
          if ([selName isEqualToString:@"alloc"] || [selName isEqualToString:@"new"] || [selName isEqualToString:@"copy"] || [selName isEqualToString:@"mutableCopy"]) {
              returnValue = (__bridge_transfer id)result;
          }else{
              returnValue = (__bridge id)result;
          }
          return returnValue;
          
      }
    }
    
    
    return nil;
}


@end
