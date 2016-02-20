$ ->
  if ('#omniauth_facebook').length
    $('#omniauth_facebook').on 'click', (e) ->
      e.preventDefault()
      $link = $(@)
      vex.dialog.confirm
        message: "<h3>#{$link.data('vex-title')}</h3> #{$link.data('vex-message')}"
        callback: (value) ->
          window.location.href = $link.attr 'href' if value is true
