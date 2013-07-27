
#import "SelectController.h"


@implementation SelectController
@synthesize tag=_tag;
@synthesize selectedIndex=_selectedIndex;
@synthesize delegate=_delegate;


#pragma mark Initialization

//
- (id)initWithArray:(NSArray *)array selectedIndex:(NSUInteger)select
{
	[super initWithStyle:UITableViewStyleGrouped];
	_array = [array retain];
	_selectedIndex = select;
	return self;
}

/*
- (id)initWithStyle:(UITableViewStyle)style {
	// Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
	if ((self = [super initWithStyle:style])) {
	}
	return self;
}
*/

//
- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
	NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:_selectedIndex inSection:0];
	[self.tableView cellForRowAtIndexPath:oldIndexPath].accessoryType = UITableViewCellAccessoryNone;
	
	_selectedIndex = selectedIndex;
	
	NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:_selectedIndex inSection:0];
	[self.tableView cellForRowAtIndexPath:newIndexPath].accessoryType = UITableViewCellAccessoryCheckmark;
}


#pragma mark View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.selectedIndex = _selectedIndex;
}

/*
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (_array == nil)
	{
		return 0;
	}
	
	return [_array count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSString *reuse = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuse] autorelease];
	}
	
	NSInteger row = indexPath.row;
	cell.textLabel.text = [_array objectAtIndex:row];
	cell.textLabel.font = [UIFont systemFontOfSize:16];
	
	cell.accessoryType = (row == _selectedIndex) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
	return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return NO if you do not want the specified item to be editable.
	return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		// Delete the row from the data source
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}   
	else if (editingStyle == UITableViewCellEditingStyleInsert) {
		// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
	}   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return NO if you do not want the item to be re-orderable.
	return YES;
}
*/


#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	self.selectedIndex = indexPath.row;
	
	if ([_delegate didSelect:self selectedIndex:self.selectedIndex]) 
	{
		[self.navigationController popViewControllerAnimated:YES];
	}
}


#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	// For example: self.myOutlet = nil;
}


- (void)dealloc 
{
	[_array release];
	[super dealloc];
}


@end

