module FactsHelper
  include Canivete::Deprecate

  # Sorting results on search page
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"

    link_to title, {  :s => params[:s], 
                      :sort => column, 
                      :direction => direction
                    }, 
                    { :class => css_class }
  end

  # Popups
  def potential_childs_popup(potential_childs)
    render :partial => 'facts/client_popups/potential_childs', 
              :locals => { :potential_childs => potential_childs }
  end

  def potential_parents_popup(potential_parents)
    render :partial => 'facts/client_popups/potential_parents', 
              :locals => { :potential_parents => potential_parents }
  end


  # Listitem for in factlink client overview
  def factlink_source_partial_as_li(fact_relation)    
    render :partial => 'facts/partial/source_as_li', 
              :locals => { :fact_relation => fact_relation }
  end
  
  def evidence_as_li(fact, evidence)
    render :partial => 'facts/partial/add_evidence_as_li', 
              :locals => { :fact => fact, :evidence => evidence }
  end
  
  # Score block of the top factlink in client
  def factlink_score_partial(fact)
    render :partial => 'facts/partial/bar_chart', 
              :locals => { :fact => fact }
  end


  # The vote options for a fact: believe, doubt, disbelieve
  deprecate
  def opinion_options(fact)
    render :partial => 'facts/partial/opinion_options', 
              :locals => { :fact => fact }
  end


  # Shows opinion of user on this fact.
  # Links to toggle the opinion.
  def fact_opinion_options(fact_relation)
    render :partial => 'facts/partial/opinion_options',
              :locals => { :fact_relation => fact_relation }
  end

  # Shows the opinion on this FactRelation
  # Links to toggle the believe on the relation.
  def fact_relation_relevance_options(fact_relation)
    render :partial => 'facts/partial/relevance_options', 
              :locals => { :fact_relation => fact_relation }
  end
  
  def no_facts_have_been_added_as_li
    render :partial => 'facts/partial/no_facts_added_message'
  end
  
  def no_evidence_found_message_as_li
    render :partial => 'facts/partial/no_evidence_found_message'
  end
  
  # Percentage and brain cycles in <li>
  def fl_source_stats(fact_relation)
    render  :partial  => 'facts/partial/fl_source_stats',
            :locals   => { :fact_relation => fact_relation }
  end
  
  def fact_relation_interacting_users(fact_relation)
    render  :partial  => 'facts/partial/interacting_users',
            :locals   => { :fact_relation => fact_relation }
  end

  deprecate
  def relevance_class_on_fact(type, fact)
    current_user.active_class_for_type_and_fact(type, fact)
  end
  
  def active_class_for_type_and_fact(type, fact)
    if current_user.opinion_on_fact_for_type?(type, fact)
      return " class='active'"
    end
  end

  def channel_listing_for_fact(fact)
    render :partial => "facts/partial/channel_listing_for_fact",
              :locals => { :fact => fact }
  end


  def fact_listing(facts)
    render :partial => "home/snippets/fact_listing", 
                :locals => {  :facts => facts }
  end

  def fact_snippet(fact,channel=nil)
    render :partial => "home/snippets/fact/fact_container", 
	            :locals => {  :fact => fact, :channel => channel }
  end
  
  def fact_bubble(fact,add_to_fact=nil) 
    render :partial => "home/snippets/fact/fact_bubble", 
	            :locals => {  :fact => fact,
	                          :add_to_fact => add_to_fact }
  end

  def evidence_fact_bubble(evidence) 
    render :partial => "home/snippets/fact/fact_bubble", 
	            :locals => {  :fact => evidence.from_fact,
	                          :fact_relation => evidence }
  end
  
  def fact_interacting_users(opinions)
    render :partial => "home/snippets/fact/users_popup",
              :locals => {:opinion => opinions.to_a }
  end
  
  def fact_channel_listing(fact)
    render :partial => "home/snippets/fact/channel_listing",
              :locals => { :fact => fact }
  end
  
  def fact_add_evidence(fact)
    render :partial => "home/snippets/fact/add_evidence",
            :locals => { :fact => fact }
  end
  
  def fact_search
    render :partial => "home/snippets/fact_search"
  end

end