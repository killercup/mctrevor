jQuery ($) ->
  $loading = $('#loading')
  $pages = $('#pages')

  $form = $('#trevor')
  $pageTitle = $('#page-title')
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
      $pageTitle.val currentPage.data.title
      # Let there be Trevor
      $trevor.val JSON.stringify data: currentPage.data.content
      trevor = new SirTrevor.Editor
        el: $trevor
      $form.removeClass 'hidden'

  $form.on 'click', 'a.save', (event) ->
    event.preventDefault()
    return unless trevor? and currentPage.data?

    newContent = trevor.blocks.map (i) -> i.saveAndReturnData()

    currentPage.data.title = $pageTitle.val()
    currentPage.data.content = newContent

    $.ajax(
      type: 'POST'
      url: "/pages#{currentPage.url}"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify currentPage.data
    )
    .success (res) ->
      button = $form.find('.save').first()
      button.next('.label').remove()
      label = $ '<span class="label label-success label-big">Saved</span>'
      setTimeout (-> label.remove()), 2000
      button.after label
    .fail (err) ->
      console.error err

      button = $form.find('.save').first()
      button.next('.label').remove()
      label = $ '<span class="label label-error label-big">Failed!</span>'
      setTimeout (-> label.remove()), 2000
      button.after label

