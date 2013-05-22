//
//  Reachability+LF.h
//  LetterFarm
//
//  Created by Daniel Mueller on 7/16/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "Reachability.h"

@interface Reachability (LF)

+(Reachability*)sharedReachability;

#ifdef DEBUG
-(BOOL)shouldIgnoreReachability;
#endif
@end
