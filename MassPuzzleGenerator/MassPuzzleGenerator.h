//
//  MassPuzzleGenerator.h
//  LetterFarm
//
//  Created by Daniel Mueller on 1/31/13.
//
//

#import <Foundation/Foundation.h>

@interface MassPuzzleGenerator : NSObject

-(void)generatePuzzlesFromDirectory:(NSString*)inputDir toFile:(NSString*)output;

@end
