
if !exists('*json_decode')
    finish
endif

function! s:apiGetter(key, option)
    if empty(g:ZFVimIM_openapi_http_exe)
        return ''
    endif
    let l:key = a:key
    if exists('g:ZFVimIM_xiaohe') && g:ZFVimIM_xiaohe > 0
      let l:key = xiaohe#line_to_pinyin(l:key)
    endif
    return g:ZFVimIM_openapi_http_exe . ' "http://olime.baidu.com/py?rn=0&pn=20&py=' . l:key . '"'
endfunction

" {"0":[[["我的",4,{"pinyin":"wo'de","type":"IMEDICT"}]]],"1":"wo'de","result":[null]}
function! s:outputParser(key, option, outputList)
    let output = join(a:outputList, '')
    let output = substitute(output, '[\r\n]', '', 'g')
    if empty(output)
        return []
    endif
    try
        let data = json_decode(output)
    catch
        return []
    endtry
    let dataArr = get(get(get(data, '0', []), 0, []), 0, [])
    let word = get(dataArr, 0, '')
    let key = substitute(get(get(dataArr, 2, {}), 'pinyin', ''), "'", '', 'g')
    if empty(key) || empty(word)
        return []
    endif
    return [{
                \   'priority' : 50,
                \   'len' : len(a:key),
                \   'key' : a:key,
                \   'word' : word,
                \   'type' : get(g:, 'ZFVimIM_openapi_word_type', 'sentence'),
                \ }]
endfunction

if !exists('g:ZFVimIM_openapi')
    let g:ZFVimIM_openapi = {}
endif
let g:ZFVimIM_openapi['baidu'] = {
            \   'apiGetter' : function('s:apiGetter'),
            \   'outputParser' : function('s:outputParser'),
            \ }

