//
//  TIOManager.m
//  TerminalIO
//
//  Created by Lutz Vogelsang on 27.09.13.
//  Copyright (c) 2013 Lutz Vogelsang. All rights reserved.
//

#import "TIO.h"
#import "TIOManager_internal.h"
#import "TIOPeripheral_internal.h"
#import "TIOAdvertisement.h"


@interface TIOManager () <CBCentralManagerDelegate>

@property (strong, nonatomic) CBCentralManager *cbCentralManager;
@property (strong, nonatomic) NSMutableArray *tioPeripherals;

@end



@implementation TIOManager

NSString *const KNOWN_PERIPHERAL_IDS_FILE_NAME = @"TIOKnownPeripheralIdentifiers";

#pragma  mark - Initialization

- (TIOManager *) init
{
	self = [super init];
	if (self)
	{
		// Allocate the IOS Core Bluetooth Central Manager instance opting for restoration.
		self.cbCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionRestoreIdentifierKey:@"TIOManager"}];
		// Allocate an array for holding the discovered peripheral instances.
		self.tioPeripherals = [[NSMutableArray alloc] init];
	}
	return self;
}


#pragma  mark - Properties

- (NSArray *)peripherals
{
	return [self.tioPeripherals copy];
}


#pragma mark - Public methods

+ (TIOManager *)sharedInstance
{
	// Lazyly instantiated TIOManager singleton.
	static __strong TIOManager *_sharedInstance = nil;
	if (!_sharedInstance)
	{
		_sharedInstance = [[TIOManager alloc] init];
	}
	return _sharedInstance;
}


- (void)startScan
{
	STTraceMethod(self, @"startScan");
	
	// Scan for devices exposing the TerminalIO Service; do not allow duplicates (default options).
	[self.cbCentralManager scanForPeripheralsWithServices: @[[TIO SERVICE_UUID]] options:nil];
}


- (void)startUpdateScan
{
	STTraceMethod(self, @"startUpdateScan");
	
	// Scan for devices exposing the TerminalIO Service; do allow duplicates.
	// This option is not recommended, leads to increased power consumption and may be disabled by the OS when in background mode.
	// It is used here in order to capture dynamically changing advertisement information during this scan procedure.
	[self.cbCentralManager scanForPeripheralsWithServices: @[[TIO SERVICE_UUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
}


- (void)stopScan
{
	STTraceMethod(self, @"stopScan");
	
	// Stop scan.
	[self.cbCentralManager stopScan];
}


- (void)loadPeripherals
{
	STTraceMethod(self, @"loadPeripherals");
	
	NSString *path = [TIO pathWithFileName:KNOWN_PERIPHERAL_IDS_FILE_NAME];
	NSMutableArray* idList = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
	if (idList == nil)
	{
		STTraceError(@"failed to deserialize identifier list");
		return;
	}

	NSArray *idArray = [idList copy];
	NSArray	 *list = [self.cbCentralManager retrievePeripheralsWithIdentifiers:idArray];
	for (CBPeripheral *peripheral in list)
	{
		// check for existing instance
		TIOPeripheral *knownPeripheral = [self findTIOPeripheralByIdentifier:peripheral.identifier];
		if (knownPeripheral != nil)
		{
			continue;
		}

		STTraceLine(@"retrieved peripheral %@", peripheral);
		// Create a new TIOPeripheral instance from discovered data.
		TIOPeripheral *tioPeripheral = [TIOPeripheral peripheralWithCBPeripheral:peripheral];
		// Add new instance to collection.
		[self.tioPeripherals addObject:tioPeripheral];
		// Notify delegate.
		[self raiseDidRetrievePeripheral:tioPeripheral];
	}
}

- (void)savePeripherals
{
	STTraceMethod(self, @"savePeripherals");
	
	NSMutableArray *idList = [[NSMutableArray alloc] init];
	for (TIOPeripheral *peripheral in self.peripherals)
	{
		if (peripheral.shallBeSaved)
		{
			[idList addObject:peripheral.cbPeripheral.identifier];
		}
	}
	
	NSString *path = [TIO pathWithFileName:KNOWN_PERIPHERAL_IDS_FILE_NAME];
	if (![NSKeyedArchiver archiveRootObject:idList toFile:path])
	{
		STTraceError(@"failed to serialize identifier list");
	}
}


- (void)removePeripheral:(TIOPeripheral *)peripheral
{
	STTraceMethod(self, @"removePeripheral %@", peripheral);
	
	// disconnect
	[peripheral cancelConnection];
	// remove instance from collection
	[self.tioPeripherals removeObject:peripheral];
	// save updated peripheral collection
	[self savePeripherals];
}


- (void)removeAllPeripherals
{
	STTraceMethod(self, @"removeAllPeripherals");

	for (TIOPeripheral *peripheral in self.tioPeripherals)
	{
		// disconnect
		[peripheral cancelConnection];
	}
	
	[self.tioPeripherals removeAllObjects];
	// save cleared peripheral collection
	[self savePeripherals];
}


#pragma mark - Internal methods

- (TIOPeripheral *)findTIOPeripheralByIdentifier:(NSUUID *)identifier
{
	STTraceMethod(self, @"findTIOPeripheralByIdentifier %@", identifier);
	
	// Iterate through known peripherals.
	for (TIOPeripheral *peripheral in self.tioPeripherals)
	{
		if ([peripheral.identifier isEqual:identifier])
		{
			// Found matching TIOPeripheral instance.
			return peripheral;
		}
	}
	
	return nil;
}


#pragma mark - CBCentralManagerDelegate implementation

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
	STTraceMethod(self, @"centralManagerDidUpdateState %d", central.state);
	
	if (central.state == CBCentralManagerStatePoweredOn)
	{
		[self raiseBluetoothAvailable];
	}
	else
	{
		[self raiseBluetoothUnavailable];
	}
}


- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict
{
	STTraceMethod(self, @"centralManagerWillRestoreState %@", dict);

	NSLog(@"centralManagerWillRestoreState %@", dict);
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
	STTraceMethod(self, @"centralManagerDidDiscoverPeripheral %@  rssi:%@", peripheral, RSSI);

	// Instantiate a TIOAdvertisement from discovered advertisement data.
	TIOAdvertisement *advertisement = [TIOAdvertisement advertisementWithData:advertisementData];
	if (advertisement == nil)
	{
		STTraceError(@"invalid advertisement");
		return;
	}

	// Check for already known TIOPeripheral instance.
	TIOPeripheral *knownPeripheral = [self findTIOPeripheralByIdentifier:peripheral.identifier];
	if (knownPeripheral != nil)
	{
		if ([knownPeripheral updateWithAdvertisement:advertisement])
		{
			// The advertisement contains new information and has been updated within the peripheral instance.
			[self raiseDidUpdatePeripheral:knownPeripheral];
		}
		else
		{
			STTraceError(@"peripheral already known");
		}
		
		return;
	}
	
	// Create a new TIOPeripheral instance from discovered data.
	TIOPeripheral *newPeripheral = [TIOPeripheral peripheralWithCBPeripheral:peripheral andAdvertisement:advertisement];
	// Add new instance to collection.
	[self.tioPeripherals addObject:newPeripheral];
	// Notify delegate.
	[self raiseDidDiscoverPeripheral:newPeripheral];
	// save updated peripheral collection
	[self savePeripherals];
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
	STTraceMethod(self, @"centralManagerDidConnectPeripheral %@", peripheral);

	// Find the corresponding TIOPeripheral instance...
	TIOPeripheral *tioPeripheral = [self findTIOPeripheralByIdentifier:peripheral.identifier];
	if (tioPeripheral)
	{
		// ... and let the TIOPeripheral instance handle the event.
		[tioPeripheral didConnect];
	}
}


- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
	STTraceMethod(self, @"centralManagerDidFailToConnectPeripheral %@", peripheral);

	// Find the corresponding TIOPeripheral instance...
	TIOPeripheral *tioPeripheral = [self findTIOPeripheralByIdentifier:peripheral.identifier];
	if (tioPeripheral)
	{
		// ... and let the TIOPeripheral instance handle the event.
		[tioPeripheral didFailToConnectWithError:error];
	}
}


- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
	STTraceMethod(self, @"centralManagerDidDisconnectPeripheral %@", peripheral);

	// Find the corresponding TIOPeripheral instance...
	TIOPeripheral *tioPeripheral = [self findTIOPeripheralByIdentifier:peripheral.identifier];
	if (tioPeripheral)
	{
		// ... and let the TIOPeripheral instance handle the event.
		[tioPeripheral didDisconnectWithError:error];
	}
}


#pragma mark - Delegate events

- (void)raiseBluetoothAvailable
{
	if ([self.delegate respondsToSelector:@selector(tioManagerBluetoothAvailable:)])
		[self.delegate tioManagerBluetoothAvailable:self];
}


- (void)raiseBluetoothUnavailable
{
	if ([self.delegate respondsToSelector:@selector(tioManagerBluetoothUnavailable:)])
		[self.delegate tioManagerBluetoothUnavailable:self];
}


- (void)raiseDidDiscoverPeripheral:(TIOPeripheral *)peripheral
{
	if ([self.delegate respondsToSelector:@selector(tioManager:didDiscoverPeripheral:)])
		[self.delegate tioManager:self didDiscoverPeripheral:peripheral];
}


- (void)raiseDidRetrievePeripheral:(TIOPeripheral *)peripheral
{
	if ([self.delegate respondsToSelector:@selector(tioManager:didRetrievePeripheral:)])
		[self.delegate tioManager:self didRetrievePeripheral:peripheral];
}


- (void)raiseDidUpdatePeripheral:(TIOPeripheral *)peripheral
{
	if ([self.delegate respondsToSelector:@selector(tioManager:didUpdatePeripheral:)])
		[self.delegate tioManager:self didUpdatePeripheral:peripheral];
}



#pragma mark - Internal interface towards TIOPeripheral

- (void)connectPeripheral:(TIOPeripheral *)peripheral
{
	STTraceMethod(self, @"connectPeripheral %@", peripheral);
	
	[self.cbCentralManager connectPeripheral:peripheral.cbPeripheral options:nil];
}


- (void)cancelPeripheralConnection:(TIOPeripheral *)peripheral
{
	STTraceMethod(self, @"cancelPeripheralConnection %@", peripheral);
	
	[self.cbCentralManager cancelPeripheralConnection:peripheral.cbPeripheral];
}


@end

