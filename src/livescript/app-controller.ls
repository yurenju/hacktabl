#= require app-constant.js
#= require app-service.js
#= require ui-bootstrap-selected.js

angular.module \app.controller, <[app.constant app.service ui.bootstrap.selected]>
.controller \AppCtrl, <[
       EDIT_URL  MockData Spy  State  $modal
]> ++ (EDIT_URL, data,    Spy, State, $modal)!->
  @EDIT_URL = EDIT_URL

  data.then (d) ~>
    @data = d

  @State = State

  @openEditModal = (evt) !->
    evt.prevent-default!
    $modal.open do
      templateUrl: 'public/templates/edit.html'
      controller: 'ModalCtrl as Modal'


.controller \HeaderCtrl, <[
       Spy  State  $scope  $anchorScroll  $location  $modal
]> ++ (Spy, State, $scope, $anchorScroll, $location, $modal)!->

  @Spy = Spy

  # Scroll to specified title
  @scroll-to = (e, title) !->
    e.prevent-default!
    $location.hash title
    $anchorScroll!

  # Show 'title' in titlebar when scrollspy changes
  $scope.$watch (-> Spy.current), ->
    State.titlebar = 'title'

  @openInfoModal = !->
    $modal.open do
      templateUrl: 'public/templates/info.html'
      controller: 'ModalCtrl as Modal'

  @openSubscribeModal = !->
    $modal.open do
      templateUrl: 'public/templates/subscribe-modal.html'
      controller: 'ModalCtrl as Modal'
      size: 'sm'


.controller \ModalCtrl, <[
       EDIT_URL  RULE_URL
]> ++ (EDIT_URL, RULE_URL) !->
  @EDIT_URL = EDIT_URL
  @RULE_URL = RULE_URL

