return if window.FACTLINK_LOADED?
window.FACTLINK_LOADED = true

#### Create iframe

iframe = document.createElement('iframe')
iframe.style.display = 'block'
iframe.style.border = '0px solid transparent'
iframe.id = 'factlink-iframe'

# Wrappers for increased CSS specificity
div = document.createElement('div')
wrapper1 = document.createElement('div')
wrapper2 = document.createElement('div')
wrapper3 = document.createElement('div')

wrapper1.id = 'fl-wrapper-1'
wrapper2.id = 'fl-wrapper-2'
wrapper3.id = 'fl-wrapper-3'
div.id = 'fl'

wrapper1.appendChild wrapper2
wrapper2.appendChild wrapper3
wrapper3.appendChild div
document.body.appendChild wrapper1

div.insertBefore iframe, div.firstChild

#### Create <script> tag

coreScriptTag = document.createElement('script')

hashOfFactlinkCoreFile = '&*HASH_PLACE_HOLDER*&' # Overwritten by grunt task
if FactlinkConfig.srcPath.match(/\.min\.js$/)
  if hashOfFactlinkCoreFile is '&*HASH_PLACE_HOLDER*&'
    hashOfFactlinkCoreFile = ''
  else
    hashOfFactlinkCoreFile = '.' + hashOfFactlinkCoreFile
  coreScriptTag.src = FactlinkConfig.lib + '/factlink.core.min' + hashOfFactlinkCoreFile + '.js'
else
  coreScriptTag.src = FactlinkConfig.lib + FactlinkConfig.srcPath

coreScriptTag.onload = coreScriptTag.onreadystatechange = ->
  return false if coreScriptTag.readyState && coreScriptTag.readyState not in ['complete', 'loaded']

  coreScriptTag.onload = coreScriptTag.onreadystatechange = null

  window.FACTLINK = iframe.contentWindow.Factlink
  jQuery?(window).trigger 'factlink.libraryLoaded'

#### Load iframe with script tag

window.FACTLINK_ON_IFRAME_LOAD = ->
  iframe.contentWindow.document.head.appendChild coreScriptTag

iframeDoc = iframe.contentWindow.document
iframeDoc.open()
iframeDoc.write """
  <!DOCTYPE html><html><head>
    <script>
      window.FactlinkConfig = #{JSON.stringify(FactlinkConfig)};
      window.parent.FACTLINK_ON_IFRAME_LOAD();
    </script>
  </head><body></body></html>
"""
iframeDoc.close()
