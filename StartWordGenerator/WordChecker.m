//
//  WordChecker.m
//  LetterFarm
//
//  Created by Daniel Mueller on 10/15/12.
//
//

#import "WordChecker.h"
#import "WordMovesGenerator.h"
#import "WordUtilities.h"


@implementation WordChecker

-(NSArray*)arrayFromFilePath:(NSString*)filePath{
    
    NSError* error = nil;
    
    NSString* contentString = [NSString stringWithContentsOfFile:filePath
                                                        encoding:NSASCIIStringEncoding
                                                           error:&error];
    
    NSString* formattedContentString = [[contentString lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return [formattedContentString componentsSeparatedByString:@"\n"];
    
}

-(void)writeArray:(NSArray*)array toFilePath:(NSString*)filePath{
        
    NSString* contentString = [array componentsJoinedByString:@"\n"];
    
    [contentString writeToFile:filePath atomically:NO encoding:NSASCIIStringEncoding error:nil];
}

-(void)filterWordsInFile:(NSString*)filePath outputPath:(NSString*)outputPath length:(int)minLength{
    
    NSArray* words = [self arrayFromFilePath:filePath];
    NSArray* lengths = [self arrayFromFilePath:outputPath];
    
    int count = (int)[words count];
    
    NSMutableArray* filteredLengths = [NSMutableArray array];
    NSMutableArray* filteredWords = [NSMutableArray array];
    
    for (int index = 0; index < count; index++) {
        
        NSString* word = (NSString*)[words objectAtIndex:index];
        NSString* length = (NSString*)[lengths objectAtIndex:index];
        
        if (minLength <= [length intValue]) {
            [filteredLengths addObject:length];
            [filteredWords addObject:word];
        }
        
    }

    [self writeArray:filteredLengths toFilePath:[outputPath stringByAppendingString:@".out"]];
    [self writeArray:filteredWords toFilePath:[filePath stringByAppendingString:@".out"]];
}

-(void)processWordsInFile:(NSString*)filePath outputPath:(NSString*)outputPath length:(int)length{
    NSArray* words = [self arrayFromFilePath:filePath];
    
    WordMovesGenerator* generator = [[WordMovesGenerator alloc] initWithWords:[NSSet setWithArray:words]];
    generator.maxMoves = length;
    
    int count = (int)[words count];
    
    NSMutableArray* lengthsArray = [NSMutableArray array];
    
    for (int index = 0; index < count; index++) {
        
        NSString* word = (NSString*)[words objectAtIndex:index];
        
        generator.startWord = word;
        @try {
            [generator generate];
            [lengthsArray addObject:[generator result]];
        
        }
        @catch (NSException *exception) {
            NSLog(@"Generation failed on %@",word);
            NSLog(@"%@",exception);
            [lengthsArray addObject:[NSNumber numberWithInt:0]];
        }
        @finally {
            
        }
        
        if (index%25 == 0) {
            NSLog(@"%d of %d",index, count);
        }
        
    }
    
    [self writeArray:lengthsArray toFilePath:outputPath];
        
    
}

@end
