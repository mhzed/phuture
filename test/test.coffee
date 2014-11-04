future = require "../lib/future"

module.exports["Once run"] = (test)->
  state = 0
  task = future.once 10, ()-> state = 1

  future.once 11, ()->
    test.equal(state, 1, "once task ran");
    test.equal(task.isCancelled(), false, 'not cancelled state')
    test.equal(task.isDone(), true, 'finished state')
    test.equal(task.result(), 1, "result saved")
    test.done();

module.exports["Once cancel"] = (test)->
  state = 0
  task = future.once 10, ()-> state = 1;
  task.cancel()
  task.finish() # no effect

  future.once 11, ()->
    test.equal(state, 0, "once task cancelled");
    test.equal(task.isCancelled(), true, 'cancelled state')
    test.equal(task.isDone(), true, 'finished state')
    test.equal(task.result(), undefined, "result not saved")
    test.done();

module.exports["Once finish"] = (test)->
  state = 0
  task = future.once 10, ()-> ++state
  task.finish()
  task.cancel() # no effect

  future.once 15, ()->
    test.equal(state, 1, "once task finished");
    test.equal(task.isCancelled(), false, 'not cancelled state')
    test.equal(task.isDone(), true, 'finished state')
    test.equal(task.result(), 1, "result saved")
    test.done();


module.exports["Interval run and cancel"] = (test)->
  state = 0
  task = future.interval 2, ()-> ++state;

  future.once 5, ()->
    test.equal(task.result(), state, "result saved")
    test.equal(task.isCancelled(), false, 'not cancelled state')
    test.equal(task.isDone(), false, 'not finished state')
    task.cancel()
    test.equal(task.isCancelled(), true, 'cancelled state')
    test.equal(task.isDone(), true, 'finished state')
    test.done();

module.exports["Interval run and finish"] = (test)->
  state = 0
  task = future.interval 2, ()-> ++state;
  task.finish()
  task.cancel() # no effect

  future.once 3, ()->
    test.equal(task.result(), state, "result saved")
    test.equal(task.isCancelled(), false, 'not cancelled state')
    test.equal(task.isDone(), true, 'finished state')
    test.done();


module.exports["Interval run and finish after"] = (test)->
  state = 0
  task = future.interval 2, ()-> ++state;
  task.finishAfter 5, ()->
    test.equal(task.result(), 5, "result saved")
    test.equal(state, 5, "state ok")
    test.done();

module.exports["Interval run and finish after, nested"] = (test)->
  state = 0
  task = future.interval 2, ()-> ++state;
  task.finishAfter 5, ()->

    test.equal(task.result(), 5, "result saved")
    test.equal(state, 5, "state ok")

    task.finishAfter 3, ()->
      test.equal(task.result(), 8, "result saved")
      test.equal(state, 8, "state ok")
      test.done();

module.exports["Interval run and reset interval"] = (test)->
  state = 0
  task = future.interval 2, ()-> ++state;
  future.once 10, ()->
    task.resetInterval 1
    oldstate = state
    state = 0
    future.once 10, ()->
      test.equal(state > oldstate + 1, true, 'is faster')
      task.cancel()
      test.done()



