$('.home-parallax, .parallax').click(function(e) {
  e.preventDefault();
  var $bgel = $(this).find('.parallax-bg');
  if ($bgel.length === 0) $bgel = $(this);

  var currentBg = $bgel.css('background-image').slice(4, -1),
      newBg = prompt("Enter the url of the image you want to change this background to:", currentBg);

  if (newBg !== currentBg) {
    $bgel.css('background-image', 'url(' + newBg + ')');
  }
});
