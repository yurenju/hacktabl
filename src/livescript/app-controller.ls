#= require app-constant.js
#= require app-service.js

angular.module \app.controller, <[app.constant app.service]>
.controller \AppCtrl, <[
       EDIT_URL  MockData Spy  State
]> ++ (EDIT_URL, data,    Spy, State)!->
  @EDIT_URL = EDIT_URL

  data.then (d) ~>
    @data = d

  @State = State

.controller \HeaderCtrl, <[
       Spy  State  $scope  $anchorScroll  $location
]> ++ (Spy, State, $scope, $anchorScroll, $location)!->

  @Spy = Spy

  # Scroll to specified title
  @scroll-to = (e, title) !->
    e.prevent-default!
    $location.hash title
    $anchorScroll!

  # Show 'title' in titlebar when scrollspy changes
  $scope.$watch (-> Spy.current), ->
    State.titlebar = 'title'
