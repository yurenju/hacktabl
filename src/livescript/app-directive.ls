#= require app-service.js
#= require angular-animate/angular-animate.min.js
#= require angular-sanitize/angular-sanitize.min.js
#= require ui-bootstrap-selected.js
#= require angular-ga/ga.js

angular.module \app.directive, <[app.service ngAnimate ngSanitize ui.bootstrap.selected ga]>

# Scroll spy
#
# Usage: <div vu-sticky="200">...</div>
#
# Adds the class "is-sticky" to the element when the window.scrollTop exceeds
# the specified value.
#
.directive \vuSticky, <[
       WindowScroller
]> ++ (WindowScroller) ->
  const CLASS_NAME = \is-sticky

  # Returned linking function
  (scope, elem, attrs) ->

    # whether the CLASS_NAME has been attached or not
    is-sticky = elem.has-class CLASS_NAME

    const threshold = +attrs.vuSticky

    # Define on-scroll callback
    #
    unsubscribe = WindowScroller.subscribe ({scroll-top}) ->
      if scroll-top > threshold and is-sticky is not true
        is-sticky := true
        elem.add-class CLASS_NAME
      else if scroll-top < threshold and is-sticky is not false
        is-sticky := false
        elem.remove-class CLASS_NAME

    scope.$on \$destroy, unsubscribe

# Scroll spy
#
# Usage: <div vu-spy="'The title'">...</div>
#
# Sets the Spy service index when the element's top is passing the top edge of
# the screen.
#
.directive \vuSpy, <[
       $window  Spy
]> ++ ($window, Spy) ->

  # Returned linking function
  (scope, elem, attrs) ->

    const spy-id = scope.$eval(attrs.vuSpy)

    # Adding spy-id into the spies array
    #
    Spy.add spy-id

    # Cached DOM rect value.
    #
    rect = windowHeight = null
    !function update-cache
      rect := elem[0].getBoundingClientRect!
      windowHeight := $window.innerHeight

    # Debounced scroll event handling using requestAnimationFrame
    # http://www.html5rocks.com/en/tutorials/speed/animations/
    #
    is-requesting = false

    # Set the current spy and reset the is-requesting flag,
    # which is probably related to the "writing" of DOM
    #
    !function do-request
      scope.$apply ->
        Spy.current = Spy.spies.indexOf(spy-id)
      is-requesting := false

    do !function scrollHandler
      # Update rect from DOM
      update-cache!
      # console.log 'scrollHandler', spy-id, rect, elem

      # Continue to do-request only if it's not currently requesting,
      # and the element is crossing the top edge of the window.
      #
      return unless !is-requesting and rect.top <= 0 and rect.bottom > 0

      $window.requestAnimationFrame do-request
      is-requesting := true


    # Setup scroll callback
    #
    !function unsubscribe-scroll
      angular.element($window).off 'scroll', scroll-handler

    angular.element($window).on 'scroll', scroll-handler

    # Remove spy and callback on scope destroy
    scope.$on \$destory , ->
      Spy.remove spy-id
      unsubscribe-scroll!

#
# Disable ng-animate
#
.directive \noAnimate, <[
       $animate
]> ++ ($animate) ->
  (scope, elem) ->
    # console.log 'no ng-animate on element', elem
    $animate.enabled false, elem

#
# Compile given content and put into element
#
.directive \vuCompile, <[
       $compile
]> ++ ($compile) ->
  # Config object
  restrict: 'EA'
  link: (scope, elem, attrs) ->
    html = scope.$eval attrs.tmpl
    dom = ($compile "<div>#{html}</div>") scope

    elem.html '' .append dom

#
# Register new event map for comment popup
#
.config <[
       $tooltipProvider
]> ++ ($tooltip-provider) !->
  $tooltip-provider.set-triggers do
    '$comment-on': '$comment-off'

#
# Comment popup, reference: https://github.com/angular-ui/bootstrap/blob/master/src/tooltip/tooltip.js
#
.directive \commentPopup, <[
       TableData  ModalManager  State
]> ++ (TableData, ModalManager, State)->

  # Returned config object
  restrict: \EA
  replace: true
  scope:
    content: \@
    placement: \@
    animation: \&
    isOpen: \&
  templateUrl: 'public/templates/comment-popup.html'
  link: (scope, elem, attrs) ->

    TableData.then (data) ->
      scope.comments = for id in scope.content.split(',')
        data.comments[id]

    scope.edit = (e) ->
      e.prevent-default!
      State.$reset \comment
      ModalManager.open \edit

    # Prevent clicking in popup propagates to $document.
    #
    elem.on \click, -> it.stopPropagation!

#
# Hack around the $tooltip...
#
.directive \comment, <[
       $tooltip  State  $timeout  $document  $rootScope  $window
]> ++ ($tooltip, State, $timeout, $document, $rootScope, $window) ->

  # Reset all comments when document is clicked or ESC is pressed
  #
  reset-comment-state = ->
    return if State.$is-default \comment
    $rootScope.$apply ->
      State.$reset \comment

  $document.on \click, reset-comment-state

  $document.on \keyup, ->
    reset-comment-state! if it.which is 27 # ESC

  # Get config object
  config = $tooltip \comment, \comment, \$comment-on

  # Intercept the linking function returned by the original compile function.
  #
  original-compile = config.compile

  config.compile = ->
    original-link = original-compile ...

    # Return our link function
    return (scope, elem, attrs) !->

      scope.placement = \top

      # Invoke the original link function
      original-link ...

      # Use the first ID as current comment id
      comment-id = attrs.comment.split \, .0

      # Manually trigger the element when element is hovered
      trigger-comment = (e) ->
        e.stopPropagation!

        # setup tooltip placement
        #
        if elem[0].getBoundingClientRect!top < $window.innerHeight / 2
          # The top of element reaches the top half of the screen
          scope.placement = \bottom
        else
          scope.placement = \top

        scope.$apply ->
          State.comment = comment-id

      elem.on \mouseenter, trigger-comment
      elem.on \click, trigger-comment

      # Trigger the open or close of comment using the global state
      scope.$watch do
        -> State.comment
        (val) !->
          if val is comment-id
            <- $timeout
            elem.triggerHandler \$comment-on
          else
            <- $timeout
            elem.triggerHandler \$comment-off

  return config

#
# Send item-specific mouse events to Google analytics
#
# Usage: <ITEM vu-track="{perspective, position, content, label, category}">
#
# If the settings has "content" then we set event category = 'item', label = content.
# If the "category" nor "content" does not exist in settings, we set category = 'button'.
#
.directive \vuTrack, <[
       ga  HtmlDecoder  DIMENSIONS $timeout  $window
]> ++ (ga, HtmlDecoder, DIM,       $timeout, $window) ->
  # Returned link function
  (scope, elem, attrs) !->
    settings = scope.$eval attrs.vuTrack
    settings.perspective = HtmlDecoder settings.perspective if settings.perspective?
    settings.content = HtmlDecoder settings.content if settings.content?

    event-option =
      hitType: \event
      eventCategory: settings.category || \button
      eventLabel: settings.label
      eventValue: 1
      "#{DIM.PERSPECTIVE}": settings.perspective
      "#{DIM.POSITION}": settings.position

    if settings.content?
      # Tracking a specific item.
      # Set event category to 'item' and label to its content.
      # Since label are different, they will be counted as non-repeative events.

      event-option <<<
        eventCategory: \item
        eventLabel: settings.content

    click-option = angular.extend {}, event-option, eventAction: \click
    hover-option = angular.extend {}, event-option, eventAction: \hover
    copy-option = angular.extend {}, event-option, eventAction: \copy

    elem.on \click, ->
      ga \send, click-option

    # 500ms hover detection & timing
    promise = null
    entered = null

    elem.on \mouseleave, ->
      $timeout.cancel promise if promise
      timing-val = Date.now! - entered
      ga \send, \timing, event-option.eventCategory, \hover, timing-val, event-option.eventLabel

      promise := null
      entered := null

    elem.on \mouseenter, ->
      entered := Date.now!
      promise := $timeout do
        !->
          ga \send, hover-option
          promise := null
        500

    # TODO: copy events
    # https://developer.mozilla.org/en-US/docs/Web/Events/copy
    # http://msdn.microsoft.com/en-us/library/ie/hh772145(v=vs.85).aspx
    #
    # https://developer.mozilla.org/en-US/docs/Web/API/ClipboardEvent.clipboardData
    # http://msdn.microsoft.com/en-us/library/ie/ms535220(v=vs.85).aspx

    elem.on \copy, !->
      # Fill in the copied text into item-content dimension.
      copy-option[DIM.ITEM_CONTENT] = $window.getSelection! + ''
      ga \send, copy-option
