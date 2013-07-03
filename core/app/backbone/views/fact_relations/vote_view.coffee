class FactRelationVoteView extends Backbone.Marionette.ItemView

  events:
    'click .btn-primary': 'save'

  set_fact_relation_opinion: (opinion) ->
    if opinion == 'none'
      if @model.get('current_user_opinion')
        @model.removeOpinion()
    else if @model.get('current_user_opinion') != opinion
      @model.setOpinion opinion

  set_fact_opinion: (opinion) ->
    # TODO should be able to unset the opinion from here as well.
    return if opinion == 'none'
    @model.getFact().getFactWheel().setActiveOpinionType opinion

class window.FactRelationVoteUpView extends FactRelationVoteView
  ui:
    fact_relation: '.js-fact-relation-believe'
    fact: '.js-fact-believe'

  template:
    text: '''
    <div style="width: 300px; padding: 15px;">
      <h5>Why do you believe this argument is supporting?</h5>

      <label><input type="checkbox" class="js-fact-relation-believe" {{#believes_fact_relation}}checked="checked"{{/believes_fact_relation}}>This argument is relevant to the upper Factlink</label>
      <label><input type="checkbox" class="js-fact-believe" {{#believes_fact}}checked="checked"{{/believes_fact}}>The Factlink in this argument is correct or true.</label>

      <a class="btn btn-primary pull-right">Done</a>
    </div>
    '''

  templateHelpers: =>
    believes_fact_relation: => @believes_fact_relation()
    believes_fact: => @believes_fact()

  save: ->
    opinion = if @ui.fact_relation.is(':checked')
                'believes'
              else
                'none'

    @set_fact_relation_opinion opinion

    believe = if @ui.fact.is(':checked')
                'believe'
              else
                'none'

    @set_fact_opinion believe

    @trigger 'saved'

  believes_fact_relation: -> @model.isBelieving()
  believes_fact: ->
    @model.getFact().get('fact_wheel').opinion_types.believe.is_user_opinion

class window.FactRelationVoteDownView extends FactRelationVoteView
  ui:
    fact_relation: '.js-fact-relation-disbelieve'
    fact: '.js-fact-disbelieve'

  template:
    text: '''
    <div style="width: 300px; padding: 15px;">
      <h5>Why do you believe this argument is not supporting?</h5>

      <label><input type="checkbox" class="js-fact-relation-disbelieve" {{#disbelieves_fact_relation}}checked="checked"{{/disbelieves_fact_relation}}>This argument is not relevant to the upper Factlink</label>
      <label><input type="checkbox" class="js-fact-disbelieve" {{#disbelieves_fact}}checked="checked"{{/disbelieves_fact}}>The Factlink in this argument is not correct or true.</label>

      <a class="btn btn-primary pull-right">Done</a>
    </div>
    '''

  templateHelpers: =>
    disbelieves_fact_relation: => @disbelieves_fact_relation()
    disbelieves_fact: => @disbelieves_fact()

  save: ->
    opinion = if @ui.fact_relation.is(':checked')
                'disbelieves'
              else
                'none'

    @set_fact_relation_opinion opinion

    @trigger 'saved'

    will_believe_fact = @ui.fact.is(':checked')
    # TODO: implement setting of the believe on the fact

  disbelieves_fact_relation: -> @model.isDisBelieving()
  disbelieves_fact: ->
    @model.getFact().get('fact_wheel').opinion_types.disbelieve.is_user_opinion
