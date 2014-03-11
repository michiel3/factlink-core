module Backend
  module Facts
    extend self

    def votes(fact_id:)
      votes_for(fact_id, 'believes') + votes_for(fact_id, 'disbelieves')
    end

    def create(displaystring:, title:, url:)
      fact_data = FactData.new
      fact_data.displaystring = displaystring
      fact_data.title = title
      fact_data.save
      fact_data

      fail "Errors when saving fact.data" unless fact_data.persisted?

      site = Site.find_or_create_by url: url

      fact = Fact.new site: site
      fact.data = fact_data
      fact.save
      fact.data.fact_id = fact.id
      fact.data.save

      fail "Errors when saving fact: #{fact.errors.inspect}" if fact.errors.length > 0

      fact
    end

    private

    def votes_for(fact_id, type)
      graph_user_ids = believable(fact_id).opiniated(type).ids
      dead_users = Pavlov.query :dead_users_by_ids, user_ids: graph_user_ids, by: :graph_user_id

      dead_users.map do |user|
        { username: user.username, user: user, type: type }
      end
    end

    def believable(fact_id)
      Believable.new Nest.new("Fact:#{fact_id}")
    end
  end
end
