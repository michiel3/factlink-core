(function(){
var ViewWithPopover = extendWithPopover( Backbone.Factlink.PlainView );

window.FactView = ViewWithPopover.extend({
  tagName: "div",

  className: "fact-block",

  events: {
    "click .hide-from-channel": "removeFactFromChannel",
    "click li.delete": "destroyFact",

    "click .tab-control .supporting"     : "tabClick",
    "click .tab-control .weakening"      : "tabClick",
    "click .tab-control .add-to-channel" : "tabClick",

    "click .title.edit": "toggleTitleEdit",
    "focus .title.edit>input": "focusTitleEdit",
    "blur .title.edit>input": "blurTitleEdit",
    "keydown .title.edit>input": "parseKeyInputTitleEdit",
    "click a.more": "showCompleteDisplaystring",
    "click a.less": "hideCompleteDisplaystring"
  },

  template: "facts/_fact",

  partials: {
    fact_bubble: "facts/_fact_bubble",
    fact_wheel: "facts/_fact_wheel",
    interacting_users: "facts/_interacting_users"
  },

  interactingUserViews: [],

  popover: [
    {
      selector: ".top-right-arrow",
      popoverSelector: "ul.top-right"
    }
  ],

  initialize: function(opts) {
    this._currentTab = undefined;
    this.interactingUserViews = [];

    this.model.bind('destroy', this.close, this);
    this.model.bind('change', this.render, this);

    this.initAddToChannel();
    this.initFactRelationsViews();
    this.initUserPassportViews();

    this.wheel = new Wheel(this.model.getFactWheel());
  },

  onRender: function() {
    this.renderAddToChannel();
    this.initFactRelationsViews();
    this.renderUserPassportViews();

    this.$('.authority').tooltip();

    if ( this.factWheelView ) {
      this.wheel.set(this.model.getFactWheel());
      this.$('.wheel').replaceWith(this.factWheelView.reRender().el);
    } else {
      this.factWheelView = new InteractiveWheelView({
        model: this.wheel,
        fact: this.model,
        el: this.$('.wheel')
      }).render();
    }
  },

  remove: function() {
    this.$el.fadeOut('fast', function() {
      $(this).remove();
    });

    _.each(this.interactingUserViews, function(view){
      view.close();
    },this);

    if(this.addToChannelView){
      this.addToChannelView.close();
    }
    // Hides the popup (if necessary)
    if ( parent.remote ) {
      parent.remote.hide();
      parent.remote.stopHighlightingFactlink(this.model.id);
    }
  },

  removeFactFromChannel: function(e) {
    e.preventDefault();

    var self = this;

    this.model.removeFromChannel(
      currentChannel, {
      error: function() {
        alert("Error while removing Factlink from Channel" );
      },
      success: function() {
        self.model.collection.remove(self.model);
        mp_track("Channel: Silence Factlink from Channel", {
          factlink_id: self.model.id,
          channel_id: currentChannel.id
        });
      }
    });
  },

  destroyFact: function(e) {
    e.preventDefault();

    this.model.destroy({
      error: function() {
        alert("Error while removing the Factlink" );
      },
      success: function() {
        mp_track("Factlink: Destroy");
      }
    });
  },

  initAddToChannel: function() {
  },

  renderAddToChannel: function() {
    var self = this;
    var add_el = '.tab-content .add-to-channel .dropdown-container .wrapper .add-to-channel-container';
    if ( this.$(add_el).length > 0 && typeof currentUser !== "undefined" ) {
      var addToChannelView = new AutoCompletedAddToChannelView({
        el: this.$(add_el)[0]
      });
      _.each(this.model.getOwnContainingChannels(),function(ch){
        //hacky hacky bang bang
        if (ch.get('type') === 'channel'){
          addToChannelView.collection.add(ch);
        }
      });
      addToChannelView.vent.bindTo("addChannel", function(channel){
        self.model.addToChannel(channel,{});
      });
      addToChannelView.vent.bindTo("removeChannel", function(channel){
        self.model.removeFromChannel(channel,{});
        if (window.currentChannel && currentChannel.get('id') === channel.get('id')){
          self.model.collection.remove(self.model);
        }
      });
      addToChannelView.render();
      this.addToChannelView = addToChannelView;
    }
  },

  initFactRelationsViews: function() {
    var supportingFactRelations = new SupportingFactRelations([], { fact: this.model } );
    var weakeningFactRelations = new WeakeningFactRelations([], { fact: this.model } );

    this.supportingFactRelationsView = new FactRelationsView({
      collection: supportingFactRelations,
      type: "supporting"
    });

    this.weakeningFactRelationsView = new FactRelationsView({
      collection: weakeningFactRelations,
      type: "weakening"
    });

   $('.supporting .dropdown-container', this.el)
   .append( this.supportingFactRelationsView.render().el );

   $('.weakening .dropdown-container', this.el)
   .append( this.weakeningFactRelationsView.render().el );
  },

  switchToRelationDropdown: function(type){
    mp_track("Factlink: Open tab", {factlink_id: this.model.id,type: type});

    if (type === "supporting") {
      this.weakeningFactRelationsView.hide();
      this.supportingFactRelationsView.showAndFetch();
    } else {
      this.supportingFactRelationsView.hide();
      this.weakeningFactRelationsView.showAndFetch();
    }
  },

  tabClick: function(e) {

    e.preventDefault();
    e.stopPropagation();

    var $target = $(e.target).closest('li');

    // Need a way to identify the clicked tab. Using the li class sucks monkeyballs.
    tab = $target.attr('class').split(' ')[0];

    // Remove .active
    var $tabButtons = this.$el.find('.tab-control li');
    $tabButtons.removeClass("active");

    if (tab !== this._currentTab) {
      // Open the clicked tab
      this._currentTab = tab;
      this.hideTabs();

      $target.addClass('active');
      // Show the tab
      this.$('.tab-content > .' + tab).show();
      // Keep showing the tabs (in the li)
      this.$('.tab-control > li').addClass('tabOpened');
      this.handleTabActions(tab);

    } else {
      // Same tab was clicked - hide it!
      this.hideTabs();
      this._currentTab = undefined;
    }
  },

  hideTabs: function() {
    this.$('.tab-content > div').hide();
    this.$('.tab-control > li').removeClass('tabOpened');
  },

  handleTabActions: function(tab) {
    switch (tab) {
    case "supporting":
    case "weakening":
      this.switchToRelationDropdown(tab);
      return true;

    case "channels":
      return true;

    default:
      return true;
    }
  },

  initUserPassportViews: function() {

  },

  renderUserPassportViews: function(){
    var interacting_users = this.model.get('interacting_users');

    _.each(interacting_users.activity, function (user) {
      var el = this.$('li.user[data-activity-id=' + user.id + ']');
      var model = new User(user.user);

      var view = new UserPassportView({
        model: model,
        el: el,
        activity: user
      });
      view.render();
    }, this);
  },

  highlight: function() {
    var self = this;
    self.$el.animate({"background-color": "#ffffe1"}, {duration: 2000, complete: function() {
      $(this).animate({"background-color": "#ffffff"}, 2000);
    }});
  },

  toggleTitleEdit: function () {
    var $editField = this.$el.find('.edit.title');

    if ( ! this._titleFieldHasFocus ) {
      $editField.toggleClass('edit-active');

      if ( $editField.hasClass('edit-active') ) {
        $editField.find('input').focus();
      }
    }
  },

  focusTitleEdit: function () {
    this._titleFieldHasFocus = true;
  },

  saveTitleEdit: function () {
    if ( this._titleFieldHasFocus ) {
      var self = this;
      var $titleField = this.$el.find('.edit.title');
      var value = $titleField.find('>input').val();

      $titleField.find('>span').html(value);
      $titleField.removeClass('edit-active');

      this._titleFieldHasFocus = false;

      if ( this.model.getTitle() === value ) {
        return;
      }

      // TODO: Please replace this with a proper Backbone.Model.prototype.save
      //       Once we got rid of Mustache
      if ( this.model.setTitle(value, { silent: true } ) ) {
        $.ajax({
          type: "PUT",
          url: this.model.url(),
          data: {
            title: value
          }
        }).done(function() {
          self.model.trigger('change');
        }).error(function() {
          alert("Something went wrong while trying to save this Factlink. Please try again");
        });
      }
    }
  },

  blurTitleEdit: function (e) {
    var $titleField = this.$el.find('.edit.title');
    var value = $titleField.find('>input').val();

    // Check if user has changes and wants to save
    if ( this.model.getTitle() !== value ) {
      if ( confirm("Do you want to save your changes?") ) {
        this.saveTitleEdit();
      } else {
        this.cancelTitleEdit();
      }
    }
  },

  cancelTitleEdit: function () {
    var $titleField = this.$el.find('.edit.title');
    var value = $titleField.find('>input').val();

    $titleField.find('>input').val( this.model.getTitle() );

    $titleField.removeClass('edit-active');
    this._titleFieldHasFocus = false;
  },

  parseKeyInputTitleEdit: function (e) {
    if ( e.keyCode === 13 ) {
      this.saveTitleEdit();

      e.preventDefault();
    } else if ( e.keyCode === 27 ) {
      this.cancelTitleEdit();

      e.preventDefault();
    }
  },

  showCompleteDisplaystring: function (e) {
    this.$('.normal').hide().siblings('.full').show();
  },

  hideCompleteDisplaystring: function (e) {
    this.$('.full').hide().siblings('.normal').show();
  }
});
})();
