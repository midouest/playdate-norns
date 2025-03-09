# Playdate Norns Mod

Connect your Playdate to norns!

## Installation

1. Install the mod ;install https://github.com/midouest/playdate-norns
2. Enable the mod in the SYSTEM > MODS menu
3. Restart norns

## API

The mod makes the `playdate` API available to norns scripts.

### Functions

`playdate.connected()`

Returns true if Playdate is connected, otherwise false

`playdate.send(msg)`

Send a string to Playdate. Playdate games can respond to the message by defining `playdate.serialMessageReceived(message)` in Lua 
or by registering a callback with `playdate->system->setSerialMessageCallback(...);` in C.

`playdate.run(path)`

Launch the PDX at the given path

`playdate.controller_start()`

Enable controller mode. The device will stream all button and crank changes to norns until controller mode is disabled or the lock button is pressed.
The running app on the Playdate will be paused while controller mode is active.

`playdate.controller_stop()`

Disable controller mode.

### Callbacks

`function playdate.add(id, name, dev)`

Called when the Playdate is connected. The Playdate must be unlocked.

`function playdate.remove(id)`

Called when the Playdate is removed. Locking the Playdate will remove it.

`function playdate.event(msg)`

Called for all non-controller mode serial messages. Serial messages can be sent from the Playdate using `print()` in Lua or `playdate->system->logToConsole()` in C.

`function playdate.accel(x, y, z)`

Called continuously with the accelerometer vector.

`function playdate.button(b, s)`

Called whenever a button is pressed or released. `n` is one of L, R, U, D, A, B or M. `s` is 1 for pressed and 0 for released.

`function playdate.crank(delta)`

Called whenever the crank is turned. Delta is the amount of degrees that the crank was turned.

`function playdate.crankdock(s)`

Called whenever the crank is docked or undocked. `s` is 1 for docked and 0 for undocked.
