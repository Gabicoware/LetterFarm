//
//  LocalMatchEngine.h
//  LetterFarm
//
//  Created by Daniel Mueller on 3/18/13.
//
//

#import <Foundation/Foundation.h>
#import "MatchEngine.h"
#import "LocalSourceData.h"

//abstract base class
@interface LocalMatchEngine : NSObject<MatchEngine>

-(void)saveMatches;

-(NSString*)localMatchFilePath;

-(NSString*)playerID;

//do not call directly
-(void)updateMatchInfo:(MatchInfo*)matchInfo withSourceData:(LocalSourceData*)localSourceData;

@end
