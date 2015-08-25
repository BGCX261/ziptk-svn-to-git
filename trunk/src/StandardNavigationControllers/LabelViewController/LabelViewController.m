//
//  Copyright 2009 Zerously.
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//  

#import "LabelViewController.h"

@interface LabelViewController (Private_API)
- (void)initTextField;
@end

@implementation LabelViewController
@synthesize table;
@synthesize labelField;
@synthesize labelText;
@synthesize delegate;

- (id)initWithText:(NSString *)text
NibName:(NSString *)nibNameOrNil
bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
        self.labelText = text;
    }
    
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [table setAllowsSelection:NO];
    [self initTextField];
    [table reloadData];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.delegate labelViewController:self
                        didLabelChange:self.labelField.text];
}

- (void)dealloc {
    [table release];
    [labelField release];
    [labelText release];
    [super dealloc];
}

- (void)initTextField {
    self.labelField = [[UITextField alloc] initWithFrame:CGRectMake(10,0,283,43)];
    self.labelField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.labelField.textColor = [UIColor colorWithRed:0.219f green:0.329f blue:0.529 alpha:1];
    self.labelField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.labelField.text = self.labelText;
    self.labelField.opaque = YES;
    self.labelField.backgroundColor = [UIColor whiteColor];
    [self.labelField becomeFirstResponder];
}

#pragma mark -
#pragma mark Table view data source methods
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:kLabelCellId];

    if(cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero
                                       reuseIdentifier:kLabelCellId]
                autorelease];
    }

    [cell.contentView addSubview:labelField];
    [labelField release];

    return cell;
}

@end
