class FactGraph
  def self.recalculate
    new.recalculate
  end

  def debug x
    @logger ||= Logger.new(STDERR)
    @logger.info "#{Time.now} #{x}"
    $stdout.flush
  end

  def recalculate
      calculate_authority

      calculate_user_opinions_of_all_base_facts
      5.times do |i|
        calculate_fact_relation_influencing_opinions i

        calculate_fact_opinions i
      end
  end

  def calculate_fact_relation_influencing_opinions i
    debug "Calculating fact relation influencing opinions (#{i})"
    FactRelation.all.to_a.each {|f| f.calculate_influencing_opinion}
  end

  def calculate_fact_opinions i
    debug "Calculating fact opinions (#{i})"
    Fact.all.to_a.each do |f|
      f.calculate_opinion
    end
  end

  def calculate_user_opinions_of_all_base_facts
    debug "Calculating user opinions on basefacts"
    Basefact.all.to_a.each {|f| f.calculate_user_opinion }
  end

  def calculate_authority
    debug "Calculating Authority"
    Authority.run_calculation(authority_calculators)
  end

  def authority_calculators
    [
      MapReduce::FactAuthority,
      MapReduce::ChannelAuthority,
      MapReduce::TopicAuthority,
      MapReduce::FactCredibility,
      MapReduce::FactRelationCredibility
    ]
  end
end
