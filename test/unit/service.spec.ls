(...) <-! describe \service, _

expect-from-fixture = (parser, basename, parser-options) ->
  input = __html__["test/unit/fixtures/#{basename}.html"]
  expected = JSON.parse __html__["test/unit/fixtures/#{basename}.json"]
  expect parser(input, parser-options) .toEqual expected

# Mock app.router to skip any router activity
#
angular.module 'app.router', []
.value \ETHERPAD_ID, \dummy

before-each module('app.service')

# describe \MockData (...) !->
#   it 'should return object asynchronously', inject (MockData) !->
#     MockData.then (data) !->
#       expect data.perspectives .toBeDefined!

describe \HighlightParser (...) !->

  before-each !->
    ($provide) <-! module _
    $provide.value \StyleData, do
      c14:
        underline: true
        italic: false
        bold: false

  parser-option =
    no-sanitize: true

  it 'should be a function', inject (HighlightParser) !->
    expect(typeof HighlightParser).toBe 'function'

  it 'should return a string, given a string', inject (HighlightParser) !->
    expect(typeof HighlightParser('arbitary string')).toBe 'string'

  it 'should strip useless <span>s', inject (HighlightParser) !->
    input    = '<span class="c14">示範區面對的「外國」，依國內法制，不包含中國。示範區對中國大陸另有限制。</span>'
    expected = '示範區面對的「外國」，依國內法制，不包含中國。示範區對中國大陸另有限制。'

    expect HighlightParser(input, {}, parser-option) .toEqual expected

  it 'should parse one comment', inject (HighlightParser) !->
    input    = '<span class="c14">去年的法令修改與鬆綁，必須要自經區條例通過後才會生效</span><sup><a href="#cmnt6" name="cmnt_ref6">[f]</a></sup><span class="c14">，並且受立法院監看；若自經區沒過，那法規鬆綁就不會生效。</span>'
    comment  = HighlightParser.GENERATE_COMMENT do
      content: '去年的法令修改與鬆綁，必須要自經區條例通過後才會生效'
      id: '6'
    expected = "#{comment}，並且受立法院監看；若自經區沒過，那法規鬆綁就不會生效。"

    expect HighlightParser(input, {}, parser-option) .toEqual expected

  it 'should parse comments and its replies', inject (HighlightParser) !->
    input    = '<span class="c5">去年的法令修改與鬆綁，必須要自經區條例通過後才會生效</span><sup><a href="#cmnt6" name="cmnt_ref6">[f]</a></sup><sup><a href="#cmnt7" name="cmnt_ref7">[g]</a></sup><sup><a href="#cmnt8" name="cmnt_ref8">[h]</a></sup><span class="c5">，並且受立法院監看；若自經區沒過，那法規鬆綁就不會生效。</span>'
    comment  = HighlightParser.GENERATE_COMMENT do
      content: '去年的法令修改與鬆綁，必須要自經區條例通過後才會生效'
      id: '6,7,8'
    expected = "#{comment}，並且受立法院監看；若自經區沒過，那法規鬆綁就不會生效。"

    expect HighlightParser(input, {}, parser-option) .toEqual expected

  it 'should parse multiple separated comments', inject (HighlightParser) !->
    input    = '<span class="c4">2012年政府民調顯示</span><sup><a href="#cmnt4" name="cmnt_ref4">[d]</a></sup><span class="c4">，超過</span><span class="c4">&nbsp;6 成民意</span><sup><a href="#cmnt5" name="cmnt_ref5">[e]</a></sup><span class="c4">支持台灣</span><sup><a href="#cmnt6" name="cmnt_ref6">[f]</a></sup><span class="c4">加入區域經濟整合，包含 TPP。</span>'
    content1 = HighlightParser.GENERATE_COMMENT do
      content: '2012年政府民調顯示'
      id: 4
    content2 = HighlightParser.GENERATE_COMMENT do
      content: '&nbsp;6 成民意'
      id: 5
    content3 = HighlightParser.GENERATE_COMMENT do
      content: '支持台灣'
      id: 6

    expected = "#{content1}，超過#{content2}#{content3}加入區域經濟整合，包含 TPP。"

    expect HighlightParser(input, {}, parser-option) .toEqual expected

  it 'should deal with reference section as well', inject (HighlightParser) !->
    input = '</span><span class="c4">&#27492;&#21477;&#26159;&#21738;&#35041;&#30475;&#21040;&#30340;&#65292;&#38468;&#36229;&#36899;&#32080;&#30340;&#36899;&#32080;&#12290;&#35519;&#25104; 8pt &#28784;&#33394;&#65292;&#26371;&#35731;&#27491;&#25991;&#27604;&#36611;&#26126;&#39023;&#12290;</span><sup><a href="#cmnt2" name="cmnt_ref2">[b]</a></sup><sup><a href="#cmnt3" name="cmnt_ref3">[c]</a></sup>'
    content = HighlightParser.GENERATE_COMMENT do
      content: '&#27492;&#21477;&#26159;&#21738;&#35041;&#30475;&#21040;&#30340;&#65292;&#38468;&#36229;&#36899;&#32080;&#30340;&#36899;&#32080;&#12290;&#35519;&#25104; 8pt &#28784;&#33394;&#65292;&#26371;&#35731;&#27491;&#25991;&#27604;&#36611;&#26126;&#39023;&#12290;'
      id: '2,3'

    expected = content

    expect HighlightParser(input, {}, parser-option) .toEqual expected

  it 'should add classes according to comment types', inject (HighlightParser, CommentParser) !->
    input = '<span>A</span><sup><a href="#cmnt4" name="cmnt_ref4">[d]</a></sup><span>B</span><sup><a href="#cmnt5" name="cmnt_ref5">[d]</a></sup><span>C</span><sup><a href="#cmnt6" name="cmnt_ref6">[d]</a></sup>'
    comments =
      \4 :
        type: CommentParser.types.REF_MISSING
      \5 :
        type: CommentParser.types.SECOND
      \6 :
        type: CommentParser.types.NOTE

    content1 = HighlightParser.GENERATE_COMMENT do
      content: \A
      id: \4
      classes:
        \is-controversial : true

    content2 = HighlightParser.GENERATE_COMMENT do
      content: \B
      id: \5
      classes: {}

    content3 = HighlightParser.GENERATE_COMMENT do
      content: \C
      id: \6
      classes:
        \is-info : true

    expected = [content1, content2, content3].join ''

    expect HighlightParser(input, comments) .toEqual expected

  it 'should keep the <span>s if has-highlight option is provided', inject (HighlightParser) !->
    input    = '<span class="c14">示範區面對的「外國」，依國內法制，不包含中國。示範區對中國大陸另有限制。</span>'
    expected = '<span ng-class=\'{"underline":true,"italic":false,"bold":false}\'>示範區面對的「外國」，依國內法制，不包含中國。示範區對中國大陸另有限制。</span>'

    expect HighlightParser(input, {}, {has-highlight: true, no-sanitize: true}) .toEqual expected

  it 'should $sanitize its input and output ng-class when has-highlight is on', inject (HighlightParser) !->
    input    = 'Test <span class="c14">Highlighted</span> <script>alert("evil")</script>'
    expected = 'Test <span ng-class=\'{"underline":true,"italic":false,"bold":false}\'>Highlighted</span>'

    expect HighlightParser(input, {}, {has-highlight: true}) .toEqual expected

describe \ItemSplitter (...) !->
  it 'should be a function', inject (ItemSplitter) !->
    expect(typeof ItemSplitter).toBe 'function'

  it 'should return with argument & ref, given a string without reference', inject (ItemSplitter) !->

    expect ItemSplitter('arbitary string') .toEqual do
      content : 'arbitary string'
      ref     : ''
      labels  : []

  it 'should extract simple reference from <li> content', inject (ItemSplitter) !->
    input      = '<span class="c5">國外對示範區內的實質投資免稅。</span><span class="c9">[&#20986;&#34389; </span><span class="c9 c18"><a class="c3" href="AAAA">自經區草案§31</a></span><span class="c21 c9">]</span>'

    expect ItemSplitter(input) .toEqual do
      content : '<span class="c5">國外對示範區內的實質投資免稅。</span><span class="c9">'
      ref      : '</span><span class="c9 c18"><a class="c3" href="AAAA">自經區草案§31</a></span>'
      labels: []

  it 'should extract reference with multiple <a>', inject (ItemSplitter) !->
    input       = '<span class="c5">公有不動產（如政府土地）可以逕行讓售，不受</span><span class="c5">民意機關同意與行政院核准</span><sup><a href="#cmnt11" name="cmnt_ref11">[k]</a></sup><span class="c5">，公有地可不經民意監督私相讓售。</span><span class="c9">[&#20986;&#34389; </span><span class="c9 c18"><a class="c3" href="BBBB">沃草自經爭議書</a></span><span class="c9">、</span><span class="c9 c18"><a class="c3" href="AAAA">自經區草案 §19</a></span><span class="c9 c21">]</span>'

    expect ItemSplitter(input) .toEqual do
      content  : '<span class="c5">公有不動產（如政府土地）可以逕行讓售，不受</span><span class="c5">民意機關同意與行政院核准</span><sup><a href="#cmnt11" name="cmnt_ref11">[k]</a></sup><span class="c5">，公有地可不經民意監督私相讓售。</span><span class="c9">'
      ref       : '</span><span class="c9 c18"><a class="c3" href="BBBB">沃草自經爭議書</a></span><span class="c9">、</span><span class="c9 c18"><a class="c3" href="AAAA">自經區草案 §19</a></span>'
      labels: []

  it 'should extract and html-decode labels', inject (ItemSplitter) !->
    input = '<span>[反對台灣獨立][支持兩岸關係] 兩岸是「</span><span>整個中國</span><span>」內部的兩個憲政政府'
    expect ItemSplitter(input) .toEqual do
      content  : '<span>兩岸是「</span><span>整個中國</span><span>」內部的兩個憲政政府'
      ref       : ''
      labels: ['反對台灣獨立', '支持兩岸關係']

    input = '<span class="c5">[&#25844;&#22686;&#36557;&#20633;]</span><span class="c5">&nbsp;&#23565;&#26044;&#19968;&#33324;&#36557;&#20633;&#21450;&#27494;&#22120;&#35037;&#20633;'
    expect ItemSplitter(input) .toEqual do
      content  : '<span class="c5"></span><span class="c5">&nbsp;&#23565;&#26044;&#19968;&#33324;&#36557;&#20633;&#21450;&#27494;&#22120;&#35037;&#20633;'
      ref       : ''
      labels: ['擴增軍備']

    # HTMl tags should not get into labels
    #
    input = '<span>[</span><span class="c32">111B: Diluted Taiwan Independence</span><span>] &#24076;&#26395;'
    expect ItemSplitter(input) .toEqual do
      content : '<span>&#24076;&#26395;'
      ref: ''
      labels: ['111B: Diluted Taiwan Independence']

describe \TableParser (...) !->

  it 'should be a function', inject (TableParser) !->
    expect(typeof TableParser).toBe 'function'

  it 'should return valid object, given a string without reference', inject (TableParser) !->
    expect TableParser('arbitary string') .toEqual do
      position-title : []
      perspectives   : []
      comments       : {}

  it 'should parse as many positions, perspectives and arguments as needed', inject (TableParser) !->
    expect-from-fixture TableParser, 'table-parser-positions'

  it 'should through out all strange tags on title and perspective title', inject (TableParser) !->
    expect-from-fixture TableParser, 'table-parser-tags'

  # (Trivial)
  # it 'should parse as many perspectives as needed', inject (TableParser) !->

  # (Trivial)
  # it 'should parse as many arguments as needed', inject (TableParser) !->

  it 'should parse summary', inject (TableParser) !->
    expect-from-fixture TableParser, 'table-parser-summary'

  it 'should use labels when LABEL_SUMMARY is set', inject (TableParser) !->
    expect-from-fixture TableParser, 'table-parser-label-summary', {label-count-to-use: 2}


describe \CommentParser (...) !->

  it 'should be a function', inject (CommentParser) !->
    expect(typeof CommentParser).toBe 'function'

  it 'should return a object, given a string', inject (CommentParser) !->
    expect(typeof CommentParser('arbitary string')).toBe 'object'

  it 'strips <span>s, add links to URLs and process types', inject (CommentParser) !->
    expect-from-fixture CommentParser, 'comment-parser-single'

  it 'parses multiple comments correctly', inject (CommentParser) !->
    expect-from-fixture CommentParser, 'comment-parser-multiple'

describe \StyleData (...) !->
  it 'extracts styles of interest', inject (StyleData) !->
    expect-from-fixture StyleData.$parse, 'style-parser-extract'