//
//  MatchListComponent.h
//  LetterFarm
//
//  Created by Daniel Mueller on 7/22/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MatchInfo.h"

@protocol MatchListMediator;

@protocol MatchListComponent <NSObject>

@property (nonatomic, weak) id<MatchListMediator> mediator;

-(void)updateMatches:(NSArray*)matches;

@property (nonatomic) BOOL isNetworkReachable;

@end

@protocol MatchListMediator <NSObject>

@property (nonatomic, weak) id<MatchListComponent> component;

-(void)reloadMatches;

-(void)quitMatch:(MatchInfo*)match;

-(void)deleteMatch:(MatchInfo*)match;

-(void)loadDataForMatch:(MatchInfo*)match withCompletionHandler:(void (^)(BOOL finished))completionHandler;

@end
