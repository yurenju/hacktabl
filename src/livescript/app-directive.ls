#= require app-service.js

angular.module \app.directive, <[app.service]>
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