//
//  NSArray+LF.h
//  LetterFarm
//
//  Created by Daniel Mueller on 7/17/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (LF)

-(id)arrayByRemovingObject:(id)object;

@end

@interface NSMutableArray (Shuffling)
- (void)shuffle;
@end
