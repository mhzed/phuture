const future = require("../lib/future");

module.exports["Once run"] = function(test) {
  let state = 0;
  const task = future.once(10, () => state = 1);

  return future.once(11, function() {
    test.equal(state, 1, "once task ran");
    test.equal(task.isCancelled(), false, 'not cancelled state');
    test.equal(task.isDone(), true, 'finished state');
    test.equal(task.result(), 1, "result saved");
    return test.done();
  });
};

module.exports["Once cancel"] = function(test) {
  let state = 0;
  const task = future.once(10, () => state = 1);
  task.cancel();
  task.finish(); // no effect

  return future.once(11, function() {
    test.equal(state, 0, "once task cancelled");
    test.equal(task.isCancelled(), true, 'cancelled state');
    test.equal(task.isDone(), true, 'finished state');
    test.equal(task.result(), undefined, "result not saved");
    return test.done();
  });
};

module.exports["Once finish"] = function(test) {
  let state = 0;
  const task = future.once(10, () => ++state);
  task.finish();
  task.cancel(); // no effect

  return future.once(15, function() {
    test.equal(state, 1, "once task finished");
    test.equal(task.isCancelled(), false, 'not cancelled state');
    test.equal(task.isDone(), true, 'finished state');
    test.equal(task.result(), 1, "result saved");
    return test.done();
  });
};

module.exports["Once finish with"] = function(test) {
  let state = 0;
  const task = future.once(10, function(n, m) { if (n) { return state = n + m; } });
  task.finish(3, 3);

  return future.once(15, function() {
    test.equal(state, 6, "once task finished");
    test.equal(task.isCancelled(), false, 'not cancelled state');
    test.equal(task.isDone(), true, 'finished state');
    test.equal(task.result(), 6, "result saved");
    return test.done();
  });
};

module.exports["Interval run and cancel"] = function(test) {
  let state = 0;
  const task = future.interval(2, () => ++state);

  return future.once(5, function() {
    test.equal(task.result(), state, "result saved");
    test.equal(task.isCancelled(), false, 'not cancelled state');
    test.equal(task.isDone(), false, 'not finished state');
    task.cancel();
    test.equal(task.isCancelled(), true, 'cancelled state');
    test.equal(task.isDone(), true, 'finished state');
    return test.done();
  });
};

module.exports["Interval run and finish"] = function(test) {
  let state = 0;
  const task = future.interval(2, () => ++state);
  task.finish();
  task.cancel(); // no effect

  return future.once(13, function() {
    test.equal(task.result(), state, "result saved");
    test.equal(task.isCancelled(), false, 'not cancelled state');
    test.equal(task.isDone(), true, 'finished state');
    return test.done();
  });
};

module.exports["Interval run and finish with"] = function(test) {
  let state = 0;
  const task = future.once(10, function(n, m) { if (n) { return state = n + m; } });
  task.finish(3, 3);
  task.cancel(); // no effect

  return future.once(13, function() {
    test.equal(task.result(), state, "result saved");
    test.equal(task.isCancelled(), false, 'not cancelled state');
    test.equal(task.isDone(), true, 'finished state');
    return test.done();
  });
};

module.exports["Interval run and finish after"] = function(test) {
  let state = 0;
  const task = future.interval(2, () => ++state);
  return task.finishAfter(5, function() {
    test.equal(task.result(), 5, "result saved");
    test.equal(state, 5, "state ok");
    return test.done();
  });
};

module.exports["Interval run and finish after, nested"] = function(test) {
  let state = 0;
  const task = future.interval(2, () => ++state);
  return task.finishAfter(5, function() {
    test.equal(task.result(), 5, "result saved");
    test.equal(state, 5, "state ok");

    return task.finishAfter(3, function() {
      test.equal(task.result(), 8, "result saved");
      test.equal(state, 8, "state ok");
      return test.done();
    });
  });
};

module.exports["Interval run and reset interval"] = function(test) {
  let state = 0;
  const task = future.interval(2, () => ++state);
  return future.once(10, function() {
    task.resetInterval(1);
    const oldstate = state;
    state = 0;
    return future.once(10, function() {
      test.equal(state > (oldstate + 1), true, 'is faster');
      task.cancel();
      return test.done();
    });
  });
};

module.exports["loop"] = function(test) {
  let task;
  return task = future.loop(1, (i, next) => {
    if (i < 2) {
      return next();
    } else { return test.done(); }
  });
};

module.exports["loop cancel"] = function(test) {
  const task = future.loop(1, (i, next) => {
    test.ok(false, 'never here');
    return next();
  });
  task.cancel();
  return test.done();
};
