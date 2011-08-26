//
//  UploadFile.m
//  CampfireStreaming
//
//  Created by Randall Brown on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UploadFile.h"

@implementation UploadFile

@synthesize name, fileID, createdAt, sizeInBytes, contentType, fullURL, roomID, userID;

-(NSString*)description
{
   return self.fullURL;
}

@end
