//
//  PassNPlayMatchEngine.h
//  LetterFarm
//
//  Created by Daniel Mueller on 1/13/13.
//
//

#import <UIKit/UIKit.h>
#import "LocalMatchEngine.h"
#import "PassNPlaySourceData.h"

@interface PassNPlayMatchEngine : LocalMatchEngine

+(id)sharedPassNPlayMatchEngine;

-(void)updateGame:(id)game forMatch:(MatchInfo*)matchInfo;

@end
