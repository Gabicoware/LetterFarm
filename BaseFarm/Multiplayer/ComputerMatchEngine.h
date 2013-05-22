//
//  ComputerMatchEngine.h
//  LetterFarm
//
//  Created by Daniel Mueller on 7/23/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalMatchEngine.h"
#import "LocalSourceData.h"

extern NSString* CMatchesDidLoadNotification;

@interface ComputerMatchEngine : LocalMatchEngine

+(id)sharedComputerMatchEngine;

@end

