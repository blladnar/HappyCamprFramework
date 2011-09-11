//
//  User.h
//  HappyCampr
//
//  Created by Brown, Randall on 7/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HCUser : NSObject

@property (assign) NSInteger userID;
@property (retain) NSString* name;
@property (retain) NSString* email;
@property (retain) NSString* avatarURL;
@property (retain) NSString* authToken;

@end
