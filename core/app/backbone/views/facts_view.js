//= require './empty_facts_view'

window.FactsView = AutoloadingCompositeView.extend({
  tagName: "div",
  className: "facts",
  containerSelector: ".facts",
  itemView: FactView,
  events: {
    "submit #create_fact_for_channel": "createFact",
    "focus #create_fact_for_channel textarea": "openCreateFactForm",
    "click #create_fact_for_channel .create_factlink .close": "closeCreateFactForm",
    "click #create_fact_for_channel": "focusCreateFactlink",
    "click #create_fact_for_channel .inset-icon.icon-pen": "toggleTitleField",
    "click #create_fact_for_channel .input-box": "focusField"
  },

  template: "channels/_facts",

  initialize: function(options) {
    this.views = {};

    this.addShowHideToggle('loadingIndicator', 'div.loading');

    this.collection.on('startLoading', this.loadingIndicatorOn, this);
    this.collection.on('stopLoading', this.loadingIndicatorOff, this);

    this.model.on('change', this.shownewposts, this)
  },

  shownewposts: function(){
    var unread_count = parseInt(this.model.get('unread_count'),10);
    this.$('.more_facts .unread_count').html(unread_count);
    this.$('.more_facts').toggle(unread_count > 0);
  },

  emptyViewOn: function() {
    this.emptyView = new EmptyFactsView({model:this.model});
    this.$('div.no_facts').html(this.emptyView.render().el);
  },

  emptyViewOff: function() {
    this.emptyView.close();
    delete this.emptyView;
  },

  createFact: function (e) {
    var self = this;
    var $form = this.$('form');

    var $textarea = $form.find('textarea[name=fact]');
    var $title = $form.find('input[name=title]');
    var $submit = $form.find('button');

    e.preventDefault();

    $form.find(':input').prop('disabled', true);

    $.ajax({
      url: this.collection.url(),
      type: "POST",
      data: {
        displaystring: $textarea.val(),
        title: $title.val()
      },
      success: function(data) {
        var fact = new Fact(data);

        self.collection.unshift(fact);

        // HACK this is how backbone marionette stores childviews:
        // dependent on their implementation though
        self.children[fact.cid].highlight();
        self.setCreateFactFormToInitialState();
      },
      error: function(data) {
        alert("Error while adding Factlink to Channel" );
        self.setCreateFactFormToInitialState();
      }
    });
  },

  setCreateFactFormToInitialState: function(){
    this.$('form').find(':input').val('').prop('disabled',false);
    this.closeCreateFactForm();
  },

  focusField: function (e) {
    $(e.target).closest('input-box').find(':input').focus();
  },

  openCreateFactForm: function () {  this.$('form').addClass('active'); },

  closeCreateFactForm: function (e) {
    this.$('form')
      .removeClass('active show-title')
      .filter(':input').val('');

    e && e.stopPropagation();
  },

  toggleTitleField: function (e) {
    var $form = this.$('form');

    $form.toggleClass('show-title');

    $form.hasClass('show-title') && $form.addClass('active').find('.add-title>input').focus();

    e.stopPropagation();
  },

  focusCreateFactlink: function (e) {
    var $target = $(e.target);

    ! $target.is(':input') && $(e.target).closest('form').find('textarea').focus();
  }

});

_.extend(window.FactsView.prototype, ToggleMixin);