//
//  DatabaseManager.m
//  Lab1
//
//  Created by Dhaval Gogri on 9/5/18.
//  Copyright © 2018 Dhaval Gogri. All rights reserved.
//

#import "DatabaseManager.h"
#import "sqlite3.h"

@interface DatabaseManager (){
    NSString *databasePath;
    sqlite3 *reminderDB;
}

@end




@implementation DatabaseManager

-(void) createDatabase {
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = [dirPaths objectAtIndex:0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"reminder.db"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &reminderDB) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS REMINDER (ID INTEGER PRIMARY KEY AUTOINCREMENT,TITLE TEXT,DESCRIPTION TEXT,TIME TEXT, DATE TEXT, IMAGE BLOB, ISDONE TEXT)";
            
            sqlite3_close(reminderDB);
            
        }
    }
    
}

- (void) updateReminder:(ReminderModel*) reminder {
    sqlite3_stmt    *statement = NULL;
    
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &reminderDB) == SQLITE_OK)
    {
        const char *insertSQL = "UPDATE REMINDER SET ISDONE='YES' WHERE ID=?";
        
        if (sqlite3_prepare_v2(reminderDB, insertSQL, -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_int(statement, 0, (int)[reminder getId]);
            sqlite3_bind_text(statement, 6, [[reminder getIsDone] UTF8String], -1, SQLITE_TRANSIENT);
            
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                NSLog(@"Data is successfully inserted into the databse");
            } else {
                NSLog(@"We got some error while entering data. Check your code again");
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(reminderDB);
    }
    
}

- (void) setReminder:(ReminderModel*) reminder {
    sqlite3_stmt    *statement = NULL;
    
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &reminderDB) == SQLITE_OK)
    {
        const char *insertSQL = "INSERT INTO REMINDER (TITLE, DESCRIPTION, TIME, DATE, IMAGE, ISDONE) VALUES (?,?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(reminderDB, insertSQL, -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_text(statement, 1, [[reminder getTitle] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 2, [[reminder getDescription] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 3, [[reminder getDate] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 4, [[reminder getTime] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_blob(statement, 5, [UIImageJPEGRepresentation(reminder.getImage, 1.0) bytes], [UIImageJPEGRepresentation(reminder.getImage, 1.0) length], SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 6, [[reminder getIsDone] UTF8String], -1, SQLITE_TRANSIENT);
            
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                NSLog(@"Data is successfully inserted into the databse");
            } else {
                NSLog(@"We got some error while entering data. Check your code again");
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(reminderDB);
    }
}


- (NSMutableArray*) getAllReminders
{
    int count = 0;
    NSMutableArray* reminderArray;
    reminderArray = [[NSMutableArray alloc]init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    
    if (sqlite3_open(dbpath, &reminderDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"SELECT ID, TITLE , DESCRIPTION, TIME, DATE, IMAGE, ISDONE FROM REMINDER"];
        
        
        if (sqlite3_prepare_v2(reminderDB, [querySQL cStringUsingEncoding:NSUTF8StringEncoding], -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                ReminderModel *reminder = [[ReminderModel alloc] init];
                
                NSInteger idField = (int) sqlite3_column_text(statement, 0);
                [reminder setId:idField];
                
                NSString *titleField = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                [reminder setTitle:titleField];
                
                NSString *descriptionField = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                [reminder setDescription:descriptionField];
                
                NSString *timeField = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)];
                [reminder setTime:timeField];
                
                NSString *dateField = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)];
                [reminder setDate:dateField];
                
                NSData *data = [NSData dataWithBytes:sqlite3_column_blob(statement, 5) length:sqlite3_column_bytes(statement, 5)];
                
                if(data == nil){
                    [reminder setImage:nil];
                }
                else{
                    UIImage *tempImage = [UIImage imageWithData:data];
                    [reminder setImage:tempImage];
                }
                
                // checking wheather reminders have expired or not usung difference in current & reminder date & time
                NSString *isDoneField = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 6)];
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"MM-dd-yyyy HH:mm"];
                NSString* date = [@" " stringByAppendingString:dateField];
                NSString* time = timeField;
                NSString* dateTime = [time stringByAppendingString:date];
                NSDate *dte = [dateFormat dateFromString:dateTime];
                
                if([NSDate.date timeIntervalSinceDate:dte] > 0){
                    isDoneField = @"YES";
                }
                else{
                    isDoneField = @"NO";
                }
                
                [reminder setIsDone:isDoneField];
                [reminderArray addObject:reminder];
            }
            sqlite3_finalize(statement);
        }
        else {
            NSLog(@"Cannot RETRIEVE data from the database");
        }
        sqlite3_close(reminderDB);
    }
    
    return reminderArray;
}

- (void) deleteDatabase{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath =  [documentsDirectory stringByAppendingPathComponent:@"reminder.db"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}

+(DatabaseManager*)sharedInstance{
    static DatabaseManager * _sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate,^{
        _sharedInstance = [[DatabaseManager alloc] init];
    });
    
    return _sharedInstance;
}

@end
