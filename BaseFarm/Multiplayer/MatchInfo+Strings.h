//
//  MatchInfo+Strings.h
//  LetterFarm
//
//  Created by Daniel Mueller on 2/23/13.
//
//

#import "MatchInfo.h"

@interface MatchInfo (Strings)

-(NSString*)mainString;

-(NSString*)detailString;


-(NSString*)outcomeString;

-(NSString*)vsString;

-(NSString*)roundString;

-(NSString*)timeString;

+(NSString*)timeStringWithDate:(NSDate*)date;

+(UIColor*)neutralColor;

-(UIColor*)matchColor;

@end
