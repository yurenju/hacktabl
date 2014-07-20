#= require app-constant.js
#= require app-service.js
#= require angular-ga/ga.js

angular.module \app.controller, <[app.constant app.service ga]>
.controller \AppCtrl, <[
       TableData Spy  State  EtherCalcData
]> ++ (data,     Spy, State, EtherCalcData)!->

  data.then (d) ~>
    @data = d

  @State = State

  EtherCalcData.then (data) !~>
    @EDIT_URL = data.EDIT_URL
    @TITLE = data.TITLE

.controller \HeaderCtrl, <[
       Spy  State  $scope  $anchorScroll  $location  $modal  ga  HtmlDecoder
]> ++ (Spy, State, $scope, $anchorScroll, $location, $modal, ga, HtmlDecoder)!->

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

.controller \ModalCtrl, <[
       EtherCalcData  $location
]> ++ (EtherCalcData, $location) !->

  @ethercalc-id = $location.path!
  EtherCalcData.then (data) !~>
    @EDIT_URL = data.EDIT_URL
    @INFO_URL = data.INFO_URL

.controller \HeadCtrl, <[
       EtherCalcData  $location
]> ++ (EtherCalcData, $location) !->
  @title = 'Hacktabl 協作比較表格'
  EtherCalcData.then (data) !~>
    @title = data.TITLE
