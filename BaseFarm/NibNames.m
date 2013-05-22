//
//  NibNames.m
//  Letter Farm
//
//  Created by Daniel Mueller on 6/29/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "NibNames.h"

#define isIPhone [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone

@implementation NibNames

+(NSString*)idiomizeName:(NSString*)name{
    if (isIPhone) {
        return [name stringByAppendingString:@"_iPhone"];
    } else {
        return [name stringByAppendingString:@"_iPad"];
    }
    
}

#pragma mark universal views

+(NSString*)mainView{
    return [self idiomizeName:@"MainViewController"];
}

+(NSString*)matchView{
    return @"MatchViewController";
}

+(NSString*)aboutView{
    return @"LFAboutViewController";
}

+(NSString*)tableView{
    return @"LFTableViewController";
}

+(NSString*)modalTableView{
    return @"LFModalTableViewController";
}

+(NSString*)selectLevelView{
    return @"SelectLevelViewController";
}

+(NSString*)createPackView{
    return @"CreatePackViewController";
}

+(NSString*)menuView{
    if (isIPhone) {
        return [NibNames idiomizeName:@"BFMenuViewController"];
    } else {
        return [NibNames tableView];
    }

}

#pragma mark puzzle views

+(NSString*)puzzleGameView{
    return [NibNames idiomizeName:@"PuGameViewController"];
}

+(NSString*)puzzleCompleteView{
    return @"PuCompleteViewController";
}

+(NSString*)matchGameCompleteView{
    return @"MatchGameCompleteViewController";
}
    
@end
