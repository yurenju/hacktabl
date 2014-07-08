angular.module \app.service, []
.factory \WindowScroller, <[
       $window  $timeout  $rootScope
]> ++ ($window, $timeout, $rootScope) ->
  win = angular.element($window)

  # scroll values
  values = {}
  getValues = ->
    values.offsetHeight = $window.document.body.offsetHeight
    values.clientHeight = $window.document.body.clientHeight
    values.scrollTop    = $window.document.body.scrollTop

    return values

  # registered callbacks
  callbacks = []

  # Debounced scroll event handling using requestAnimationFrame
  # http://www.html5rocks.com/en/tutorials/speed/animations/
  #
  isRequesting = false

  launchCallbacks = ->
    # console.log 'window scroller callbacks launching'
    $rootScope.$apply ->
      for callback in callbacks
        callback values
    isRequesting = false

  win.on 'scroll', ->
    getValues!

    # Skip if the animation frame is already requested.
    return if isRequesting

    # Request the animation frame.
    requestAnimationFrame launchCallbacks
    isRequesting = true


  # Return the service object singleton
  subscribe: (callback) ->

    callbacks.push callback
    $timeout -> callback getValues!

    # Returns unsubscribe function
    return ->
      callbacks.splice callbacks.indexOf(callback), 1
