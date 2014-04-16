//
//  ViewController.m
//  app
//
//  Created by Joel Oliveira on 16/04/14.
//  Copyright (c) 2014 Notificare. All rights reserved.
//

#import "MainViewController.h"
#import "IIViewDeckController.h"
#import "AppDelegate.h"
#import "Configuration.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    
    NSURL *nsUrl=[NSURL URLWithString:[[Configuration shared] getProperty:@"url"]];
    NSURLRequest *nsRequest=[NSURLRequest requestWithURL:nsUrl];
    [[self webView] loadRequest:nsRequest];
    
    
    [[self navigationItem] setTitleView:[[UIImageView alloc] initWithImage: [UIImage imageNamed: @"Logo"]]];
    
    [self setTitle:@""];
    
    [[self navigationItem] setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"LeftMenuIcon"] style:UIBarButtonItemStyleBordered target:[self viewDeckController] action:@selector(toggleLeftView)]];
    
    [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"RightMenuIcon"] style:UIBarButtonItemStyleBordered target:[self viewDeckController] action:@selector(toggleRightView)]];
    
    
    [self setActivityIndicatorView:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
    [[self view] addSubview:[self activityIndicatorView]];
    
    [[self activityIndicatorView] setHidden:YES];
    [[self activityIndicatorView]  setCenter:CGPointMake( self.view.frame.size.width /2-5, self.view.frame.size.height /2-5)];
    [[self activityIndicatorView]  setContentMode:UIViewContentModeCenter];
    [[self activityIndicatorView]  startAnimating];
}


-(void)webViewDidStartLoad:(UIWebView *)webView{
    
    [[self activityIndicatorView] setHidden:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [[self activityIndicatorView] setHidden:YES];
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    ALERT_DIALOG(LSSTRING(@"title_webview_load_fail"), LSSTRING(@"message_webview_load_fail"));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
