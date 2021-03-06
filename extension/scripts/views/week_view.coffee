class BH.Views.WeekView extends BH.Views.MainView
  @include BH.Modules.I18n

  template: BH.Templates['week']

  className: 'week_view with_controls'

  events:
    'click .delete_all': 'onDeleteAllClicked'
    'keyup .search': 'onSearchTyped'
    'blur .search': 'onSearchBlurred'
    'click .remove_filter': 'onRemoveSearchFilterClick'

  initialize: ->
    @collection.bind('reset', @onHistoryLoaded, @)

    # on view selection, the search filter should always be seen
    @on 'selected', =>
      setTimeout =>
        @$('.corner .tags').show()
        @$('.corner .search').data('filter', 'true')
      , 250
    , @

  render: ->
    presenter = new BH.Presenters.WeekPresenter(@model.toJSON())
    properties = _.extend @getI18nValues(), presenter.inflatedWeek()
    html = Mustache.to_html @template, properties
    @$el.html html
    @

  onHistoryLoaded: ->
    @renderHistory()

  onDeleteAllClicked: ->
    @promptToDeleteAllVisits()

  pageTitle: ->
    presenter = new BH.Presenters.WeekPresenter(@model.toJSON())
    presenter.inflatedWeek().title

  renderHistory: ->
    presenter = new BH.Presenters.WeekHistoryPresenter(@collection.toJSON())
    history = presenter.history()
    for day in history.days
      container = @$("[data-day=#{day.day}]")
      container.find(".label .count").html @t('number_of_visits', [day.count])
      container.find('.bar').css width: day.percentage

    @$('.controls .count').html @t('number_of_visits', [history.total])
    @assignTabIndices('.day a')
    @$el.addClass('loaded')

  promptToDeleteAllVisits: ->
    presenter = new BH.Presenters.WeekPresenter(@model.toJSON())
    promptMessage = @t('confirm_delete_all_visits', [presenter.inflatedWeek().title])
    @promptView = BH.Views.CreatePrompt(promptMessage)
    @promptView.open()
    @promptView.model.on('change', @promptAction, @)

  promptAction: (prompt) ->
    if prompt.get('action')
      analyticsTracker.weekVisitsDeletion()
      new BH.Lib.WeekHistory(@model.get('date')).destroy =>
        @promptView.close()
        window.location.reload()
    else
      @promptView.close()

  getI18nValues: ->
    @t [
      'delete_all_visits_for_filter_button',
      'no_visits_found',
      'search_input_placeholder_text'
    ]
