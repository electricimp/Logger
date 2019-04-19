// MIT License
//
// Copyright 2019 Electric Imp
//
// SPDX-License-Identifier: MIT
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
// EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
// OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.

LOGGER_DEFAULT_UART_BAUD_RATE = 115200;

enum LOG_LEVEL {
    DEBUG,
    INFO,
    WARNING,
    ERROR
}

// Logging Singleton 
// NOTE: Logger can be used without initializing, log level will default to DEBUG, an no uart logs will appear
Logger <- {

    "level"   : LOG_LEVEL.DEBUG,
    "isAgent" : null, 
    "uart"    : null,

    "init" : function(_level, opts = {}) {
        // Set log level
        level = _level;
        // Store environment lookup 
        if (isAgent == null) isAgent = _isAgent();

        // Configure device options
        if (!isAgent) {
            if ("uart" in opts) {
                uart = opts.uart;
                if ("configureUART" in opts && opts.configureUART) {
                    local br = ("baudRate" in opts) ? opts.baudRate : LOGGER_DEFAULT_UART_BAUD_RATE;
                    uart.configure(br, 8, PARITY_NONE, 1, NO_CTSRTS);
                }
            }

            // Update _isConnected to use connection manager
            if ("cm" in opts && opts.cm != null) {
                _isConnected = function() {
                    return _cm.isConnected();
                }
            }
        }
    },

    "debug" : function(msg) {
        if (level <= LOG_LEVEL.DEBUG) {
            _log("[DEBUG]: " + msg.tostring());
        }
    },

    "info" : function(msg) {
        if (level <= LOG_LEVEL.INFO) {
            _log("[INFO]: " + msg.tostring());
        }
    },

    "warning" : function(msg) {
        if (level <= LOG_LEVEL.WARNING) {
            _log("[WARNING]: " + msg.tostring());
        }
    },

    "error" : function(msg) {
        if (level <= LOG_LEVEL.ERROR) {
            _log("[ERROR]: " + msg.tostring());
        }
    },

    "_isConnected" : function() {
        return server.isconnected();
    },

    "_isAgent" : function() {
        return (imp.environment() == ENVIRONMENT_AGENT);
    },

    "_log" : function(msg, err = false) {
        // Configure isAgent if needed 
        if (isAgent == null) isAgent = _isAgent();

        // Log message
        if (isAgent) {
            (err) ? server.error(msg) : server.log(msg);
        } else {
            if (_isConnected()) {
                (err) ? server.error(msg) : server.log(msg);
            }
            if (uart != null) {
                local d = date();
                local ts = format("%04d-%02d-%02d %02d:%02d:%02d", d.year, d.month+1, d.day, d.hour, d.min, d.sec);
                uart.write(ts + " " + msg + "\n\r");
            }
        }
    },
}

// Global logging functions
// NOTE: "error", "debug" and "log" are now all
// global variables and should not be used as 
// local variable names in other places in the code
debug <- Logger.debug.bindenv(Logger);
log <- Logger.info.bindenv(Logger);
warn <- Logger.warning.bindenv(Logger);
error <- Logger.error.bindenv(Logger);
