//
//  CampfireStreamingAppDelegate.m
//  CampfireStreaming
//
//  Created by Randall Brown on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CampfireStreamingAppDelegate.h"
#import "ASIHTTPRequest.h"

@implementation CampfireStreamingAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
   campfire = [[Campfire alloc] initWithCampfireURL:@"https://randallbrown.campfirenow.com"];
   campfire.delegate = self;
   campfire.authToken = @"60507110c014abd367f2532fcbc65007ee8861f0";
//   [campfire sendText:@"this is a test" toRoom:@"412475"];
//   
//   [campfire getMessagesFromRoom:@"412475" sinceID:0 completionHandler:^(NSArray* messages)
//    {
//       NSLog(@"%@", messages);
//    }];
   queue = [[ASINetworkQueue alloc] init];
}

-(void)messageReceived:(Message *)message
{
   NSLog(@"Message: %@", message);
}

- (IBAction)startListening:(id)sender 
{
   [campfire startListeningForMessagesInRoom:@"431886"];
   //[self grabURLInTheBackground];
}

- (IBAction)GetVisibleRooms:(id)sender 
{
   [campfire getVisibleRoomsWithHandler:^(NSArray *rooms){
      NSLog(@"%@", rooms);
   }];
}

- (IBAction)GetRoomsUserIsIn:(id)sender 
{
   [campfire getRoomsAuthenticatedUserIsInWithHandler:^(NSArray *rooms){
      NSLog(@"%@", rooms);
   }];
}

- (IBAction)GetRoomInfo:(id)sender 
{
   [campfire getRoomWithID:@"431886" completionHandler:^(Room *room)
    {
       NSLog(@"%@", room);
    }];
}

- (IBAction)PostFileToRoom:(id)sender 
{
   NSOpenPanel *open = [NSOpenPanel openPanel];
   [open runModal];
   
   [campfire postFile:[[[open URLs] lastObject] path]toRoom:@"431886" completionHandler:^(UploadFile* file,NSError* error)
    {
       NSLog(@"%@", file.fullURL);
       NSLog(@"%@", error);
    }];
}

- (IBAction)UpdateRoomNameAndTopic:(id)sender 
{
   [campfire updateRoom:@"431886" topic:@"Awesome" name:@"AwesomeName" completionHandler:^(NSError* error){
      NSLog(@"%@", error);
   }];
}

- (IBAction)GetRecentUploadsFromRoom:(id)sender 
{
   [campfire getRecentlyUploadedFilesFromRoom:@"431886" completionHandler:^(NSArray *files, NSError *error){
      NSLog(@"%@", files);
   }];
}

- (IBAction)JoinROom:(id)sender 
{
   [campfire joinRoom:@"431886" WithCompletionHandler:^(NSError* error){
   }];
}

- (IBAction)LeaveRoom:(id)sender 
{
   [campfire leaveRoom:@"431886" WithCompletionHandler:^(NSError* error){}];   
}

- (IBAction)LockRoom:(id)sender 
{
   [campfire lockRoom:@"431886" WithCompletionHandler:^(NSError* error){}];
}

- (IBAction)UnlockRoom:(id)sender 
{
   [campfire unlockRoom:@"431886" WithCompletionHandler:^(NSError* error){}];
}
- (IBAction)GetUser:(id)sender 
{
   [campfire getUserWithID:@"988871" withCompletionHandler:^(User *user, NSError *error){
      NSLog(@"%@", user);
   }];
}
- (IBAction)GetMe:(id)sender 
{
   [campfire getAuthenticatedUserInfo:^(User* user, NSError *error){
      NSLog(@"%@", user);
   }];
}

- (IBAction)PlaySound:(id)sender 
{
   [campfire sendSound:@"vuvuzela" toRoom:@"431886"];
}




@end
