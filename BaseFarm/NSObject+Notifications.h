//
//  NSObject+Notifications.h
//  LetterFarm
//
//  Created by Daniel Mueller on 11/11/12.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (Notifications)

-(void)observeNotifications:(NSDictionary*)notifications;

@end

@interface NSNotification (Utilities)

-(BOOL)isNamed:(NSString*)name;

@end