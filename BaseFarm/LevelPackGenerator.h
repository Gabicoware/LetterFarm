//
//  LevelPackGenerator.h
//  LetterFarm
//
//  Created by Daniel Mueller on 2/10/13.
//
//

#import "BaseGenerator.h"
#import "BaseFarm.h"

@interface LevelPackGenerator : NSObject

@property (nonatomic) id result;


//generates the results and sends a message to the target and returns instantly
-(void)generateInBackground;

-(void)generate;

-(id)generateResult;

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL action;

@property (nonatomic) Difficulty difficulty;

@property (atomic) int generatedCount;

@end
