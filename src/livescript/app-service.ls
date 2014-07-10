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
    titlebar: <[title toolbox]> # Show title or toolbox in header
    labels: [true, false]        # Whether the labels in content to be shown

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
          positions: [[
            * ref: '<a href="https://www.google.com/url?q=https%3A%2F%2Fg0v.hackpad.com%2F20140528-PART-I-Zw8BPf9G4oQ%23%3Ah%3D-40%3A00~45%3A00-YusanHsu&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNHxRBqOs-SQt6rRUwEAknzGt6esww">第一次溝通會逐字稿 45 分處</a>'
              content: '2012年政府民調顯示，超過 6 成民意支持台灣加入區域經濟整合，包含 TPP。'
            * ref: '<a href="https://www.google.com/url?q=https%3A%2F%2Fg0v.hackpad.com%2F20140528-PART-I-Zw8BPf9G4oQ%23%3Ah%3D-40%3A00~45%3A00-YusanHsu&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNHxRBqOs-SQt6rRUwEAknzGt6esww">第一次溝通會逐字稿 45 分處</a>'
              content: '美國 CSIS 民調 100% 支持台灣參加 RCEP 與 TPP 區域經濟整合。'
            * ref: '<a href="https://www.google.com/url?q=https%3A%2F%2Fg0v.hackpad.com%2F20140528-PART-I-Zw8BPf9G4oQ%23%3Ah%3D-35%3A00~40%3A00-Shawn-Huang&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNG1GSprIaC2yPUVddZmYVWAwrW__w">逐字稿 40 分處</a>'
              content: '產業與企業開放，主管機關是經濟部，什麼階段開放了什麼，都會公布。如果覺得作不好，就監督經濟部。'
            * ref: '<a href="http://www.google.com/url?q=http%3A%2F%2Fwww.fepz.org.tw%2Fm1.aspx%3FsNo%3D0060479&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNEKwgGWJDp17qXrskqyQv9XoMP95w">6/10 質疑回應 p.4</a>'
              content: '示範區面對的「外國」，依國內法制，不包含中國。示範區對中國大陸另有限制。'
            * ref: '<a href="https://www.google.com/url?q=https%3A%2F%2Fg0v.hackpad.com%2F20140528-PART-I-Zw8BPf9G4oQ%23%3Ah%3D-45%3A00~50%3A00-Lyra&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNHznOOgJV2mAK56hicGvZ8iZS4pLw">逐字稿 50 分處</a>'
              content: '去年的法令修改與鬆綁，必須要自經區條例通過後才會生效，並且受立法院監看；若自經區沒過，那法規鬆綁就不會生效。'
            * ref: '<a href="https://www.google.com/url?q=https%3A%2F%2Fg0v.hackpad.com%2F20140528-PART-I-Zw8BPf9G4oQ%23%3Ah%3D-55%3A00~1%3A00%3A00-Amu&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNGu1yuxMwp7-c2JCY_goAZAM5dAow">逐字稿 55 分處</a>'
              content: '空白授權的法案，細節訂完之後，需要送立法院備查，立法院也可以退案。'
          ], []]
        * title: <[農業 環境]>
          full-title: \農業與環境
          positions: [[], []]
        * title: <[健康 醫療]>
          full-title: \健康與醫療
          positions: [[
            * ref: '<a href="http://www.google.com/url?q=http%3A%2F%2Fwww.fepz.org.tw%2Fdn.aspx%3Fuid%3D35707&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNGGs9BwLGcf0H1fY1ah0wQn_-wMCg">法規影響評估報告p23</a>'
              content: '簡化行政程序，特定職業以特別法立法，吸引外籍專業人士於示範區工作。'
            * ref: '<a href="http://www.google.com/url?q=http%3A%2F%2Fwww.fepz.org.tw%2Fdn.aspx%3Fuid%3D35707&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNGGs9BwLGcf0H1fY1ah0wQn_-wMCg">法規影響評估報告p25</a>'
              content: '每年預計吸引 93 個外籍專業人士。'
          ], [
            * ref: '<a href="http://www.google.com/url?q=http%3A%2F%2Fbilly3321.gitbooks.io%2Ftaiwanfepzs%2F3-1.html&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNHviDkzVNWeB0KJ0lrNGn2jDeb6jg">沃草自經區爭議書</a>'
              content: '為自經區鬆綁的<a href="http://www.google.com/url?q=http%3A%2F%2Flaw.moj.gov.tw%2FLawClass%2FLawAll.aspx%3FPCode%3DN0090029&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNEKWKBODzjIOVYoQavTB2IaWtMG0A">外國人從事就業服務法審核標準</a>之<a href="https://www.google.com/url?q=https%3A%2F%2Fsites.google.com%2Fa%2Flabor.ngo.tw%2Flabor%2F2013NEWS%2F20130411&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNGEjnkrrmGjZu9DAM1PKwjPbJdJkQ">勞工預核制</a>違背其母法<a href="http://www.google.com/url?q=http%3A%2F%2Flaw.moj.gov.tw%2FLawClass%2FLawSingle.aspx%3FPcode%3DN0090001%26FLNO%3D47&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNEUEQXPcXEHgu5HN5bfjMoQV3DWsw">就業服務法§47</a>優先雇用本勞之精神。'
          ]]
        * title: <[租稅 土地]>
          full-title: \租稅與土地
          positions: [[
            * ref: '<a href="https://www.google.com/url?q=https%3A%2F%2Fg0v.hackpad.com%2F20140528-PartIII--nohCg9qxSFT&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNEfXdDw5oUGtWjfnGG_UjXjY_n-QA">第一次溝通會逐字稿 2時30分處</a>'
              content: '公有不動產讓售不受民意監督，但必須依照市價售出，符合公產權益。'
            * ref: '<a href="http://www.google.com/url?q=http%3A%2F%2Fwww.fepz.org.tw%2Fdn.aspx%3Fuid%3D34042&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNGWxsR2HXdcpuSeGdRc352B1VMmzw">自經區草案 §13-2</a>'
              content: '規定行政院會核定新示範區的設立。'
            * ref: '<a href="https://www.google.com/url?q=https%3A%2F%2Fwww.facebook.com%2FFEPZ.TW%2Fposts%2F846983645330890%3Freply_comment_id%3D853369284692326%26total_comments%3D1&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNHY5LRgudxqcsqUiCVTB9nxvtwj_Q">自經區粉專小編回文</a>'
              content: '新示範區經費等需經過地方議會同意，故新設示範區會受民意機關監督。'
            * ref: '<a href="http://www.google.com/url?q=http%3A%2F%2Fwww.fepz.org.tw%2Fdn.aspx%3Fuid%3D35707&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNGGs9BwLGcf0H1fY1ah0wQn_-wMCg">法規影響評估報告p31</a>'
              content: '租稅淨效益為正，比「直接補助」對國家之衝擊小。'
          ], [
            * ref: '<a href="http://www.google.com/url?q=http%3A%2F%2Fbilly3321.gitbooks.io%2Ftaiwanfepzs%2F2-2.html&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNG7wYW_jlXYT_O3wZS_izKn75gm9g">沃草自經爭議書</a>、<a class="c5" href="http://www.google.com/url?q=http%3A%2F%2Fwww.fepz.org.tw%2Fdn.aspx%3Fuid%3D34042&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNGWxsR2HXdcpuSeGdRc352B1VMmzw">自經區草案 §19</a>'
              content: '公有不動產（如政府土地）可以逕行讓售，不受民意機關同意與行政院核准，公有地可不經民意監督私相讓售。'
            * ref: '<a href="http://www.google.com/url?q=http%3A%2F%2Fbilly3321.gitbooks.io%2Ftaiwanfepzs%2F3-1.html&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNHviDkzVNWeB0KJ0lrNGn2jDeb6jg">沃草自經區爭議書</a>'
              content: '過去減稅讓電子業受益，但國外直接投資不增反減，稅賦天平歪斜。'
          ]]
        * title: <[物流 金融]>
          full-title: \物流與金融
          positions: [[
            * ref: '<a href="http://www.google.com/url?q=http%3A%2F%2Fwww.fepz.org.tw%2Fdn.aspx%3Fuid%3D34042&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNGWxsR2HXdcpuSeGdRc352B1VMmzw">自經區草案§36、37</a>'
              content: '智慧物流之貨物進出示範區需用電子系統向海關通關，區內廠商必須建立電子帳冊受海關稽核。'
          ], []]

      comments: # types: REF_MISSING, REF_CONTROVERSIAL, NOTE
        {}
        {}
        {}
        * type: \REF_MISSING
          content: "民調應該有開放資料可以查。"
        * type: \APPROVAL
          name: "Anonymous"
          content: "+1 我也覺得。"
        * type: \REF_MISSING
          content: "民調應該有開放資料可以查。"
        * type: \REF_MISSING
          content: "法規鬆綁是自經區第一階段的目標。可以列出去年因自經區修改的法律，看看是否有「自經區過了才生效」的但書。"
        * type: \NOTE
          content: "自經區草案§58、§59、§60 分別定義了會計師、建築師、律師的行政程序。"
        * type: \NOTE
          content: "根據自經區條例"
        * type: \NOTE
          content: "此為土地法 §25 的規範，但自經區草案 §19、§23 明定，區內公有不動產不循土地法 §25 限制。\nhttp://law.moj.gov.tw/LawClass/LawSingle.aspx?Pcode=D0060001&FLNO=25"

    deferred.resolve data

  return deferred.promise

# Saves / loads the preference from localStorage.
# The user preference include email and experiment settings
#
.service \UserPreference, class UserPreference
  # localStorage object reference, populated in constructor
  storage = null

  @$inject = <[
    $window
  ]>
  ( $window ) ->
    storage := $window.localStorage # Populate the storage reference

  subscribe: (email) !->
    storage.email := email

  get-email: ->
    storage.email

  backout: !->
    storage.isBackedout := true

  can-send-data: ->
    !storage.isBackedout

#
# Parses arguments (論述)
#
.factory \ArgumentParser, <[
       $interpolate
]> ++ ($interpolate) ->

  const COMMENT_TEMPLATE = '
    <{{tagName}} comment="{{id}}" comment-placement="top" comment-trigger="click" 
     comment-append-to-body="true">{{content}}</{{tagName}}>
    '

  const COMMENT = /<span class="[^"]+">([^<]+)<\/span>((?:<sup>.+?<\/sup>)+)/gim
  const EXTRACT_ID = /#cmnt(\d+)/g
  const GARBAGE_LEN = '#cmnt'.length
  const SPAN_START = /<span class="[^"]+">/gim
  const SPAN_END   = /<\/span>/gim
  const SPAN_PLACEHOLDER_STR = 'xx-span-xx'
  const SPAN_PLACEHOLDER = new RegExp SPAN_PLACEHOLDER_STR, 'gm'

  parser = (doc) ->
    # Construct the comments
    return doc.replace COMMENT, (m, content, sups) ->
      # sups should look like:
      # <sup>....</sup><sup>....</sup><sup>....</sup>...
      #
      # We now track the ids from those <sup>s
      #
      ids = sups.match EXTRACT_ID .map (.slice(GARBAGE_LEN))

      return ($interpolate COMMENT_TEMPLATE) do
        id: ids * \,
        content: content
        tag-name: SPAN_PLACEHOLDER_STR

    .replace SPAN_START, ''
    .replace SPAN_END, ''
    .replace SPAN_PLACEHOLDER, 'span'


  parser.COMMENT_TEMPLATE = COMMENT_TEMPLATE

  return parser

#
# Split a <li> content into content and its reference
#
.factory \ItemSplitter, ->
  const SPLITTER   = /<span class="[^"]+">\s*\[\s*出處\s*/gm
  const SPAN_START = /<span class="[^"]+">/gim
  const SPAN_END   = /]?\s*<\/span>*/gim
  const CLASS      = /\s+class="[^"]+"/gim

  # Returned function
  (doc) ->
    idx = doc.search SPLITTER

    # If splitter is not found, set to the end of the string
    idx = doc.length if idx is -1

    # Returned object
    content: doc.slice(0, idx)
    ref: doc.slice(idx)
      .replace(SPLITTER, '').replace(SPAN_START, '')
      .replace(SPAN_END, '').replace(CLASS, '').trim()

#
# Find table and extract data into the following format:
# {
#   positionTitle: [],
#   perspectives: [ // 面向
#     {
#       title: [a, b],
#       fullTitle: "a&b",
#       positions: [[{ref, content}, ...], [...]] // 立場發言
#     }
#     ...
#   ]
#
#
.factory \TableParser, ->

  # Returned function
  (doc) ->

    # Returned object
    position-title: ''
    perspectives: []