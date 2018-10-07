//
//  DatabaseManager.h
//  Lab1
//
//  Created by Dhaval Gogri on 9/5/18.
//  Copyright © 2018 Dhaval Gogri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReminderModel.h"

@interface DatabaseManager : NSObject
-(void) createDatabase;
-(void) setReminder:(ReminderModel*)reminder;
-(void) updateReminder:(ReminderModel*)reminder;
-(NSMutableArray*) getAllReminders;
-(void) deleteDatabase;
+(DatabaseManager*)sharedInstance;
@end
