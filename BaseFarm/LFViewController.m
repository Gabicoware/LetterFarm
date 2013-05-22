//
//  LFViewController.m
//  LetterFarm
//
//  Created by Daniel Mueller on 11/13/12.
//
//

#import "LFViewController.h"

@implementation LFViewController

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[Analytics sharedAnalytics] trackScreen:self.categoryName];
}

-(NSString*)categoryName{
    if (self.viewName != nil) {
        return self.viewName;
    }else{
        return [super categoryName];
    }
}

@end
