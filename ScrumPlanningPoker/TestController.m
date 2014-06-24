//
//  TestController.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/28/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "TestController.h"
#import "SPPProperties.h"
#import "SRWebSocketTransport.h"

@interface TestController (){
    SPPProperties *properties;
    NSString *sessionId;
}

@end

@implementation TestController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [_connection stop];
    _hub = nil;
    _connection.delegate = nil;
    _connection = nil;
    
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if(_data == nil)
    {
        _data = [NSMutableArray array];
    }
    __weak __typeof(&*self)weakSelf = self;
    
    properties=[SPPProperties sharedProperties];
    //_connection = [SRHubConnection connectionWithURL:[NSString stringWithFormat:@"http://%@", properties.server]];
    _connection = [SRHubConnection connectionWithURL:@"http://vinw3428/SignalrMVC"];
    _hub = [_connection createHubProxy:@"chatHub"];
    [_hub on:@"onState" perform:self selector:@selector(onState:)];
    [_hub on:@"onConnectionId" perform:self selector:@selector(onConnectionId:)];
    _connection.started = ^{
        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
        [strongSelf.data insertObject:@"Connection Opened" atIndex:0];
        [strongSelf.tableView reloadData];
    };
    _connection.received = ^(NSDictionary * data){
        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
        [strongSelf.data insertObject:data atIndex:0];
        [strongSelf.tableView reloadData];
    };
    _connection.closed = ^{
        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
        [strongSelf.data insertObject:@"Connection Closed" atIndex:0];
        [strongSelf.tableView reloadData];
    };
    _connection.error = ^(NSError *error){
        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
        [strongSelf.data insertObject:error.localizedDescription atIndex:0];
        [strongSelf.tableView reloadData];
    };
    [_connection start: [[SRWebSocketTransport alloc]  init]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark TableView datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"Connection Status", @"Connection Status");
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSInteger row=indexPath.row;
    cell.textLabel.text = [[NSString stringWithFormat:@"%@", (self.data)[row]] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return cell;
}

#pragma mark -


#pragma mark Habs methods
- (void)onState: (NSDictionary *) state
{
    sessionId = [state objectForKey:@"SessionId"];
    [self.data insertObject:[NSString stringWithFormat:@"Hub connected with id %@", sessionId] atIndex:0];
    [self.tableView reloadData];
}

- (void)onConnectionId: (NSDictionary *) connectionId
{
    sessionId = [NSString stringWithFormat:@"%@", connectionId];
    [self.data insertObject:[NSString stringWithFormat:@"Hub connected with id %@", sessionId] atIndex:0];
    [self.tableView reloadData];
}

#pragma mark -

- (IBAction)actJoinRoom:(id)sender {
    [_hub invoke:@"JoinRoom"
            withArgs:@[@"TestRoom", sessionId]];
}

- (IBAction)actLeaveRoom:(id)sender {
    [_hub invoke:@"LeaveRoom"
        withArgs:@[@"TestRoom", sessionId]];
}

- (IBAction)actTest:(id)sender {
    [_hub invoke:@"Test"
        withArgs:@[@"TestRoom"]];
}
@end
