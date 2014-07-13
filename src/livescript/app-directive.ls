#= require app-service.js
#= require angular-animate/angular-animate.min.js
#= require angular-sanitize/angular-sanitize.min.js
#= require ui-bootstrap-selected.js

angular.module \app.directive, <[app.service ngAnimate ngSanitize ui.bootstrap.selected]>

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