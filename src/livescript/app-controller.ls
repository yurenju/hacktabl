require 'angular-ga/ga.js'
require './app-constant'
require './app-service'
require './app-router'

require('ngtemplate?relativeTo=templates/!html!jade-html!../jade/templates/info.jade')

require('ngtemplate?relativeTo=errors/!html!jade-html!../jade/errors/no-ethercalc.jade')
require('ngtemplate?relativeTo=errors/!html!jade-html!../jade/errors/no-doc-info.jade')
require('ngtemplate?relativeTo=errors/!html!jade-html!../jade/errors/not-shared.jade')
require('ngtemplate?relativeTo=errors/!html!jade-html!../jade/errors/error.jade')

angular.module \app.controller, <[app.constant app.service ga app.router]>
.controller \AppCtrl, <[
       TableData Spy  State  EtherCalcData  $anchorScroll  $timeout  ERRORS  $modal
]> ++ (data,     Spy, State, EtherCalcData, $anchorScroll, $timeout, ERRORS, $modal)!->

  data.then (d) ~>
    @data = d

    # Go to anchor if there is one after all data is loaded
    $timeout ->
      $anchorScroll!
  .catch (reason) ~>

    # Error handling
    #
    templateUrl = switch reason
    case ERRORS.NO_ETHERCALC
      'no-ethercalc.jade'
    case ERRORS.NO_DOC_INFO
      'no-doc-info.jade'
    case ERRORS.NOT_SHARED
      'not-shared.jade'
    default
      'error.jade'

    $modal.open do
      templateUrl: templateUrl
      controller: 'ErrorModalCtrl as ErrorModal'
      resolve: do
        reason: reason

  @State = State

  EtherCalcData.then (data) !~>
    @EDIT_URL = data.EDIT_URL
    @TITLE = data.TITLE
    @LAYOUT_TYPE = data.TYPE
    @EMPHASIZE_NO_REF = data.EMPHASIZE_NO_REF

.controller \ErrorModalCtrl, <[
       $window  $routeParams  reason  EtherCalcData
]> ++ ($window, $routeParams, reason, EtherCalcData) !->

  @id = $routeParams.id
  @reason = JSON.stringify(reason)

  EtherCalcData.then (data) !~>
    @ethercalcData = data

  @handleHomeButton = (e) !~>
    # Forces a full-page reload,
    # or the factories does not get initialized correctly.
    #
    $window.location.href = '/'


.controller \WelcomeCtrl, <[
       VisitHistory  $http  $window
]> ++ (VisitHistory, $http, $window)!->
  @history-records = ^^VisitHistory.get!

  # Prepare scope.historyRecords
  for let record, idx in @history-records
    @history-records[idx].time-str = new Date(record.time).toLocaleString!

    resp <~ $http.get "https://www.googleapis.com/drive/v2/files/#{record.doc-id}?fields=thumbnailLink&key=#{GOOGLE_API_KEY}" .then
    @history-records[idx].style = do
      'background-image': "url(#{resp.data.thumbnail-link})"

  @handleClick = (e, key) !~>
    # Forces a full-page reload,
    # or the factories does not get initialized correctly.
    #
    e.prevent-default!
    $window.location.href = '/' + key


.controller \HeaderCtrl, <[
       Spy  State  $scope  $anchorScroll  $location  $modal  ga  HtmlDecoder  $routeParams  VisitHistory
]> ++ (Spy, State, $scope, $anchorScroll, $location, $modal, ga, HtmlDecoder, $routeParams, VisitHistory)!->

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
      templateUrl: 'info.jade'
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
  unless VisitHistory.is-visited($routeParams.id)
    @open-info-modal!

  # Add or update visit record
  #
  VisitHistory.add $routeParams.id

.controller \ModalCtrl, <[
       EtherCalcData  $routeParams
]> ++ (EtherCalcData, $routeParams) !->

  @ethercalc-id = $routeParams.id
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
