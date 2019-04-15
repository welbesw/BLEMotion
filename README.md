# BLEMotion
An example iOS app that uses CoreBluetooth to send CoreMotion data to another iOS device via BLE

In order to send data from one iOS device to another, this app make use of both the peripheral mode and central mode of CoreBluetooth.  Peripheral mode is what we commonly think of for a peripheral like headphones, heart rate monitor, or a fit bit.  It's a device that is publishing BLE services for a central device to consume.  Central mode is what we commonly associate with an iPhone or computer - using a device to connect to an interact with peripherals.

iOS supports operating as both a peripheral and central.  It is most common for iOS apps to implement the central role, but for this app I have implemented both the peripheral and central roles.  The peripheral role will be used for the iOS device that is publishing it's core motion information for pitch, roll and yaw.  The application will provide the data on a single characteristic that is part of an exposed service.  The central roll will be filled by the app instance that will connect to the peripheral and read the Core Motion values that are being provided on the BLE service.

## Install

Install this app on two iOS devices in order to use the BLE functionality between devices.  Set one of the devices into peripheral mode and then connect to the peripheral from the device acting in the central role.

## Peripheral Mode

After starting the app, simply check the box on the main screen to begin sending Core Motion data from the device to the BLE service and characteristic.

## Central Mode

On a device that is not operating as a peripheral, navigate to the Peripheral List.  This list should show the nearby Peripheral device.  Make sure the app instance operating as a peripheral is started and in the foreground.  Tap on the peripheral instance in the list to connect to the device.  Once connected, the device details screen will show a real time update of the Euler Angles that are being sent on the BLE service.

## Visualize

Once connected to a peripheral, you can more easily visualize the data by tapping the "Visualize" button on the peripheral details screen to be taken to a visualization.  Here, I've used a simple 3D rendering of a rectangle that corresponds to the iOS device providing CoreMotion data.  As you move the device around, you'll see the on screen box move around as well.  Keep in mind that the angles are oriented with reference to magnetic north, so facing west generally gives a consistent feel between the iOS device being manipulated and the on screen visualization.

