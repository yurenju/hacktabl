she = it

describe \service !->
  beforeEach module('app.service')

  describe \MockData !->
    she 'should return object asynchronously', inject (MockData) !->
      MockData.then (data) !->
        expect data.perspectives .toBeDefined!

  describe \ArgumentParser !->
    she 'should be a function', inject (ArgumentParser) !->
      expect(typeof ArgumentParser).toBe 'function'

    she 'should return a string, given a string', inject (ArgumentParser) !->
      expect(typeof ArgumentParser('arbitary string')).toBe 'string'

    she 'should strip useless <span>s', inject (ArgumentParser) !->
      input    = '<span class="c14">示範區面對的「外國」，依國內法制，不包含中國。示範區對中國大陸另有限制。</span>'
      expected = '示範區面對的「外國」，依國內法制，不包含中國。示範區對中國大陸另有限制。'

      expect ArgumentParser(input) .toEqual expected

    she 'should parse one comment', inject (ArgumentParser, $interpolate) !->
      input    = '<span class="c14">去年的法令修改與鬆綁，必須要自經區條例通過後才會生效</span><sup><a href="#cmnt6" name="cmnt_ref6">[f]</a></sup><span class="c14">，並且受立法院監看；若自經區沒過，那法規鬆綁就不會生效。</span>'
      comment  = ($interpolate ArgumentParser.COMMENT_TEMPLATE) do
        content: '去年的法令修改與鬆綁，必須要自經區條例通過後才會生效'
        id: '6'
      expected = "#{comment}，並且受立法院監看；若自經區沒過，那法規鬆綁就不會生效。"

      expect ArgumentParser(input) .toEqual expected

    she 'should parse comments and its replies', inject (ArgumentParser, $interpolate) !->
      input    = '<span class="c5">去年的法令修改與鬆綁，必須要自經區條例通過後才會生效</span><sup><a href="#cmnt6" name="cmnt_ref6">[f]</a></sup><sup><a href="#cmnt7" name="cmnt_ref7">[g]</a></sup><sup><a href="#cmnt8" name="cmnt_ref8">[h]</a></sup><span class="c5">，並且受立法院監看；若自經區沒過，那法規鬆綁就不會生效。</span>'
      comment  = ($interpolate ArgumentParser.COMMENT_TEMPLATE) do
        content: '去年的法令修改與鬆綁，必須要自經區條例通過後才會生效'
        id: '6,7,8'
      expected = "#{comment}，並且受立法院監看；若自經區沒過，那法規鬆綁就不會生效。"

      expect ArgumentParser(input) .toEqual expected


  describe \ItemSplitter !->
    she 'should be a function', inject (ItemSplitter) !->
      expect(typeof ItemSplitter).toBe 'function'

    she 'should return with argument & ref, given a string without reference', inject (ItemSplitter) !->

      expect ItemSplitter('arbitary string') .toEqual do
        argument : 'arbitary string'
        ref      : ''

    she 'should extract simple reference from <li> content', inject (ItemSplitter) !->
      input      = '<span class="c5">國外對示範區內的實質投資免稅。</span><span class="c9">[來源 </span><span class="c9 c18"><a class="c3" href="AAAA">自經區草案§31</a></span><span class="c21 c9">]</span>'

      expect ItemSplitter(input) .toEqual do
        argument : '<span class="c5">國外對示範區內的實質投資免稅。</span>'
        ref      : '<a href="AAAA">自經區草案§31</a>'

    she 'should extract reference with multiple <a>', inject (ItemSplitter) !->
      input       = '<span class="c5">公有不動產（如政府土地）可以逕行讓售，不受</span><span class="c5">民意機關同意與行政院核准</span><sup><a href="#cmnt11" name="cmnt_ref11">[k]</a></sup><span class="c5">，公有地可不經民意監督私相讓售。</span><span class="c9">[來源 </span><span class="c9 c18"><a class="c3" href="BBBB">沃草自經爭議書</a></span><span class="c9">、</span><span class="c9 c18"><a class="c3" href="AAAA">自經區草案 §19</a></span><span class="c9 c21">]</span>'

      expect ItemSplitter(input) .toEqual do
        argument  : '<span class="c5">公有不動產（如政府土地）可以逕行讓售，不受</span><span class="c5">民意機關同意與行政院核准</span><sup><a href="#cmnt11" name="cmnt_ref11">[k]</a></sup><span class="c5">，公有地可不經民意監督私相讓售。</span>'
        ref       : '<a href="BBBB">沃草自經爭議書</a>、<a href="AAAA">自經區草案 §19</a>'