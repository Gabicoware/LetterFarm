//
//  RemoteLoader.m
//  LetterFarm
//
//  Created by Daniel Mueller on 10/5/12.
//
//

#import "RemoteLoader.h"

@interface RemoteLoader()

@property (nonatomic) NSURLConnection* connection;

@property (nonatomic) id completionBlock;

@property (nonatomic) NSURL* sourceURL;

@end

@implementation RemoteLoader

@synthesize connection=_connection, completionBlock=_completionBlock;
@synthesize sourceURL=_sourceURL;

-(void)dealloc{
    if (self.completionBlock != nil) {
        void (^completion)(BOOL) = self.completionBlock;
        completion(NO);
    }
}

-(void)downloadFileAtURL:(NSURL*)sourceURL completionHandler:(void (^)(BOOL))completionHandler{
    
    self.sourceURL=sourceURL;
    
    self.completionBlock = [completionHandler copy];
    
    self.receivedData = [NSMutableData data];
    
    //it is a tiny request, very infrequent and we always need the latest version
    NSURLRequest* request = [NSURLRequest requestWithURL:sourceURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5.0];
    
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
        
    [self.connection start];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    void (^completion)(BOOL) = self.completionBlock;
    completion(YES);
    
    self.connection = nil;
    self.receivedData = nil;
    self.completionBlock = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    void (^completion)(BOOL) = self.completionBlock;
    completion(NO);
    
    self.connection = nil;
    self.receivedData = nil;
    self.completionBlock = nil;
}

@end