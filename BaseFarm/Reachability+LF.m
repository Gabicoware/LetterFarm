//
//  Reachability+LF.m
//  LetterFarm
//
//  Created by Daniel Mueller on 7/16/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "Reachability+LF.h"

@implementation Reachability (LF)

+(Reachability*)sharedReachability{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [Reachability reachabilityForInternetConnection];; // or some other init method
    });
    return _sharedObject;

}

#ifdef DEBUG
-(BOOL)shouldIgnoreReachability{
    return [[[NSProcessInfo processInfo] arguments] containsObject:@"IGNORE_REACHABILITY"];
}
#endif


@end
