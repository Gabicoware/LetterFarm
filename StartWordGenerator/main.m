//
//  main.m
//  StartWordGenerator
//
//  Created by Daniel Mueller on 10/15/12.
//
//

#import <Foundation/Foundation.h>
#import "Arguments.h"
#import "WordChecker.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        NSString* filePath = [Arguments argumentValueWithName:@"--input"];
        NSString* outputPath = [Arguments argumentValueWithName:@"--output"];
        NSString* lengthString = [Arguments argumentValueWithName:@"--length"];
        BOOL filter = [Arguments hasArgumentWithName:@"--filter-only"];
        
        
        if (filePath == nil || outputPath == nil || lengthString == nil) {
            
            [@"Requires \n\t--input={somefile} \n\t--output={someotherfile} \n\t--length=n" writeToFile:@"/dev/stdout" atomically:NO encoding:NSASCIIStringEncoding error:nil];
            
            return 0;
        }
        
        BOOL fileExists = NO;
        
        
        
        
        if ( filePath != nil ) {
            
            fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
            
        }
        
        NSLog(@"%@",filePath);
        
        if (!fileExists) {
            NSLog(@"File doesn't exist, closing");
        }else if(filter){
            WordChecker* checker = [[WordChecker alloc] init];
            
            [checker filterWordsInFile:filePath outputPath:outputPath length:[lengthString intValue]];
        }else{
            WordChecker* checker = [[WordChecker alloc] init];
            
            [checker processWordsInFile:filePath outputPath:outputPath length:[lengthString intValue]];
        }
        
    }
    return 0;
}

