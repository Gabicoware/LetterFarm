//
//  main.m
//  MassPuzzleGenerator
//
//  Created by Daniel Mueller on 1/31/13.
//
//

#import <Foundation/Foundation.h>
#import "Arguments.h"
#import "MassPuzzleGenerator.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        NSString* filePath = [Arguments argumentValueWithName:@"--input"];
        NSString* outputPath = [Arguments argumentValueWithName:@"--output"];
        
        if (filePath == nil || outputPath == nil ) {
            
            [@"Requires \n\t--input={somefile} \n\t--output={someotherfile} \n\t--length=n" writeToFile:@"/dev/stdout" atomically:NO encoding:NSASCIIStringEncoding error:nil];
            
            return 0;
        }
        
        BOOL directoryExists = NO;
        if ( filePath != nil ) {
            BOOL isDirectory = NO;
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
            directoryExists = fileExists && isDirectory;
        }
        
        NSLog(@"%@",filePath);
        
        if (!directoryExists) {
            NSLog(@"Directory doesn't exist, closing");
        }else{
            MassPuzzleGenerator* generator = [[MassPuzzleGenerator alloc] init];
            
            [generator generatePuzzlesFromDirectory:filePath toFile:outputPath];
            
        }

        
    }
    return 0;
}

