$('#contact-form form').attr('action', "http://#{API_HOST}/contact_request")

flash = (type, message) ->
  """
    <div class="alert-message #{type}">
      #{message}
      <span class="close" href="#">x</span>
    </div>
  """

qs = {}
for keyAndValue in document.location.search.substr(1).split('&')
  [_, key, value] = keyAndValue.match(/([^=]*)(?:=(.*))?/)
  qs[decodeURIComponent(key)] = decodeURIComponent(value)

$box = $('.contact-box')
if qs.contact_success
  $box.prepend(flash('success', qs.contact_success))
else if qs.contact_error
  $box.prepend(flash('error', qs.contact_error))
