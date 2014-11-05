
class OnceFuture

  constructor : (@ms, @cb)->
    @runTime = ()=> @res = @cb(); @timer = null;
    @timer = setTimeout @runTime, @ms

  cancel : ()->
    if @isDone() then return false;
    clearTimeout(@timer);
    @timer = undefined;
    true;
  # params if provided are passed to run callback
  finish : (params...)->
    if @isDone() then return false;
    clearTimeout(@timer);
    @res = @cb(params...); @timer = null;
    true;

  result : ()-> @res

    # true if cancelled or finished
  isDone : ()-> @timer == undefined || @timer == null
  isCancelled : ()-> @timer == undefined


class ManyFuture

  constructor : (@ms, @maxRun, @cb)->
    @n = 0    # run count
    @runTime = ()=>
      @res = @cb(); @n++;
      if @n == @maxRun
        if @finishCb then @finishCb()
        if @n == @maxRun # @finishCb may have extended
          clearInterval(@timer);
          @timer = null;


    @timer = setInterval @runTime, @ms

  # < 0: infinite more times, = 0: no more, > 0 how many times
  _remainTimes : ()-> @maxRun - @n

  cancel : ()->
    if @isDone() then return false;
    clearInterval(@timer);
    @timer = undefined;
    true
  # params if provided are passed to run callback
  finish : (params...)->
    if @isDone() then return false;
    clearInterval(@timer);
    @res = @cb(params...); @n++;
    @timer = null;
    true

  finishAfter : (n, @finishCb)-> @maxRun = @n + n;
  result : ()-> @res

  # true if cancelled or finished
  isDone : ()-> @timer == undefined || @timer == null
  isCancelled : ()-> @timer == undefined

  resetInterval : (@ms)->
    if @timer
      clearInterval(@timer);
      @timer = setInterval @runTime, @ms


module.exports = {

  once : (msInFuture, runCb)->
    return new OnceFuture(msInFuture, runCb)

  interval : (msInterval, runCb)->
    return new ManyFuture(msInterval, -1, runCb)


}