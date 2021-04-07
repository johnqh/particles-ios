//
//  NSObject+Class.m
//  Utilities
//
//  Created by Qiang Huang on 10/10/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

#import "NSObject+Class.h"

@implementation NSObject (Class)

- (NSArray<NSString *> *)classNames
{
    NSMutableArray<NSString *> *classNames = [NSMutableArray array];
    Class class = self.class;
    while (class != nil) {
        [classNames addObject:NSStringFromClass(class)];
        class = [class superclass];
    }
    return classNames;
}

- (NSString *)className {
    return [[self classNames] firstObject];
}

@end
