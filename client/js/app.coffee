# # MC Trevor Frontend
jQuery ($) ->
  # ## DOM
  $loading = $('#loading')
  $alerts = $('#alerts')

  $pages = $('#pages')
  $addPage = $('#pages-add')

  $form = $('#trevor')
  $pageFilename = $('#page-filename')
  $pageTitle = $('#page-title')
  $trevor = $('#trevor-instance')

  # Trevor instance
  trevor = {}

  ###
  # ## Current Page
  #
  # Data Structure:
  #
  # @example ```json
  # {
  #   url: String,
  #   data: {
  #     title: String,
  #     content: Array
  #   }
  # }
  # ```
  ###
  currentPage = {}

  # ## Helpers
  # ### Reset editor
  editor = ->
    # Destroy previous instance
    trevor.destroy?()
    $trevor.empty()

    $pageTitle.val currentPage.data.title
    $pageFilename.text currentPage.url
    # Let there be Trevor
    $trevor.val JSON.stringify data: currentPage.data.content
    trevor = new SirTrevor.Editor
      el: $trevor
    $form.removeClass 'hidden'

  # ### Add an alert
  showAlert = (content) ->
    newAlert = $ content
    setTimeout (-> newAlert.remove()), 2000
    $alerts.prepend newAlert

  # ### Load Pages
  loadPages = ->
    $.getJSON("/pages")
    .success (data) ->
      $pages.html data.pages.sort().map((page) ->
        "<a class='list-group-item' href='#' data-edit='#{page}'>#{page}</a>"
      ).join('')
      $loading.addClass 'hidden'

  # ## Select Page
  $pages.on 'click', 'a[data-edit]', (event) ->
    event.preventDefault()
    $pageLink = $(@)
    currentPage.url = $pageLink.data('edit')
    $pageLink.siblings().removeClass 'active'
    $pageLink.addClass 'active'

    $.getJSON("/pages#{currentPage.url}")
    .success (data) ->
      currentPage.data = data
      editor()
    .fail (err) ->
      window.alert(err)

  # ## Save Page
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
      showAlert "<div class='alert alert-success'>Saved <em>#{currentPage.url}</em></div>"
      if currentPage._new
        loadPages()
    .fail (err) ->
      console.error err
      showAlert "<div class='alert alert-danger'>Failed to save <em>#{currentPage.url}</em>!</div>"

  # ## Add Page
  $addPage.on 'submit', (event) ->
    event.preventDefault()
    filename = $('#pages-add-title').val()
    currentPage =
      _new: true
      url: filename
      data:
        title: ''
        content: []
    editor()

  # ## Init
  loadPages()

