#= require app-constant.js
#= require app-service.js

angular.module \app.controller, <[app.constant app.service]>
.controller \AppCtrl, <[
       EDIT_URL  MockData Spy  State  $scope  $anchorScroll  $timeout  $location
]> ++ (EDIT_URL, data,    Spy, State, $scope, $anchorScroll, $timeout, $location)!->
  @EDIT_URL = EDIT_URL
  data.then (d) ~>
    @data = d

  @Spy = Spy

  @State = State

  # Show 'title' in titlebar when scrollspy changes
  $scope.$watch (-> Spy.current), ->
    State.titlebar = 'title'

  @scroll-to = (e, title) !->
    e.prevent-default!
    $location.hash title
    $anchorScroll!
