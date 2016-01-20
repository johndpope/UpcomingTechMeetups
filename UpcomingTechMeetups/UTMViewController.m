//
//  UTMViewController.m
//  UpcomingTechMeetups
//
//  Created by Joseph Bandera-Duplantier on 1/18/16.
//  Copyright © 2016 Joseph Bandera-Duplantier. All rights reserved.
//

#import "UTMViewController.h"

NSString *const kBaseURL = @"https://api.meetup.com/2/open_events.json";
NSString *const kTopic = @"technology";
NSString *const kTime = @",1w";
NSString *const kMeetupAPIKey = @"72802f7e1f52316734565576f654a2e";

@interface UTMViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;

@end

@implementation UTMViewController {
    NSMutableArray *meetups;
}

- (void)fetchMeetups {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?topic=%@&time=%@&lat=%f&lon=%f&key=%@",
                                       kBaseURL,
                                       kTopic,
                                       kTime,
                                       self.location.coordinate.latitude,
                                       self.location.coordinate.longitude,
                                       kMeetupAPIKey]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      if (data.length > 0 && error == nil) {
                                          NSDictionary *dictionaryResult = [NSJSONSerialization JSONObjectWithData:data
                                                                                                   options:0
                                                                                                     error:NULL];
                                          
                                          NSArray *results = [dictionaryResult objectForKey:@"results"];
                                          
                                          for (NSDictionary *result in results) {
                                              NSString *meetup = [NSString stringWithFormat:@"%@:\n%@", [[result objectForKey:@"group"]
                                                                                                         objectForKey:@"name"], [result objectForKey:@"name"]];
                                              
                                              [meetups addObject:meetup];
                                                                    }
                                          
                                          [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
                                      }
                                  }];
    
    [task resume];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    meetups = [NSMutableArray array];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    
    if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
    self.locationManager.delegate = self;
    self.location = [[CLLocation alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Core location delegate

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                               message: @"There was an error retrieving your location. Please try again."
                                                                        preferredStyle:UIAlertControllerStyleAlert                   ];
    
    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             [myAlertController dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    [myAlertController addAction: ok];
    [self presentViewController:myAlertController animated:YES completion:nil];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.location = locations.lastObject;
    
    if (CLLocationCoordinate2DIsValid(self.location.coordinate)) {
        [self.locationManager stopUpdatingLocation];
        self.locationManager.delegate = nil;
        self.locationManager = nil;
        [self fetchMeetups];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [meetups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *meetupIdentifier = @"meetupCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:meetupIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:meetupIdentifier];
    }
    
    cell.textLabel.text = [meetups objectAtIndex:indexPath.row];
    cell.textLabel.numberOfLines = 4;
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0f;
}

@end
