//
//  AddReminderViewController.m
//  Lab1
//
//  Created by Dhaval Gogri on 9/5/18.
//  Copyright © 2018 Dhaval Gogri. All rights reserved.
//

#import "AddReminderViewController.h"
#import "ReminderModel.h"



@interface AddReminderViewController () <UIImagePickerControllerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textViewTitle;
@property (weak, nonatomic) IBOutlet UITextField *textViewDescription;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;
@property (weak, nonatomic) IBOutlet UIButton *buttonSubmit;
@property (weak, nonatomic) IBOutlet UIDatePicker *pickerDateTIme;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation AddReminderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textViewTitle.delegate = self;
    self.textViewDescription.delegate = self;
    
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *currentDate = [NSDate date];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:0];
    NSDate *minDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
    [self.pickerDateTIme setMinimumDate:minDate];
    
    self.pickerDateTIme.timeZone = [NSTimeZone systemTimeZone];
    [self.pickerDateTIme addTarget:self action:@selector(dateIsChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    
    
}

- (void)dateIsChanged:(id)sender{
    NSLog(@"%@", self.pickerDateTIme.date);
}


- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
    });
    return formatter;
}

- (IBAction)submitReminderInformation:(UIButton *)sender {
    if(self.textViewTitle.text.length < 1){
        [self showAlertBox:@"Title cannot be blank"];
        return;
    }
    
    ReminderModel *reminder = [[ReminderModel alloc] init];
    NSString *title = self.textViewTitle.text;
    NSString *description = self.textViewDescription.text;
    self.pickerDateTIme.timeZone = [NSTimeZone systemTimeZone];
    
    NSString *dateStr = [NSString stringWithFormat:@"%@", [self.pickerDateTIme date]];
    NSDateFormatter *formatter = [self dateFormatter];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    NSDate *sourceDate = [formatter dateFromString:dateStr];
    NSDateFormatter* dateFormat = [self dateFormatter];
    [dateFormat setDateFormat:@"MM-dd-yyyy HH:mm"];
    NSString* dateAndTime = [dateFormat stringFromDate:sourceDate];
    
    
    
    
    
    NSArray *dateAndtimeList = [dateAndTime componentsSeparatedByString:@" "];
    
    NSString *date = dateAndtimeList[0];
    NSString *time = dateAndtimeList[1];
    
    
    
    UIImage* image = nil;
    if(self.imageView.image!=nil){
        image = self.imageView.image;
    }
    
    
    [reminder setTitle:title];
    [reminder setDescription:description];
    [reminder setDate:date];
    [reminder setTime:time];
    [reminder setImage:image];
    [reminder setIsDone:@"NO"];
    
    [self.saveReminderDelegate saveRemimderInformationInDatabaseAndUpdate:reminder];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)addImageToReminder:(UIButton *)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //You can retrieve the actual UIImage
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    //Or you can get the image url from AssetsLibrary
    NSURL *path = [info valueForKey:UIImagePickerControllerReferenceURL];
    [self.imageView setImage:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)showAlertBox:(NSString*)message{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@""
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:@"Got it"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   [alert dismissViewControllerAnimated:true completion:nil];
                               }];
    
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)dismissViewController:(UIButton *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
