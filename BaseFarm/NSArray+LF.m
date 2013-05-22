//
//  NSArray+LF.m
//  LetterFarm
//
//  Created by Daniel Mueller on 7/17/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "NSArray+LF.h"

@implementation NSArray (LF)

-(id)arrayByRemovingObject:(id)object{
    NSMutableArray* mutableSelf = [self mutableCopy];
    
    if ([mutableSelf containsObject:object]) {
        [mutableSelf removeObject:object];
    }
    
    NSArray* result = [NSArray arrayWithArray:mutableSelf];
    
    return result;
    
}

@end

@implementation NSMutableArray (Shuffling)

- (void)shuffle
{
    static BOOL seeded = NO;
    if(!seeded)
    {
        seeded = YES;
        srandom((uint)time(NULL));
    }
    
    int count = (int)[self count];
    for (int i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        int nElements = count - i;
        int n = (random() % nElements) + i;
        [self exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

@end
