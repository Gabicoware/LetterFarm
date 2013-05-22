//
//  WordChecker.h
//  LetterFarm
//
//  Created by Daniel Mueller on 10/15/12.
//
//

#import <Foundation/Foundation.h>

@interface WordChecker : NSObject

-(void)processWordsInFile:(NSString*)filePath outputPath:(NSString*)outputPath length:(int)length;

-(void)filterWordsInFile:(NSString*)filePath outputPath:(NSString*)outputPath length:(int)minLength;

@end
