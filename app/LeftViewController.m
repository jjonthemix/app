//
//  LeftViewController.m
//  app
//
//  Created by Joel Oliveira on 16/04/14.
//  Copyright (c) 2014 Notificare. All rights reserved.
//

#import "LeftViewController.h"
#import "AppDelegate.h"
#import "DefaultCell.h"


@interface LeftViewController ()

@end

@implementation LeftViewController



- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


#pragma mark - Table delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [[self navSections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[[self navSections] objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString* cellType = @"DefaultCell";
    DefaultCell * cell = (DefaultCell *)[tableView dequeueReusableCellWithIdentifier:cellType];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellType owner:nil options:nil];
        cell = (DefaultCell*)[nib objectAtIndex:0];
    }
    //    NSDictionary * item = (NSDictionary *)[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
    //
    //    [[cell tagLabel] setText:[item objectForKey:@"label"]];
    //    [[cell tagLabel] setFont:MONTSERRAT_FONT(12)];
    //
    //    if([[item objectForKey:@"active"] isEqual:[NSNumber numberWithBool:YES]]){
    //        [[cell tagSwitch] setOn:YES];
    //    } else {
    //        [[cell tagSwitch] setOn:NO];
    //    }
    //
    //
    //    UISwitch * switchTag = [(DefaultCell *)cell tagSwitch];
    //    [switchTag setTag:(([indexPath section] * 100) + [indexPath row])];
    //    [switchTag addTarget:self action:@selector(changeTag:) forControlEvents:UIControlEventValueChanged];
    //
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return MENU_CELLHEIGHT;
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, MENU_HEADER_HEIGHT)];
    headerView.backgroundColor = [UIColor clearColor];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, self.view.frame.size.width - 50, MENU_HEADER_HEIGHT)];
    [label setText:[[self sectionTitles] objectAtIndex:section]];
    [label setFont:MONTSERRAT_BOLD_FONT(16)];
    [label setBackgroundColor:[UIColor clearColor]];
    label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    
    [headerView addSubview:label];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return MENU_HEADER_HEIGHT;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self sectionTitles] objectAtIndex:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //    if([[[[self theItems] objectAtIndex:indexPath.row] objectForKey:@"icon"] isEqualToString:@"signout"]){
    //        CONFIRM_DIALOG(LSSTRING(@"warning_title"), LSSTRING(@"warning_confirm_signout"));
    //    }
    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
