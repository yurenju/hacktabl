#= require app-constant.js
#= require app-service.js
#= require ui-bootstrap-selected.js
#= require ui-bootstrap-selected.js
#= require angular-ga/ga.js

angular.module \app.controller, <[app.constant app.service ui.bootstrap.selected ga]>
.controller \AppCtrl, <[
       EDIT_URL  TableData Spy  State  $modal
]> ++ (EDIT_URL, data,     Spy, State, $modal)!->
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
       Spy  State  $scope  $anchorScroll  $location  $modal  ga  DIMENSIONS
]> ++ (Spy, State, $scope, $anchorScroll, $location, $modal, ga, DIM)!->

  @Spy = Spy

  # Scroll to specified title
  @scroll-to = (e, title) !->
    e.prevent-default!
    $location.hash title
    $anchorScroll!

  $scope.$watch (-> Spy.current), !->
    # Switch to title view (hide the buttons) in titlebar when scrollspy changes
    State.titlebar = \title

    # Send pageview event to google analytics
    ga \send, \pageview, title: Spy.spies[Spy.current] unless Spy.current is null

  @openInfoModal = !->
    $modal.open do
      templateUrl: 'public/templates/info.html'
      controller: 'ModalCtrl as Modal'

  @openSubscribeModal = !->
    $modal.open do
      templateUrl: 'public/templates/subscribe-modal.html'
      controller: 'ModalCtrl as Modal'
      size: \sm

  # Setup @labelAction
  do ~!function write-label-action
    @label-action =
      if State.labels # label is "on" now.
        "按一下關閉"
      else
        "按一下開啟"

  # Toggle the label state on / off
  @toggle-labels = ->
    State.$cycle \labels
    write-label-action!

.controller \ModalCtrl, <[
       EDIT_URL  RULE_URL  DISCUSS_URL
]> ++ (EDIT_URL, RULE_URL, DISCUSS_URL) !->
  @EDIT_URL = EDIT_URL
  @RULE_URL = RULE_URL
  @DISCUSS_URL = DISCUSS_URL


.controller \SubscriptionCtrl, <[
       UserPreference $scope
]> ++ (UserPref,      $scope) !->
  console.log 'Subscription control'
  @email = UserPref.get-email!

  @subscribe = !~>
    console.log 'SUBSCRIBE', @email
    UserPref.subscribe @email

    # If in modal ($close exists in $scope), close the modal
    $scope.$close && $scope.$close()
