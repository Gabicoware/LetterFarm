//
//  NSObject+Notifications.m
//  LetterFarm
//
//  Created by Daniel Mueller on 11/11/12.
//
//

#import "NSObject+Notifications.h"

@implementation NSObject (Notifications)

-(void)observeNotifications:(NSDictionary*)notifications{
    for (NSString* key in [notifications allKeys]) {
        NSString* selectorName = [notifications objectForKey:key];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:NSSelectorFromString(selectorName)
                                                     name:key
                                                   object:nil];
    }

}

@end

@implementation NSNotification (Utilities)

-(BOOL)isNamed:(NSString*)name{
    return [[self name] isEqualToString:name];
}

@end