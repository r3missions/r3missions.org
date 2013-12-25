$('.home-parallax, .parallax').click (e) ->
  e.preventDefault()

  $bg = findBgElem(this)
  currentBg = $bg.css('background-image').slice(4, -1)
  newBg = prompt("Enter the url of the image you want to change this background to:", currentBg)

  if newBg and newBg != currentBg
    $bg.css('background-image', "url(#{newBg})")

.on 'dragover', (e) ->
  e.stopPropagation()
  e.preventDefault()
  e.originalEvent.dataTransfer.dropEffect = 'copy'

.on 'drop', (e) ->
  e.stopPropagation()
  e.preventDefault()

  file = e.originalEvent.dataTransfer.files[0]

  return unless file.type.match(/^image\//)

  $bg = findBgElem(this)

  reader = new FileReader()
  reader.onload = (e) ->
    $bg.css('background-image', "url(#{e.target.result})")

  reader.readAsDataURL(file)

findBgElem = (el) ->
  $el = $(el)
  $bg = $el.find('.parallax-bg')
  if $bg.length == 0 then $el else $bg
