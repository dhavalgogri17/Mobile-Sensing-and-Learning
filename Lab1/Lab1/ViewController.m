//
//  ViewController.m
//  Lab1
//
//  Created by Dhaval Gogri, Rishab Vaishya on 9/1/18.
//  Copyright © 2018 Dhaval Gogri. All rights reserved.
//

#import "ViewController.h"
#import "SettingsViewController.h"
#import "DatabaseManager.h"
#import "ReminderTableViewCell.h"
#import "ReminderTableViewCell2.h"
#import "ReminderTableViewCell3.h"
#import "ReminderTableViewCell4.h"
#import "AddReminderViewController.h"
#import "DisplayReminderInformationViewController.h"
#import "ReminderUICollectionViewCell.h"


@interface ViewController() <UITableViewDelegate, UITableViewDataSource, SaveRemiderInformationDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *settings;
@property (strong,nonatomic) DatabaseManager* databaseManager;
@property (strong,nonatomic) NSMutableArray* reminderInformation;
@property (strong,nonatomic) NSMutableArray* reminderInformationFiltered;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (nonatomic) BOOL isListView;
@end

@implementation ViewController
@synthesize databaseManager = _databaseManager;

// Lazy instantiating database manager
-(DatabaseManager*)databaseManager{
    
    if(!_databaseManager)
        _databaseManager =[DatabaseManager sharedInstance];
    
    return _databaseManager;
}

// NSUserDefaults stores the preference of user to show reminders in
// table view or collection view (default is table or list view)
-(BOOL)isListView{
    if(!_isListView){
        NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
        NSString *currentLevelKey = @"isListView";
        if ([preferences objectForKey:currentLevelKey] == nil)
        {
            _isListView = true;
        }
        else
        {
            _isListView = [preferences boolForKey:currentLevelKey];
        }
    }
    return _isListView;
}


// toggle visibility between table view & collection view depending on preference.
- (void) viewWillAppear:(BOOL)animated{
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    NSString *currentLevelKey = @"isListView";
    if ([preferences objectForKey:currentLevelKey] == nil)
    {
        _isListView = true;
    }
    else
    {
        _isListView = [preferences boolForKey:currentLevelKey];
    }
    
    if(_isListView){
        self.tableView.alpha = 1;
        self.collectionView.alpha = 0;
    }
    else{
        self.tableView.alpha = 0;
        self.collectionView.alpha = 1;
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.reminderInformation = [[NSMutableArray alloc]init];
    self.reminderInformationFiltered = [[NSMutableArray alloc]init];
    
    // calling database methods, method name gives away their functionality.
    [self.databaseManager createDatabase];
    NSLog(@"Finished Saving All Data");
    self.reminderInformation = [self.databaseManager getAllReminders];
    NSLog(@"Finished GETTING All Data");
    
    // sort reminders between upcoming & done
    [self filterReminders:@"Upcoming"];
    
    
    
    
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)goToSettings:(id)sender {
    ViewController *gotoYourClass = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewControllerIdentifier"];
    [self.navigationController pushViewController:gotoYourClass animated:YES];
}


// we are calling the modal view controller here, modal view name is AddReminderViewController
- (IBAction)goToAddReminder:(UIButton *)sender {
    
    AddReminderViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddReminderViewController"];
    
    viewController.saveReminderDelegate = self;
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:viewController];
    [self presentModalViewController:navController animated:YES];
}


// All Functions below are for Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.reminderInformationFiltered count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Cell Prototype Type 1
    if([[[self.reminderInformationFiltered objectAtIndex:indexPath.row] getDescription]  isEqual: @""] && [[self.reminderInformationFiltered objectAtIndex:indexPath.row] getImage] == nil){
        ReminderTableViewCell* cell;
        cell = [tableView dequeueReusableCellWithIdentifier:@"ReminderTableViewCellIdentifier" forIndexPath:indexPath];
        cell.labelViewTitle.text = [[self.reminderInformationFiltered objectAtIndex:indexPath.row] getTitle];
        return cell;
    }
    
    //Cell Prototype Type 2
    else if(![[[self.reminderInformationFiltered objectAtIndex:indexPath.row] getDescription]  isEqual: @""] && [[self.reminderInformationFiltered objectAtIndex:indexPath.row] getImage] == nil){
        ReminderTableViewCell2* cell;
        cell = [tableView dequeueReusableCellWithIdentifier:@"ReminderTableViewCellIdentifier2" forIndexPath:indexPath];
        cell.labelViewTitle.text = [[self.reminderInformationFiltered objectAtIndex:indexPath.row] getTitle];
        cell.labelViewDescription.text = [[self.reminderInformationFiltered objectAtIndex:indexPath.row] getDescription];
        return cell;
    }
    
    //Cell Prototype Type 3
    else if([[[self.reminderInformationFiltered objectAtIndex:indexPath.row] getDescription]  isEqual: @""] && [[self.reminderInformationFiltered objectAtIndex:indexPath.row] getImage] != nil){
        ReminderTableViewCell3* cell;
        cell = [tableView dequeueReusableCellWithIdentifier:@"ReminderTableViewCellIdentifier3" forIndexPath:indexPath];
        cell.labelViewTitle.text = [[self.reminderInformationFiltered objectAtIndex:indexPath.row] getTitle];
        cell.imageView.image = [[self.reminderInformationFiltered objectAtIndex:indexPath.row] getImage];
        return cell;
    }
    
    //Cell Prototype Type 4
    else{
        ReminderTableViewCell4* cell;
        cell = [tableView dequeueReusableCellWithIdentifier:@"ReminderTableViewCellIdentifier4" forIndexPath:indexPath];
        cell.labelViewTitle.text = [[self.reminderInformationFiltered objectAtIndex:indexPath.row] getTitle];
        cell.labelViewDescription.text = [[self.reminderInformationFiltered objectAtIndex:indexPath.row] getDescription];
        cell.imageView.image = [[self.reminderInformationFiltered objectAtIndex:indexPath.row] getImage];
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ViewController *gotoYourClass = [self.storyboard instantiateViewControllerWithIdentifier:@"DisplayReminderViewControllerIdentifier"];
    ((DisplayReminderInformationViewController*)gotoYourClass).reminderModel = [self.reminderInformationFiltered objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:gotoYourClass animated:YES];
}

- (void)saveRemimderInformationInDatabaseAndUpdate:(ReminderModel *)reminderModel{
    [self.databaseManager setReminder:reminderModel];
    [self.reminderInformation removeAllObjects];
    self.reminderInformation = [self.databaseManager getAllReminders];
    
    
    
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    // formatting dates to find difference between current & reminder expired dates to find whether reminder given on time or not
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd-yyyy HH:mm"];
    NSString* date = [reminderModel getDate];
    NSString* time = [@" " stringByAppendingString:[reminderModel getTime]];
    NSString* dateTime = [date stringByAppendingString:time];
    NSDate *dte = [dateFormat dateFromString:dateTime];
    
    // push notifies the user whn it's time to show the reminder
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = dte;
    notification.alertBody = [@"You have a reminder for " stringByAppendingString:[reminderModel getTitle]];
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    
    
    [self.navigationController popViewControllerAnimated:YES];
    
    // current date
    NSDate *now = [NSDate date];
    
    // converting timezone from GMT to local
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"hh:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSLog(@"The Current Time is %@",[dateFormatter stringFromDate:now]);
    
    // refreshing all the table & collection views
    [self.segmentControl setSelectedSegmentIndex:0];
    [self filterReminders:@"Upcoming"];
    [self.tableView reloadData];
    [self.collectionView reloadData];
    
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.reminderInformationFiltered count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ReminderUICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ReminderCollectionViewCell" forIndexPath:indexPath];
    cell.labelViewTitle.text = [[self.reminderInformationFiltered objectAtIndex:indexPath.row] getTitle];
    cell.labelViewTitle.layer.borderColor = [UIColor blackColor].CGColor;
    cell.labelViewTitle.layer.borderWidth = 3.0;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    ViewController *gotoYourClass = [self.storyboard instantiateViewControllerWithIdentifier:@"DisplayReminderViewControllerIdentifier"];
    ((DisplayReminderInformationViewController*)gotoYourClass).reminderModel = [self.reminderInformationFiltered objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:gotoYourClass animated:YES];
}


- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    NSString *title = [sender titleForSegmentAtIndex:sender.selectedSegmentIndex];
    [self filterReminders:title];
}

-(void)filterReminders:(NSString*)title{
    // catogorizing reminders depending upon their expiry.
    if([title  isEqual: @"Upcoming"]){
        [self.reminderInformationFiltered removeAllObjects];
        for(int i = 0; i < self.reminderInformation.count; i++){
            if([[[self.reminderInformation objectAtIndex:i] getIsDone]  isEqual: @"NO"]){
                [self.reminderInformationFiltered addObject:[self.reminderInformation objectAtIndex:i]];
            }
        }
    }
    else{
        [self.reminderInformationFiltered removeAllObjects];
        for(int i = 0; i < self.reminderInformation.count; i++){
            if([[[self.reminderInformation objectAtIndex:i] getIsDone] isEqual: @"YES"]){
                [self.reminderInformationFiltered addObject:[self.reminderInformation objectAtIndex:i]];
            }
        }
    }
    
    // reloading the visible view
    if(self.tableView.alpha == 1){
        [self.tableView reloadData];
    }
    else{
        [self.collectionView reloadData];
    }
}


@end
