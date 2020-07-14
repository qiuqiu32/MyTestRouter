//
//  MTRouter.h
//  MyComponentA_Example
//
//  Created by mac on 2020/7/14.
//  Copyright © 2020 1442687881@qq.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTRouter : NSObject

+(instancetype)sharedInstance;

- (id)performTarget:(NSString *)targetName action:(NSString *)actionName arguments:(NSArray *)arguments isCacheTarget:(BOOL)isCacheTarget;

- (id)performInstance:(NSString *)targetName isCacheTarget:(BOOL)isCacheTarget;

@end

NS_ASSUME_NONNULL_END
