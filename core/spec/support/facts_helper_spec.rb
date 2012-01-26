module BeliefExpressions
  def b(user,fact)
    something_happened
    fact.add_opinion(:believes,user.graph_user)
  end

  def d(user,fact)
    something_happened
    fact.add_opinion(:disbelieves,user.graph_user)
  end

  def u(user,fact)
    something_happened
    fact.add_opinion(:doubts,user.graph_user)
  end

  def _(b,d,u,a)
    Opinion.new(b:b,d:d,u:u,a:a)
  end

  def possible_reset
    unless @nothing_happened
      FactGraph.reset_values
      FactGraph.recalculate
      @nothing_happened = true
    end
  end

  def something_happened
    @nothing_happened = false
  end

  def a(user)
    @nothing_happened = false
    possible_reset
    Authority.from(GraphUser[user.graph_user.id]).to_f.should
  end

  def opinion?(fact)
    possible_reset
    # values are recalculated in Redis, so get the object fresh from Redis
    fact = fact.class[fact.id]
    fact.get_opinion.should
  end
end
