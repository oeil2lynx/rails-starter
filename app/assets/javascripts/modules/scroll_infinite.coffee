$(document).on 'ready page:load page:restore', ->
  # Scroll infinite for articles or comments
  if $('.pagination').length
    $(window).on 'scroll', throttle(((e) ->
      url = $('.pagination .next a').attr('href')
      if url && $(window).scrollTop() > ($(document).height() - $(window).height() - 50)
        $('.pagination').text(I18n.t('scroll_infinite.fetch_nexts', { locale: gon.language }))
        $.getScript(url).done((script, textStatus) ->
          magnific_popup_init()
          $('.fotorama').fotorama()
          return
        )
      return
    ), 100)
    $(window).scroll()