jQuery ($) ->
  $loading = $('#loading')
  $pages = $('#pages')
  $form = $('#trevor')
  $trevor = $('#trevor-instance')
  trevor = window.trevor = null

  currentPage = {}

  $.getJSON("/pages")
  .success (data) ->
    pages = data.pages
    $pages.append pages.map((page) ->
      "<a class='list-group-item' href='#' data-edit='#{page}'>#{page}</a>"
    ).join('')
    $loading.addClass 'hidden'

  $pages.on 'click', 'a[data-edit]', (event) ->
    event.preventDefault()
    $pageLink = $(@)
    currentPage.url = $pageLink.data('edit')
    $pageLink.siblings().removeClass 'active'
    $pageLink.addClass 'active'

    $.getJSON("/pages#{currentPage.url}")
    .success (data) ->
      currentPage.data = data
      # Let there be Trevor
      $trevor.val JSON.stringify data: data.content
      trevor = new SirTrevor.Editor
        el: $trevor
      $form.removeClass 'hidden'

  $form.on 'click', 'a.save', (event) ->
    event.preventDefault()
    return unless trevor? and currentPage.data?

    newContent = trevor.blocks.map (i) -> i.saveAndReturnData()
    console.log newContent

    currentPage.data.content = newContent

    $.ajax(
      type: 'POST'
      url: "/pages#{currentPage.url}"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify currentPage.data
    )
    .success (res) ->
      console.log res
      button = $form.find('.save').first()
      button.next('.label').remove()
      label = $ '<span class="label label-success label-big">Saved</span>'
      setTimeout (-> label.remove()), 2000
      button.after label
    .fail (err) ->
      console.error err

