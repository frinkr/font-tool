//
//  Common.m
//  harfbuzz
//
//  Created by Yuqing Jiang on 10/18/17.
//
#import "Common.h"
#import <Foundation/Foundation.h>


@implementation NSString (NilFallback)
+ (instancetype)stringWithUTF8StringNilFallback:(const char *)utf8 {
    return [NSString stringWithUTF8String:utf8 withNullFallback:nil];
}

+ (instancetype)stringWithUTF8String:(const char *)utf8 withNullFallback:(NSString*)fallback {
    if (!utf8) return fallback;
    return [NSString stringWithUTF8String:utf8];
}

@end
