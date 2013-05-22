//
//  SelectPackViewController.m
//  LetterFarm
//
//  Created by Daniel Mueller on 2/11/13.
//
//

#import "SelectPackViewController.h"
#import "LevelManager.h"
#import "LetterFarmSinglePlayer.h"

#define BUTTON_TAG_OFFSET 888


@interface SelectPackViewController ()

@property (nonatomic) BOOL isPending;

@end


@implementation SelectPackViewController{
    NSArray* _buttons;
    NSArray* _completePacks;
    NSArray* _incompletePacks;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 1 && _completePacks.count > 0) {
        return @"Complete";
    }
    return nil;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    NSMutableArray* mutableCompletePacks = [NSMutableArray array];
    NSMutableArray* mutableIncompletePacks = [NSMutableArray array];
    
    for (int index = 0; index < [[LevelManager sharedLevelManager] packCount]; index++) {
        
        NSString* packName = [[LevelManager sharedLevelManager] packNameAtIndex:index];
        if ([[LevelManager sharedLevelManager] completedGameCountWithName:packName] < [[LevelManager sharedLevelManager] totalGameCountWithName:packName]) {
            [mutableIncompletePacks addObject:packName];
        }else{
            [mutableCompletePacks addObject:packName];
        }
        
    }
    
    _completePacks = [NSArray arrayWithArray:mutableCompletePacks];
    _incompletePacks = [NSArray arrayWithArray:mutableIncompletePacks];
    
    return 2;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        return [_incompletePacks count] + 1;
    }else{
        return [_completePacks count];
    }
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* identifier = @"PackTableViewCellIdentifier";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    
    NSString* packName = nil;
    
    NSArray* packNames = [indexPath section] == 0 ? _incompletePacks : _completePacks;
    
    if ([indexPath row] < [packNames count]) {
        packName = [packNames objectAtIndex:[indexPath row]];
    }
    
    [[cell textLabel] setTextColor:[UIColor blackColor]];
    [[cell imageView] setAlpha:1.0];
    
    //if there is no pack name, we assume its a create row
    if(packName != nil){
        
        NSString* packTitle = [[LevelManager sharedLevelManager] packTitleWithName:packName];
        NSString* packTheme = [[LevelManager sharedLevelManager] packThemeWithName:packName];
        
        
        NSString* imageName = @"summer_button";
        
        if ([packTheme isEqualToString:WorldThemeWinter]) {
            imageName = @"winter_button";
        }else if ([packTheme isEqualToString:WorldThemeAutumn]) {
            imageName = @"autumn_button";
        }else if ([packTheme isEqualToString:WorldThemeSpring]) {
            imageName = @"spring_button";
        }
        
        NSInteger completeCount = [[LevelManager sharedLevelManager] completedGameCountWithName:packName];
        NSInteger totalCount = [[LevelManager sharedLevelManager] totalGameCountWithName:packName];
        
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d of %d complete", completeCount, totalCount];
        
        cell.textLabel.text = packTitle;
        
        cell.imageView.image = [UIImage imageNamed:imageName];
        
    }else{
        
        cell.imageView.image = [UIImage imageNamed:@"create_pack_button"];
        
        cell.textLabel.text = @"Create New Pack";
        
        cell.detailTextLabel.text = @"";

    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row < _incompletePacks.count) {
        NSString* packName = [_incompletePacks objectAtIndex:indexPath.row];
        [self selectPack:packName];
    }else if (indexPath.section == 1 && indexPath.row < _completePacks.count) {
        NSString* packName = [_completePacks objectAtIndex:indexPath.row];
        [self selectPack:packName];
    }else{
        [self createPack];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)createPack{
    [[NSNotificationCenter defaultCenter] postNotificationName:CreatePackNotification object:self];
}


-(void)selectPack:(NSString*)packName{
        
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:packName,SelectPackNameKey, nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SelectPackNotification
                                                        object:self
                                                      userInfo:userInfo];
    
}


@end
