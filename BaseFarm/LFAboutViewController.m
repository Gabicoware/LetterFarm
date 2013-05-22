//
//  LFAboutViewController.m
//  LetterFarm
//
//  Created by Daniel Mueller on 7/9/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "LFAboutViewController.h"

@interface LFAboutViewController ()

-(IBAction)didTapLinkButton:(id)sender;

@property (nonatomic) IBOutlet UILabel* versionLabel;

@property (nonatomic) IBOutlet UIView* contentView;

@property (nonatomic, retain) IBOutlet UITableView* tableView;

@end

@implementation LFAboutViewController

@synthesize versionLabel=_versionLabel;

-(void)viewDidLoad{
    [super viewDidLoad];
    
    NSString* versionString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    self.versionLabel.text = [NSString stringWithFormat:@"Version: %@", versionString];
    [self.tableView reloadData];
    self.tableView.backgroundView = nil;
}

-(IBAction)didTapLinkButton:(id)sender{
    
    UIButton* linkButton = OBJECT_IF_OF_CLASS(sender, UIButton);
    NSString * linkTitle = [linkButton titleForState:UIControlStateNormal];
    NSURL* URL = [NSURL URLWithString:linkTitle];
    
    if([[UIApplication sharedApplication] canOpenURL:URL]){
        [[UIApplication sharedApplication] openURL:URL]; 
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* identifier = @"AboutIdentifier";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [[cell contentView] addSubview:self.contentView];
    }
    
    return cell;
    
}
-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.contentView.frame.size.height;
}


@end
