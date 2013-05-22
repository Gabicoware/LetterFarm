//
//  LFMoreViewController.m
//  LetterFarm
//
//  Created by Daniel Mueller on 11/10/12.
//
//

#import "LFMoreViewController.h"
#import "LocalConfiguration.h"

typedef enum _MoreRow{
    MoreRowAbout,
#ifndef COLOR_WORD
    MoreRowStore,
#endif
    MoreRowContact,
    MoreRowPreferences,
}MoreRow;

NSString* MoreAbout = @"MoreAbout";
NSString* MoreStore = @"MoreStore";
NSString* MoreContact = @"MoreContact";
NSString* MorePreferences = @"MorePreferences";

@interface LFMoreViewController()

@property (nonatomic, retain) NSArray* rows;

@end


@implementation LFMoreViewController

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSMutableArray* mRows = [NSMutableArray array];
    [mRows addObject:[NSNumber numberWithInt:MoreRowAbout]];
#ifndef COLOR_WORD
    [mRows addObject:[NSNumber numberWithInt:MoreRowStore]];
#endif
    [mRows addObject:[NSNumber numberWithInt:MoreRowContact]];
    [mRows addObject:[NSNumber numberWithInt:MoreRowPreferences]];
    
    self.rows = [NSArray arrayWithArray:mRows];
    return self.rows.count;
}

-(MoreRow)moreRowWithPath:(NSIndexPath*)indexPath{
    NSNumber* number = [self.rows objectAtIndex:[indexPath row]];
    return [number intValue];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    
    static NSString* CellIdentifier = @"MoreTableViewCell";
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    MoreRow row = [self moreRowWithPath:indexPath];
    
    switch (row) {
        case MoreRowAbout:
            [[cell textLabel] setText:@"About"];
            break;
#ifndef COLOR_WORD
        case MoreRowStore:
            [[cell textLabel] setText:@"Store"];
            break;
#endif
        case MoreRowContact:
            [[cell textLabel] setText:@"Feedback"];
            break;
        case MoreRowPreferences:
            [[cell textLabel] setText:@"Preferences"];
            break;
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString* notificationName = nil;
    MoreRow row = [self moreRowWithPath:indexPath];
                                                     
    switch (row) {
        case MoreRowAbout:
            notificationName = MoreAbout;
            break;
#ifndef COLOR_WORD
        case MoreRowStore:
            notificationName = MoreStore;
            break;
#endif
        case MoreRowContact:
            notificationName = MoreContact;
            break;
        case MoreRowPreferences:
            notificationName = MorePreferences;
            break;
    }
    if (notificationName != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                            object:self];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


@end
