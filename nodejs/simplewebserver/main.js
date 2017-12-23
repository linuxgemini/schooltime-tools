'use strict';

var port = 80;                             // set target port

var connect = require('connect');          // import connect package
var serveStatic = require('serve-static'); // import static serving package
connect()                                  // initiate connect
    .use(serveStatic(__dirname))                     // serve every file in the current directory staticly
    .listen(port, () => {                       // listen on target port
        console.log(`Server running on port ${port}...\n`); // report back to console
    });
