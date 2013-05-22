//
//  NSString+LF.h
//  Letter Farm
//
//  Created by Daniel Mueller on 4/25/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(LF)

-(NSArray*)letters;

-(NSString*)letterAtIndex:(NSInteger)index;

//in base 26
-(unsigned long)numericValue;

@end

@interface NSString (MD5HexDigest)
- (NSString*)md5HexDigest;
@end
