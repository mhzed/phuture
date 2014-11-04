phuture
--------

A future utility to manipulate javascript timers, because 'setTimeout' and 'setInterval' are awkward:

- callBack is the first parameter?!  Especially painful to write in coffee-script.
- easier to cancel timer
- easier to readjust timer 


## Installation

    npm install phuture

## Examples
    
    var future = require("phuture")
    
    var onceTask = future.once( msInFuture, runCb)
    
    onceTask.cancel();  // cancel timer, will not ever run
    onceTask.finish();  // if not yet run, run then cancel timer, if already run, no affect
    onceTask.result();  // whatever runCb() returned
     
    var manyTask = future.interval( msInterval, functor)
    
    manyTask.cancel();  // cancel timer, will not ever run
    manyTask.finishAfter(n);  // run n more times, then stop timer
    manyTask.result();        // whatever most recent runCb() returned
    manyTask.resetInterval(msInterval/2)  // run twice faster!
    

See test/test.coffee for more examples.
    
    
     
    
    
