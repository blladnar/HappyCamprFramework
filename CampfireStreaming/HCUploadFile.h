//
//  UploadFile.h
//  CampfireStreaming
//
//  Created by Randall Brown on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HCUploadFile : NSObject

@property (assign) NSInteger sizeInBytes;
@property (assign) NSInteger fileID;
@property (retain) NSString *contentType;
@property (retain) NSString *name;
@property (retain) NSString *roomID;
@property (retain) NSString *userID;
@property (retain) NSString *fullURL;
@property (retain) NSDate *createdAt;

@end
