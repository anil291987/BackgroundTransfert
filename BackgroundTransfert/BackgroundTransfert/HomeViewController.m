//
//  HomeViewController.m
//  BackgroundTransfert
//
//  Created by Olivier on 26/06/2014.
//  Copyright (c) 2014 sqli. All rights reserved.
//

#import "HomeViewController.h"
#import <POP/POP.h>

#define CellLabelTagValue			10
#define CellStartPauseBtnTagValue	20
#define CellStopBtnTagValue			30
#define CellProgressTagValue		40
#define CellLabelReadyTagValue		50

@interface HomeViewController () <POPAnimationDelegate>

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self initializeFileDownloadDataArray];
	NSArray *URLs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
	self.docDirectoryURL = [URLs objectAtIndex:0];
	
	self.tableFile.delegate = self;
	self.tableFile.dataSource = self;
	self.tableFile.scrollEnabled = NO;
	
	NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.sqli.BackgroundTransfert"];
	sessionConfiguration.HTTPMaximumConnectionsPerHost = 5;
	self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
}

- (void)initializeFileDownloadDataArray {
	self.arrFileDownloadData = [[NSMutableArray alloc] init];
	
	[self.arrFileDownloadData addObject:[[FileDownloadInfo alloc] initWithFileTitle:@"iOS Programming Guide"
																  andDownloadSource:@"https://developer.apple.com/library/ios/documentation/iphone/conceptual/iphoneosprogrammingguide/iphoneappprogrammingguide.pdf"]];
    [self.arrFileDownloadData addObject:[[FileDownloadInfo alloc] initWithFileTitle:@"Human Interface Guidelines"
																  andDownloadSource:@"https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/MobileHIG/MobileHIG.pdf"]];
    [self.arrFileDownloadData addObject:[[FileDownloadInfo alloc] initWithFileTitle:@"Networking Overview"
																  andDownloadSource:@"https://developer.apple.com/library/ios/documentation/NetworkingInternetWeb/Conceptual/NetworkingOverview/NetworkingOverview.pdf"]];
    [self.arrFileDownloadData addObject:[[FileDownloadInfo alloc] initWithFileTitle:@"AV Foundation"
																  andDownloadSource:@"https://developer.apple.com/library/ios/documentation/AudioVideo/Conceptual/AVFoundationPG/AVFoundationPG.pdf"]];
    [self.arrFileDownloadData addObject:[[FileDownloadInfo alloc] initWithFileTitle:@"iPhone User Guide"
																  andDownloadSource:@"http://manuals.info.apple.com/MANUALS/1000/MA1565/en_US/iphone_user_guide.pdf"]];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.arrFileDownloadData count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"BgCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	
	FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:indexPath.row];
	
	UILabel *displayedTitle = (UILabel*)[cell viewWithTag:10];
	UIButton *startPauseBtn = (UIButton*)[cell viewWithTag:CellStartPauseBtnTagValue];
	UIButton *stopBtn = (UIButton*)[cell viewWithTag:CellStopBtnTagValue];
	UIProgressView *progressView = (UIProgressView*)[cell viewWithTag:CellProgressTagValue];
	UILabel *readyLab = (UILabel*)[cell viewWithTag:CellLabelReadyTagValue];
	
	NSString *startPauseBtnImageName;
	
	displayedTitle.text = fdi.fileTitle;
	
	if (!fdi.isDownloading) {
		progressView.hidden = YES;
		stopBtn.enabled = NO;
		
		BOOL hideControls = (fdi.downloadComplete)?YES:NO;
		startPauseBtn.hidden = hideControls;
		stopBtn.hidden = hideControls;
		readyLab.hidden = !hideControls;
		
		startPauseBtnImageName = @"Download";
	} else {
		progressView.hidden = NO;
		progressView.progress = fdi.downloadProgress;
		stopBtn.enabled = YES;
		startPauseBtnImageName = @"Pause";
	}
	
	[startPauseBtn setImage:[UIImage imageNamed:startPauseBtnImageName] forState:UIControlStateNormal];
	
	return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(int)getFileDownloadInfoIndexWithTaskIdentifier:(unsigned long)taskIdentifier {
	int index = 0;
	for (int i = 0; i<[self.arrFileDownloadData count]; i++) {
		FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:i];
		if (fdi.taskIdentifier == taskIdentifier) {
			index = i;
			break;
		}
	}
	
	return index;
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
	if (totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown) {
		NSLog(@"unknow transfert size");
	} else {
		int index = [self getFileDownloadInfoIndexWithTaskIdentifier:downloadTask.taskIdentifier];
		FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:index];
		
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			fdi.downloadProgress = (double)totalBytesWritten/(double)totalBytesExpectedToWrite;
			UITableViewCell *cell = [self.tableFile cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
			UIProgressView *progressView = (UIProgressView*)[cell viewWithTag:CellProgressTagValue];
			progressView.progress = fdi.downloadProgress;
		}];
	}
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
	NSError *error;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSString *destinationFileName = downloadTask.originalRequest.URL.lastPathComponent;
	NSURL *destinationURL = [self.docDirectoryURL URLByAppendingPathComponent:destinationFileName];
	
	if ([fileManager fileExistsAtPath:[destinationURL path]]) {
		[fileManager removeItemAtURL:destinationURL error:nil];
	}
	
	BOOL success = [fileManager copyItemAtURL:location
										toURL:destinationURL
										error:&error];
	
	if (success) {
		int index = [self getFileDownloadInfoIndexWithTaskIdentifier:downloadTask.taskIdentifier];
		FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:index];
		
		fdi.isDownloading = NO;
		fdi.downloadComplete = YES;
		
		fdi.taskIdentifier = -1;
		fdi.taskResumeData = nil;
		
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			[self.tableFile reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
		}];
	} else {
		NSLog(@"Unable to copy temp file. Error: %@", [error localizedDescription]);
	}
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
	if (error != nil) {
		NSLog(@"Download completed with error: %@", [error localizedDescription]);
	} else {
		NSLog(@"Download finished successfully");
	}
}

-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	
	[self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
		if ([downloadTasks count] == 0) {
			if (appDelegate.backgroundTransfertCompletionHandler != nil) {
				void(^completionHandler)() = appDelegate.backgroundTransfertCompletionHandler;
				appDelegate.backgroundTransfertCompletionHandler = nil;
				
				[[NSOperationQueue mainQueue] addOperationWithBlock:^{
					completionHandler();
					
					UILocalNotification *localNotification = [[UILocalNotification alloc] init];
					localNotification.alertBody = @"All files have been downloaded";
					[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
				}];
			}
		}
	}];
}

- (IBAction)startPauseDlFile:(id)sender {
	if ([[[[sender superview] superview] superview] isKindOfClass:[UITableViewCell class]]) {
		
		UITableViewCell *containerCell = (UITableViewCell *)[[[sender superview] superview] superview];
		NSIndexPath *cellIndexPath = [self.tableFile indexPathForCell:containerCell];
		int cellIndex = cellIndexPath.row;
				
		FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:cellIndex];
		if (!fdi.isDownloading) {
			if (fdi.taskIdentifier == -1) {
				fdi.downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:fdi.downloadSource]];
				fdi.taskIdentifier = fdi.downloadTask.taskIdentifier;
				[fdi.downloadTask resume];
			} else {
				fdi.downloadTask = [self.session downloadTaskWithResumeData:fdi.taskResumeData];
				[fdi.downloadTask resume];
				fdi.taskIdentifier = fdi.downloadTask.taskIdentifier;
			}
		} else {
			[fdi.downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
				if (resumeData != nil) {
					fdi.taskResumeData = [[NSData alloc] initWithData:resumeData];
				}
			}];
		}
		
		fdi.isDownloading = !fdi.isDownloading;
		[self.tableFile reloadRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
	}
}

- (IBAction)stopDlFile:(id)sender {
	if ([[[[sender superview] superview] superview] isKindOfClass:[UITableViewCell class]]) {
		UITableViewCell *containerCell = (UITableViewCell*)[[[sender superview] superview] superview];
		NSIndexPath *cellIndexPath = [self.tableFile indexPathForCell:containerCell];
		int cellIndex = cellIndexPath.row;
		
		FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:cellIndex];
		[fdi.downloadTask cancel];
		fdi.isDownloading = NO;
		fdi.taskIdentifier = -1;
		fdi.downloadProgress = 0.0;
		
		[self.tableFile reloadRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
	}
}
- (IBAction)stopAllDl:(id)sender {
	for (int i=0; i<[self.arrFileDownloadData count]; i++) {
		FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:i];
		
		if (fdi.isDownloading) {
			[fdi.downloadTask cancel];
			fdi.isDownloading = NO;
			fdi.taskIdentifier = -1;
			fdi.downloadProgress = 0.0;
			fdi.downloadTask = nil;
		}
	}
	
	[self.tableFile reloadData];
}

- (IBAction)initializeAll:(id)sender {
	for (int i=0; i<[self.arrFileDownloadData count]; i++) {
		FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:i];
		
		if (fdi.isDownloading) {
			[fdi.downloadTask cancel];
		}
		
		fdi.isDownloading = NO;
		fdi.downloadComplete = NO;
		fdi.taskIdentifier = -1;
		fdi.downloadProgress = 0.0;
		fdi.downloadTask = nil;
	}
	
	[self.tableFile reloadData];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *allFiles = [fileManager contentsOfDirectoryAtURL:self.docDirectoryURL
								   includingPropertiesForKeys:nil
													  options:NSDirectoryEnumerationSkipsHiddenFiles
														error:nil];
	for (int i=0; i<[allFiles count]; i++) {
		[fileManager removeItemAtURL:[allFiles objectAtIndex:i] error:nil];
	}
}

- (IBAction)startAllDl:(id)sender {
	for (int i=0; i<[self.arrFileDownloadData count]; i++) {
		FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:i];
		
		if (!fdi.isDownloading) {
			if (fdi.taskIdentifier == -1) {
				fdi.downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:fdi.downloadSource]];
			} else {
				fdi.downloadTask = [self.session downloadTaskWithResumeData:fdi.taskResumeData];
			}
			
			fdi.taskIdentifier = fdi.downloadTask.taskIdentifier;
			[fdi.downloadTask resume];
			fdi.isDownloading = YES;
		}
	}
	
	[self.tableFile reloadData];
}

@end
