//
//  BaseGenerator.h
//  LetterFarm
//
//  Created by Daniel Mueller on 9/20/12.
//
//

#import <Foundation/Foundation.h>

@interface BaseGenerator : NSObject

-(id)initWithWords:(NSSet*)words;

@property (nonatomic) NSSet* words;
@property (nonatomic) id result;


//generates the results and sends a message to the target and returns instantly
-(void)generateInBackground;

//! generates the results, and sends a message to the target
-(void)generate;

//!generate the results
/*!
 * This returns the results directly, bypass sending the message to the 
 * target, and setting the result on the receiver
 *
 */
-(id)generateResult;

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL action;

//! properties for internal use
@property (nonatomic) NSMutableDictionary* sourcesDictionary;
@property (nonatomic) NSMutableDictionary* levelsDictionary;

-(NSMutableArray*)resultWordsWithStart:(NSString*)start finish:(NSString*)finish moves:(int)moves;
-(NSSet*)wordsForMove:(int)move currentWords:(NSSet*)currentWords;

-(BOOL)isCandidateLegal:(NSString*)candidateWord forWord:(NSString*)word inMoves:(int)moves;

@end
