window.UserPassportView = Backbone.View.extend({
  tagName: "li",
  className: "user",
  shouldShow: false,

  events: {
    "mouseenter": "show",
    "mouseleave": "hide"
  },

  tmpl: Template.use("users", "_user_passport"),

  initialize: function(opts) {
    this.$passport = $(".passport", this.el);

    this.model.bind("change", this.render, this);
  },

  render: function () {
    this.$passport.html( this.tmpl.render( this.model.toJSON() ) );

    $(".activity", this.$passport)
      .html( this.options.activity["internationalized_action"] )
      .addClass( this.options.activity["action"] );

    return this;
  },

  show: function() {
    this.shouldShow = true;

    this.$passport.fadeIn('fast');
  },

  hide: function() {
    this.shouldShow = false;

    _.delay( _.bind(function() {
      if ( ! this.shouldShow ) {
        this.$passport.fadeOut('fast');
      }
    }, this), 150);
  }
});
