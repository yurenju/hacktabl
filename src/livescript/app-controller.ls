#= require app-constant.js
#= require app-service.js
#= require app-router.js
#= require angular-ga/ga.js

angular.module \app.controller, <[app.constant app.service ga app.router]>
.controller \AppCtrl, <[
       TableData Spy  State  EtherCalcData  $anchorScroll  $timeout
]> ++ (data,     Spy, State, EtherCalcData, $anchorScroll, $timeout)!->

  data.then (d) ~>
    @data = d

    # Go to anchor if there is one after all data is loaded
    $timeout ->
      $anchorScroll!

  @State = State

  EtherCalcData.then (data) !~>
    @EDIT_URL = data.EDIT_URL
    @TITLE = data.TITLE
    @LAYOUT_TYPE = data.TYPE
    @EMPHASIZE_NO_REF = data.EMPHASIZE_NO_REF

.controller \HeaderCtrl, <[
       Spy  State  $scope  $anchorScroll  $location  $modal  ga  HtmlDecoder  ETHERPAD_ID
]> ++ (Spy, State, $scope, $anchorScroll, $location, $modal, ga, HtmlDecoder, ETHERPAD_ID)!->

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
    unless Spy.current is null
      title = HtmlDecoder Spy.spies[Spy.current]
      ga \send, \pageview, {title}

  @open-info-modal = !->
    $modal.open do
      templateUrl: 'public/templates/info.html'
      controller: 'ModalCtrl as Modal'

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

  # During page load, show the info modal for users that visits the table for the first time
  #
  visit-key = "visit(#{ETHERPAD_ID})"
  unless local-storage[visit-key]
    local-storage[visit-key] = true
    @open-info-modal!

.controller \ModalCtrl, <[
       EtherCalcData  ETHERPAD_ID
]> ++ (EtherCalcData, ETHERPAD_ID) !->

  @ethercalc-id = ETHERPAD_ID
  EtherCalcData.then (data) !~>
    @EDIT_URL = data.EDIT_URL
    @INFO_URL = data.INFO_URL

.controller \HeadCtrl, <[
       EtherCalcData
]> ++ (EtherCalcData) !->
  @title = 'Hacktabl 協作比較表格'
  EtherCalcData.then (data) !~>
    @title = data.TITLE

.controller \TableRowCtrl, !->
  @is-expanded = false
  @toggle-expand = !~>
    @is-expanded = !@is-expanded