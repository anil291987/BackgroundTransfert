//
//  HomeViewController.h
//  BackgroundTransfert
//
//  Created by Olivier on 26/06/2014.
//  Copyright (c) 2014 sqli. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FileDownloadInfo.h"

@interface HomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableArray *arrFileDownloadData;
@property (nonatomic, strong) NSURL *docDirectoryURL;

@property (weak, nonatomic) IBOutlet UITableView *tableFile;

- (IBAction)startPauseDlFile:(id)sender;
- (IBAction)stopDlFile:(id)sender;
- (IBAction)startAllDl:(id)sender;
- (IBAction)stopAllDl:(id)sender;

@end
