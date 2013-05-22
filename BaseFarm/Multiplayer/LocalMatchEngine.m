//
//  LocalMatchEngine.m
//  LetterFarm
//
//  Created by Daniel Mueller on 3/18/13.
//
//

#import "LocalMatchEngine.h"
#import "MatchInfo.h"
#import "PuzzleGame.h"
#import "MatchInfo+Puzzle.h"

@implementation LocalMatchEngine

@synthesize allMatches;

-(id)init{
    if((self = [super init])){
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleDidBecomeActiveNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(BOOL)isAvailable{
    return YES;
}

-(void)handleDidBecomeActiveNotification:(id)notification{
    [self loadMatches];
}

-(NSString*)localMatchFilePath{
    [NSException raise:@"Unimplemented Exception" format:@"%@ must implement -localMatchFilePath", NSStringFromClass([self class])];
    return  nil;
}

-(NSString*)playerID{
    [NSException raise:@"Unimplemented Exception" format:@"%@ must implement -playerID", NSStringFromClass([self class])];
    return  nil;
}

-(void)loadMatches{
    
    
    self.allMatches = [NSMutableDictionary dictionary];
    
    NSString* path = [self localMatchFilePath];
    
    NSData* archiveData = [NSData dataWithContentsOfFile:path];
    
    NSArray* matches = nil;
    if (archiveData != nil) {
        @try {
            matches = [NSKeyedUnarchiver unarchiveObjectWithData:archiveData];
        }
        @catch (NSException *exception) {}
        @finally {}
    }
    
    BOOL shouldSave = NO;
    
    BOOL hasOneMatchInProgress = NO;
    
    if (matches != nil) {
        
        
        for (LocalSourceData* sourceData in matches) {
            
            MatchInfo* matchInfo = [self.allMatches objectForKey:sourceData.matchID];
            
            if (matchInfo == nil) {
                matchInfo = [[MatchInfo alloc] init];
                
                [self.allMatches setObject:matchInfo forKey:[sourceData matchID]];
            }
            
            [self updateMatchInfo:matchInfo withSourceData:sourceData];
            
            if(matchInfo.status == MatchStatusTheirTurn || matchInfo.status == MatchStatusYourTurn){
                hasOneMatchInProgress = YES;
            }
            
        }
        
    }
        
    if (shouldSave) {
        [self saveMatches];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MatchesDidLoadNotification object:self];
    
}

-(BOOL)completeMatch:(MatchInfo*)matchInfo{
    
    LocalSourceData* sourceData = OBJECT_IF_OF_CLASS( matchInfo.sourceData, LocalSourceData);
    
    sourceData.currentGame = nil;
    sourceData.matchStatus = matchInfo.status;
    
    [self saveMatch:matchInfo];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MatchesDidLoadNotification object:self];
    
    return NO;
}

-(BOOL)endTurnInMatch:(MatchInfo*)matchInfo{
    
    LocalSourceData* sourceData = OBJECT_IF_OF_CLASS( matchInfo.sourceData, LocalSourceData);
    
    sourceData.currentGame = nil;
    sourceData.matchStatus = MatchStatusTheirTurn;
    matchInfo.status = MatchStatusTheirTurn;
    
    [self saveMatch:matchInfo];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MatchesDidLoadNotification object:self];
    
    return NO;
}

-(void)quitMatch:(MatchInfo*)matchInfo{
    //we can safely delete this
    if ([[self.allMatches allValues] containsObject:matchInfo]) {
        LocalSourceData* sourceData = OBJECT_IF_OF_CLASS(matchInfo.sourceData, LocalSourceData);
        [[self allMatches] removeObjectForKey:sourceData.matchID];
    }
    
    [self saveMatches];
    [[NSNotificationCenter defaultCenter] postNotificationName:MatchesDidLoadNotification object:self];
}

-(void)deleteMatch:(MatchInfo*)match{
    
    if ([[self.allMatches allValues] containsObject:match]) {
        LocalSourceData* sourceData = OBJECT_IF_OF_CLASS(match.sourceData, LocalSourceData);
        [[self allMatches] removeObjectForKey:sourceData.matchID];
    }
    
    [self saveMatches];
    [[NSNotificationCenter defaultCenter] postNotificationName:MatchesDidLoadNotification object:self];
}

-(BOOL)canPlayWithMatchInfo:(MatchInfo*)matchInfo{
    return [matchInfo.sourceData isKindOfClass:[LocalSourceData class]] && matchInfo.status == MatchStatusYourTurn;
}

-(void)saveMatch:(MatchInfo*)match{
    LocalSourceData* sourceData = OBJECT_IF_OF_CLASS( match.sourceData, LocalSourceData);
    
    sourceData.currentGame = match.currentGame;
    sourceData.games = match.games;
    sourceData.startingDifficulty = match.startingDifficulty;
    
    if (![[self.allMatches allValues] containsObject:match]) {
        [[self allMatches] setObject:match forKey:sourceData.matchID];
    }
    
    [self saveMatches];
    
}

-(void)saveMatches{
    
    NSMutableArray* matches = [NSMutableArray array];
    for (MatchInfo* info in self.allMatches.allValues) {
        LocalSourceData* sourceData = OBJECT_IF_OF_CLASS(info.sourceData, LocalSourceData);
        [matches addObject:sourceData];
    }
    
    NSArray* result = [NSArray arrayWithArray:matches];
    
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:result];
    
    [data writeToFile:[self localMatchFilePath] atomically:YES];
    
}

-(void)loadMatchInfoWithSourceData:(id)sourceData completionHandler:( void (^) (MatchInfo* matchInfo))completionHandler{
    LocalSourceData* localSourceData = OBJECT_IF_OF_CLASS(sourceData, LocalSourceData);
    
    MatchInfo* matchInfo = [self.allMatches objectForKey:localSourceData.matchID];
    
    if (matchInfo == nil) {
        matchInfo = [[MatchInfo alloc] init];
        
        [self.allMatches setObject:matchInfo forKey:[localSourceData matchID]];
    }
    
    [self updateMatchInfo:matchInfo withSourceData:localSourceData];
    
    completionHandler(matchInfo);
    
}

-(void)updateMatchInfo:(MatchInfo*)matchInfo withSourceData:(LocalSourceData*)localSourceData{
    
    matchInfo.sourceData = localSourceData;
    
    matchInfo.currentGame = localSourceData.currentGame;
    
    matchInfo.matchID = localSourceData.matchID;
    
    int difficulty = [MatchInfo currentDifficultyWithMin:localSourceData.startingDifficulty games:localSourceData.games];
    
    matchInfo.tileViewLetter = [NSString stringWithFormat:@"%d", difficulty];
    
    matchInfo.createdDate = localSourceData.creationDate;
    matchInfo.games = localSourceData.games;
    
    matchInfo.updatedDate = localSourceData.updatedDate;
    
    //current status
    
    matchInfo.status = localSourceData.matchStatus;
}

-(BOOL)doesNeedReachability{
    return NO;
}
@end
