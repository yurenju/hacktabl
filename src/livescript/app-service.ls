angular.module \app.service, []
#
# Debounced window scroll event listener, built to avoid layout threshing
#
.factory \WindowScroller, <[
       $window  $timeout  $rootScope
]> ++ ($window, $timeout, $rootScope) ->
  win = angular.element($window)

  # scroll values
  values = {}
  getValues = ->
    values.offsetHeight = $window.document.body.offsetHeight
    values.clientHeight = $window.document.body.clientHeight
    values.scrollTop    = $window.document.body.scrollTop

    return values

  # registered callbacks
  callbacks = []

  # Debounced scroll event handling using requestAnimationFrame
  # http://www.html5rocks.com/en/tutorials/speed/animations/
  #
  isRequesting = false

  launchCallbacks = ->
    # console.log 'window scroller callbacks launching'
    $rootScope.$apply ->
      for callback in callbacks
        callback values
    isRequesting = false

  win.on 'scroll', ->
    getValues!

    # Skip if the animation frame is already requested.
    return if isRequesting

    # Request the animation frame.
    requestAnimationFrame launchCallbacks
    isRequesting = true


  # Return the service object singleton
  subscribe: (callback) ->

    callbacks.push callback
    $timeout -> callback getValues!

    # Returns unsubscribe function
    return ->
      callbacks.splice callbacks.indexOf(callback), 1

#
# The app-wide scroll-spy state machine
#
.service \Spy, class Spy
  ->
    @spies = []
    @current = null

  add: (spy-id) -> @spies = @spies ++ spy-id
  remove: (spy-id) -> @spies.splice @spies.indexOf(spy-id), 1

#
# The app-wide multi-purpose state machine
#
.service \State, class State

  # Defined state name and their possible values.
  # The first enumerated value of each state is the default state value.
  #
  @enum =
    titlebar: <[title toolbox]>

  ->
    # Set the states to the instance
    #
    for own let name, values of @@enum
      @[name] = values[0]

  # Cycle through the state value, given a state name
  #
  $cycle: (name) ->
    current-index = @@enum[name].indexOf @[name]
    new-index = (current-index + 1) % @@enum[name].length
    console.log(current-index, new-index)
    @[name] = @@enum[name][new-index]

#
# Data mocking the parsed data from Google Doc
#
.factory \MockData, <[
       $q  $timeout
]> ++ ($q, $timeout) ->
  deferred = $q.defer!

  $timeout ->
    data =
      position-title:
        '正方／支持自經區'
        '反方／自經區的疑慮'

      perspectives:
        * title: <[政策 條例]>
          full-title: \政策與條例
          positions:
            * '2012年政府民調顯示，超過 6 成民意支持台灣加入區域經濟整合，包含 TPP。'
              '美國 CSIS 民調 100% 支持台灣參加 RCEP 與 TPP 區域經濟整合。'
              '產業與企業開放，主管機關是經濟部，什麼階段開放了什麼，都會公布。如果覺得作不好，就監督經濟部。'
              '示範區面對的「外國」，依國內法制，不包含中國。示範區對中國大陸另有限制。'
              '去年的法令修改與鬆綁，必須要自經區條例通過後才會生效，並且受立法院監看；若自經區沒過，那法規鬆綁就不會生效。'
              '空白授權的法案，細節訂完之後，需要送立法院備查，立法院也可以退案。'
            * []
        * title: <[農業 環境]>
          full-title: \農業與環境
          positions: [[], []]
        * title: <[健康 醫療]>
          full-title: \健康與醫療
          positions:
            * '簡化行政程序，特定職業以特別法立法，吸引外籍專業人士於示範區工作。'
              '每年預計吸引 93 個外籍專業人士。'
            * '為自經區鬆綁的外國人從事就業服務法審核標準之勞工預核制違背其母法就業服務法§47優先雇用本勞之精神。'
              ...
        * title: <[租稅 土地]>
          full-title: \租稅與土地
          positions:
            * '公有不動產讓售不受民意監督，但必須依照市價售出，符合公產權益。'
              '規定行政院會核定新示範區的設立。'
              '新示範區經費等需經過地方議會同意，故新設示範區會受民意機關監督。'
              '國外對示範區內的實質投資免稅。'
              '外籍專業人士，三年內所得稅半價。'
              '內銷貨物佔年度銷售總額 10% 內可免稅，超過者仍要交稅，鼓勵外銷。'
              '租稅淨效益為正，比「直接補助」對國家之衝擊小。'
            * '公有不動產（如政府土地）可以逕行讓售，不受民意機關同意與行政院核准，公有地可不經民意監督私相讓售。'
              '過去減稅讓電子業受益，但國外直接投資不增反減，稅賦天平歪斜。'
        * title: <[物流 金融]>
          full-title: \物流與金融
          positions:
            * '智慧物流之貨物進出示範區需用電子系統向海關通關，區內廠商必須建立電子帳冊受海關稽核。'
              ...
            * []

    deferred.resolve data

  return deferred.promise