class window.EvidenceBottomView extends Backbone.Marionette.Layout
  className: 'evidence-bottom bottom-base'

  template: 'facts/bottom_base'

  regions:
    subCommentsRegion: '.js-region-sub-comments'

  events:
    'click .js-sub-comments-link': 'toggleSubCommentsList'

  templateHelpers: ->
    showTime: false
    showRepost: false
    showShare: false
    showSubComments: true
    showFactInfo: ->
      @fact_base.scroll_to_link?
    fact_url_host: ->
      new Backbone.Factlink.Url(@fact_url).host() if @fact_url?
    
  onRender: ->
    @bindTo @model, 'change:sub_comments_count', @updateSubCommentsLink, @
    @updateSubCommentsLink()

  toggleSubCommentsList: ->
    if @listOpen
      @listOpen = false
      @subCommentsRegion.close()
    else
      @listOpen = true
      @subCommentsRegion.show new SubCommentsListView
        collection: new SubComments([], parentModel: @model)

  updateSubCommentsLink: ->
    count = @model.get('sub_comments_count')

    count_str = ""

    if count
      count_str = " (#{count})"

    @$(".js-sub-comments-link").text "Comments#{count_str}"
