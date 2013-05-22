//
//  LFPreferencesViewController.m
//  LetterFarm
//
//  Created by Daniel Mueller on 11/10/12.
//
//

#import "LFPreferencesViewController.h"

#import "TableViewCellFactory.h"
#import "LocalConfiguration.h"

enum GeneralPreferencesRows {
    GeneralPreferencesRowsUsage,
    GeneralPreferencesRowsName,
    GeneralPreferencesRowsTotal,
};

@interface LFPreferencesViewController()

-(NSArray*)availableTileImageNames;

@end

@implementation LFPreferencesViewController

-(NSArray*)availableTileImageNames{
    return @[@"sheep", @"gold_sheep", @"cow"];
}

-(NSString*)titleWithTileImageName:(NSString*)name{
    if ([name isEqualToString:@"sheep"]) {
        return @"Sheep";
    }else if ([name isEqualToString:@"gold_sheep"]) {
        return @"Golden Sheep";
    }else if ([name isEqualToString:@"cow"]) {
        return @"Cow";
    }
    
    return nil;
}

-(BOOL)isSelectedTileImage:(NSString*)name{
    return [[[LocalConfiguration sharedLocalConfiguration] tileImageName] isEqualToString:name];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return GeneralPreferencesRowsTotal;
    }else{
        return [self availableTileImageNames].count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case GeneralPreferencesRowsUsage:
                cell = [self tableView:tableView switchCellForRowAtIndexPath:indexPath];
                break;
            case GeneralPreferencesRowsName:
            //case GeneralPreferencesRowsEmail:
                cell = [self tableView:tableView textFieldCellForRowAtIndexPath:indexPath];
                break;
            default:
                break;
        }
    }else{
        cell = [self tableView:tableView animalCellForRowAtIndexPath:indexPath];
    }
    
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView animalCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* AnimalTableViewCellIdentifier = @"AnimalTableViewCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AnimalTableViewCellIdentifier];
    
    if (cell == nil) {
        cell = [TableViewCellFactory newAnimalTableViewCellWithReuseIdentifier:AnimalTableViewCellIdentifier];
    }
    
    NSString* name = [[self availableTileImageNames] objectAtIndex:indexPath.row];
    
    [cell.tileView setTileImageName:name];
    
    cell.textLabel.text = [self titleWithTileImageName:name];
    
    cell.accessoryType = [self isSelectedTileImage:name] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView switchCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* SwitchTableViewCellIdentifier = @"SwitchTableViewCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SwitchTableViewCellIdentifier];
    
    if (cell == nil) {
        cell = [TableViewCellFactory newSwitchTableViewCellWithReuseIdentifier:SwitchTableViewCellIdentifier];
        [[cell uiSwitch] addTarget:self action:@selector(didValueChangeControl:) forControlEvents:UIControlEventValueChanged];
    }
    
    switch (indexPath.row) {
        case GeneralPreferencesRowsUsage:
            [[cell uiSwitch] setOn:self.usageTrackingEnabled];
            [[cell textLabel] setText:@"Usage Tracking"];
            break;
        default:
            break;
    }
    
    return cell;
    
}

-(void)didValueChangeControl:(UISwitch*)sender{
    
    NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:[self.tableView convertPoint:CGPointZero fromView:sender]];
    
    if (indexPath.row ==  GeneralPreferencesRowsUsage) {
        [self setIsUsageTrackingEnabled:sender.isOn];
    }
}

-(BOOL)usageTrackingEnabled{
    BOOL enabled = ![[LocalConfiguration sharedLocalConfiguration] isUsageTrackingDisabled];
    return enabled;
}

-(void)setIsUsageTrackingEnabled:(BOOL)isUsageTrackingEnabled{
    [[LocalConfiguration sharedLocalConfiguration] setIsUsageTrackingDisabled:!isUsageTrackingEnabled];
}

#define TEXT_FIELD_TAG_OFFSET 5001

- (UITableViewCell *)tableView:(UITableView *)tableView textFieldCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *TetFieldTableViewCellIdentifier = @"TetFieldTableViewCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TetFieldTableViewCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TetFieldTableViewCellIdentifier];
        
        if (indexPath.section == 0) {
            
            // Add a UITextField
            UITextField *textField = [[UITextField alloc] init];
            // Set a unique tag on each text field
            textField.tag = TEXT_FIELD_TAG_OFFSET + indexPath.row;
            // Add general UITextAttributes if necessary
            textField.enablesReturnKeyAutomatically = YES;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            textField.font = [textField.font fontWithSize:15.0];
            [cell.contentView addSubview:textField];
        }
    }
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


- (void)configureCell:(UITableViewCell *)theCell atIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        // Get the text field using the tag
        UITextField *textField = (UITextField *)[theCell.contentView viewWithTag:TEXT_FIELD_TAG_OFFSET+indexPath.row];
        // Position the text field within the cell bounds
        CGRect cellBounds = theCell.bounds;
        CGFloat textLeftMargin = 65.0;
        CGFloat textRightMargin = 20.0;
        // Don't align the field exactly in the vertical middle, as the text
        // is not actually in the middle of the field.
        CGRect aRect = CGRectMake(textLeftMargin, 12.f, CGRectGetWidth(cellBounds)-textRightMargin-textLeftMargin, 31.f );
        
        textField.frame = aRect;
        
        // Configure UITextAttributes for each field
        if(indexPath.row == GeneralPreferencesRowsName) {
            theCell.textLabel.text = @"Name";
            textField.placeholder = @"Optional";
            textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            textField.text = [[LocalConfiguration sharedLocalConfiguration] playerName];
        } /*else if(indexPath.row == GeneralPreferencesRowsEmail) {
            theCell.textLabel.text = @"Email";
            textField.placeholder = @"Required for email matches";
            textField.keyboardType = UIKeyboardTypeEmailAddress;
            textField.text = [[LocalConfiguration sharedLocalConfiguration] playerEmail];
        }*/
        textField.returnKeyType = UIReturnKeyDone;
        textField.delegate = self;
        [theCell.contentView addSubview:textField];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    int row = textField.tag - TEXT_FIELD_TAG_OFFSET;
    
    if(row == GeneralPreferencesRowsName) {
        [[LocalConfiguration sharedLocalConfiguration] setPlayerName:textField.text];
    }/* else if(row == GeneralPreferencesRowsEmail) {
        [[LocalConfiguration sharedLocalConfiguration] setPlayerEmail:textField.text];
    }*/
    
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    int row = textField.tag - TEXT_FIELD_TAG_OFFSET;
    
    if(row == GeneralPreferencesRowsName) {
        [[LocalConfiguration sharedLocalConfiguration] setPlayerName:textField.text];
    }/* else if(row == GeneralPreferencesRowsEmail) {
        [[LocalConfiguration sharedLocalConfiguration] setPlayerEmail:textField.text];
    }*/
    
    [textField resignFirstResponder];
    return YES;
}

-(NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return nil;
    }
    return indexPath;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString* selectedName = [self.availableTileImageNames objectAtIndex:indexPath.row];
    
    [[LocalConfiguration sharedLocalConfiguration] setTileImageName:selectedName];
    
    for (int index = 0; index < self.availableTileImageNames.count; index++) {
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:indexPath.section]];
        
        NSString* name = [self.availableTileImageNames objectAtIndex:index];
        
        cell.accessoryType = [self isSelectedTileImage:name] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        
    }

}

@end
