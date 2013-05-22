//
//  RemoteLoader.h
//  LetterFarm
//
//  Created by Daniel Mueller on 10/5/12.
//
//

#import <Foundation/Foundation.h>

//good for smaller files
@interface RemoteLoader : NSObject <NSURLConnectionDataDelegate>

//!downloads the file, notifies the local configuration object when complete
-(void)downloadFileAtURL:(NSURL*)sourceURL completionHandler:(void(^)(BOOL finished))completionHandler;

@property (nonatomic, retain) NSMutableData* receivedData;

@end
