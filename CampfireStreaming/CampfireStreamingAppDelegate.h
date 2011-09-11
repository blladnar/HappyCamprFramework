//
//  CampfireStreamingAppDelegate.h
//  CampfireStreaming
//
//  Created by Randall Brown on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HappyCampfire.h"
#import "ASINetworkQueue.h"

@interface CampfireStreamingAppDelegate : NSObject <NSApplicationDelegate,CampfireResponseProtocol> {
   NSWindow *window;
   HappyCampfire *campfire;
   NSOperationQueue *queue;
   IBOutlet NSTextField *username;
   IBOutlet NSSecureTextField *password;
}

@property (assign) IBOutlet NSWindow *window;
- (IBAction)startListening:(id)sender;
- (IBAction)GetVisibleRooms:(id)sender;
- (IBAction)GetRoomsUserIsIn:(id)sender;
- (IBAction)GetRoomInfo:(id)sender;
- (IBAction)PostFileToRoom:(id)sender;
- (IBAction)UpdateRoomNameAndTopic:(id)sender;
- (IBAction)GetRecentUploadsFromRoom:(id)sender;
- (IBAction)JoinROom:(id)sender;
- (IBAction)LeaveRoom:(id)sender;
- (IBAction)LockRoom:(id)sender;
- (IBAction)UnlockRoom:(id)sender;
- (IBAction)Authenticate:(id)sender;

@end
