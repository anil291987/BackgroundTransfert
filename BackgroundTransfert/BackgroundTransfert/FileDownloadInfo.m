//
//  FileDownloadInfo.m
//  BackgroundTransfert
//
//  Created by Olivier on 26/06/2014.
//  Copyright (c) 2014 sqli. All rights reserved.
//

#import "FileDownloadInfo.h"

@implementation FileDownloadInfo

-(id)initWithFileTitle:(NSString *)title andDownloadSource:(NSString *)source {
	if (self == [super init]) {
		self.fileTitle = title;
		self.downloadSource = source;
		self.downloadProgress = 0.0;
		self.isDownloading = NO;
		self.downloadComplete = NO;
		self.taskIdentifier = -1;
	}
	
	return self;
}

@end
