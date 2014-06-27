//
//  HomeViewController.h
//  BackgroundTransfert
//
//  Created by Olivier on 26/06/2014.
//  Copyright (c) 2014 sqli. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "FileDownloadInfo.h"

@interface HomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableArray *arrFileDownloadData;
@property (nonatomic, strong) NSURL *docDirectoryURL;

@property (weak, nonatomic) IBOutlet UITableView *tableFile;

- (int)getFileDownloadInfoIndexWithTaskIdentifier:(unsigned long)taskIdentifier;

- (IBAction)startPauseDlFile:(id)sender;
- (IBAction)stopDlFile:(id)sender;
- (IBAction)startAllDl:(id)sender;
- (IBAction)stopAllDl:(id)sender;
- (IBAction)initializeAll:(id)sender;

@end
