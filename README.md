# Logger #

The Logger library adds log level tags to the imp API's logging methods, and filters logs based on the currently set log level. This library can be used on either/both the agent and the device. Logger is a singleton and as such it can be used without initialization. If the device is [initialized](#initlevel-options) with UART it will log based on the level to both the UART and, if the device is connected to the server, to the server via the imp API's `server.log` and `server.error` methods. 

**To add this library to your project, add** `#require "Logger.lib.nut:1.0.0"` **to the top of your code.**

## Logger Methods ##

### init(*level[, options]*) ###

Use the init method to set the log level, and on the device to enable UART logging. When using the logging functions in this library, only the logs equal to or below the currently set logging level will appear. By default the level is set to LOG_LEVEL.DEBUG, so all logging methods with generate log messages.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *level* | enum | Yes | LOG_LEVEL, [See below](#log_level-enum) |  
| *options* | table | No | Table containing additional configuration parameters. The default is an empty table. [See below](#init-options) |

#### Return Value ####

Logger table reference.

##### LOG_LEVEL enum: ##### 

| Name | Value |
| --- | --- |
| *DEBUG* | 0 |
| *INFO* | 1 |
| *WARNING* | 2 |
| *ERROR* | 3 |

##### Init Options #####

| Slot | Value | Supported on | Description | 
| --- | --- | --- | --- |
| *cm* | ConnectionManager instance | device | Used to determine if the the device is connected, if cm is not provided the imp API server.isconnected method will be used instead | 
| *uart* | imp UART object | device |  Used for logging via the UART |
| *configureUART* | Boolean | device | Whether this method should configure the UART |
| *baudRate* | Integer | device | The baud rate that should be used to configure the UART. If one is not provided a default baud rate of 115200 will be used |

Agent:
```squirrel
Logger.init(LOG_LEVEL.INFO);
```

Device:
```squirrel
cm <- ConnectionManager();
opts <- {
    "cm"            : cm, 
    "uart"          : hardware.uartDCAB,
    "configureUART" : true
}

Logger.init(LOG_LEVEL.INFO, opts);
```

### debug(*logEntry*) ###

Creates a debug level log.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *logEntry* | String | Yes | Message to be logged. |  

#### Return Value ####

Integer — 0 on success, or a [Send Error Code](https://developer.electricimp.com/api/server) on failure

```
Logger.debug("Wake reason: new squirrel code");

// Creates a server.log
2019-04-18T23:12:21.451 +00:00 [Device] [DEBUG]: Wake reason: new squirrel code

// Creates a UART log 
2019-04-18 23:12:20 [DEBUG]: Wake reason: new squirrel code
```

### info(*logEntry*) ###

Creates a info level log.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *logEntry* | String | Yes | Message to be logged. |  

#### Return Value ####

Integer — 0 on success, or a [Send Error Code](https://developer.electricimp.com/api/server) on failure

```
Logger.info("Disabling GPS power");

// Creates a server.log
2019-04-18T23:12:34.164 +00:00 [Device] [INFO]: Disabling GPS power

// Creates a UART log 
2019-04-18 23:12:33 [INFO]: Disabling GPS power
```

### warning(*logEntry*) ###

Creates a warning level log.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *logEntry* | String | Yes | Message to be logged. |  

#### Return Value ####

Integer — 0 on success, or a [Send Error Code](https://developer.electricimp.com/api/server) on failure

```
Logger.warning("Going to sleep...");

// Creates a server.log
2019-04-18T23:12:34.620 +00:00 [Device] [WARNING]: Going to sleep...

// Creates a UART log 
2019-04-18 23:12:33 [WARNING]: Going to sleep...
```

### error(*logEntry*) ###

Creates an error level log. These will be logged using server.error method.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *logEntry* | String | Yes | Message to be logged. |  

#### Return Value ####

Integer — 0 on success, or a [Send Error Code](https://developer.electricimp.com/api/server) on failure

```
Logger.error("Report send failed.");

// Creates a server.error
2019-04-18T23:12:34.165 +00:00 [Device] ERROR: [ERROR]: Report send failed.

// Creates a UART log 
2019-04-18 23:12:33 [ERROR]: Report send failed.
```

## Full Example ##

```
#require "Logger.lib.nut:1.0.0"

cm <- ConnectionManager();
opts <- {
    "cm"            : cm, 
    "uart"          : hardware.uartDCAB,
    "configureUART" : true
}

Logger.init(LOG_LEVEL.INFO, opts);

// Global logging functions
// NOTE: "error", "debug", "warn", and "log" are now all
// global variables and should not be used as 
// local variable names in other places in the code
debug <- Logger.debug.bindenv(Logger);
log <- Logger.info.bindenv(Logger);
warn <- Logger.warning.bindenv(Logger);
error <- Logger.error.bindenv(Logger);

// Create some logs
::log("Device running...");
::debug(imp.getsoftwareversion()); // This log will not appear

::warn("This is a warning");
::error("Oh no, an error has occurred");

Logger.init(LOG_LEVEL.DEBUG);
::debug(imp.getsoftwareversion()); // This log will now appear
```

## Licence ##

This library is licensed under the [MIT License](./LICENSE).