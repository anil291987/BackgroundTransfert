//
//  HomeViewController.m
//  BackgroundTransfert
//
//  Created by Olivier on 26/06/2014.
//  Copyright (c) 2014 sqli. All rights reserved.
//

#import "HomeViewController.h"

#define CellLabelTagValue			10
#define CellStartPauseBtnTagValue	20
#define CellStopBtnTagValue			30
#define CellProgressTagValue		40
#define CellLabelReadyTagValue		50

@interface HomeViewController ()

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

- (IBAction)startPauseDlFile:(id)sender {
}

- (IBAction)stopDlFile:(id)sender {
}
- (IBAction)stopAllDl:(id)sender {
}

- (IBAction)startAllDl:(id)sender {
}
@end
