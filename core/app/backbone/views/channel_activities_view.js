//= require jquery.hoverIntent
//= require ./channel_view

window.ChannelActivitiesView = Backbone.View.extend({
  tagName: "div",

  template: "channels/_channel",

  initialize: function(opts) {
    this.activitiesView = new ActivitiesView({
      el: '#activity_for_channel',
      collection: new ChannelActivities([],{
        channel: this.model
      })
    });
    this.activitiesView.collection.loadMore();
    this.initSubChannels()
  },

  initAddToChannel: function() {
    if ( this.$el.find('#add-to-channel') && typeof currentUser !== "undefined" ) {
      this.addToChannelView = new AddToChannelView({
        collection: currentUser.channels,
        el: this.$el.find('#follow-channel'),
        model: currentChannel,
        containingChannels: currentChannel.getOwnContainingChannels()
      }).render();
    }
  },

  initMoreButton: function() {
    var containedChannels = this.$el.find('#contained-channels');
    if  ( containedChannels ) {
      this.$el.find('#more-button').bind('click', function() {
        var button = $(this).find(".label");
        containedChannels.find('.overflow').slideToggle(function(e) {
          button.text($(button).text() === 'more' ? 'less' : 'more');
        });
      });
    }
  },

  initSubChannelMenu: function() {
    if( this.model.get("followable?") ) {
      var addToChannelButton = this.$el.find("#add-to-channel");
      var followChannelMenu =this.$el.find("#follow-channel");

      followChannelMenu.css({"left": addToChannelButton.position().left});

      addToChannelButton.hoverIntent(
        function() { followChannelMenu.fadeIn("fast"); },
        function() { followChannelMenu.delay(600).fadeOut("fast"); }
      );

      followChannelMenu.on("mouseover", function() {
        followChannelMenu.stop(true, true).show();
      });

      followChannelMenu.on("mouseout", function() {
       if (!followChannelMenu.find("input#channel_title").is(":focus")) {
          followChannelMenu.delay(500).fadeOut("fast");
        }
      });
    }
  },

  remove: function() {
    if ( this.activitiesView ) {
      this.activitiesView.close();
    }

    if ( this.addToChannelView ) {
      this.addToChannelView.close();
    }

    if ( this.subchannelView ) {
      this.subchannelView.close();
    }
    Backbone.View.prototype.remove.apply(this);
  },

  render: function() {
    var self = this;

    if ( self.model ) {
      self.model.trigger('loading');

      this.$el
        .html( this.templateRender(this.model.toJSON()) );

      this.renderSubChannels();
      this.initSubChannelMenu();
      this.initAddToChannel();
      this.initMoreButton();

      this.activitiesView.$el = this.$el.find('#activity_for_channel');
      this.activitiesView.render();

      // Set the active tab
      var tabs = this.$el.find('.tabs ul');
      tabs.find('li').removeClass('active');
      tabs.find('.activity').addClass('active');

      self.model.trigger('loaded')
                  .trigger('activate', self.model);
    }

    return this;
  }
});

_.extend(ChannelActivitiesView.prototype, TemplateMixin, CommonChannelStuff);