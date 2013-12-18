class Channel < OurOhm
  attribute :title
  index :title

  attribute :lowercase_title

  attribute :slug_title
  index :slug_title

  def create
    result = super

    Topic.get_or_create_by_channel(self)

    result
  end

  alias :old_set_title :title= unless method_defined?(:old_set_title)
  def title=(new_title)
    old_set_title new_title
    self.lowercase_title = new_title.downcase
    self.slug_title = new_title.to_url
  end

  def save
    self.title = title
    super
  end

  reference :created_by, GraphUser
  index :created_by_id

  timestamped_set :sorted_internal_facts, Fact

  def delete
    Activity.for(self).each do |a|
      a.delete
    end
    super
  end

  def add_fact fact
    sorted_internal_facts.add(fact)
    fact.channels.add(self)
  end

  def remove_fact(fact)
    sorted_internal_facts.delete(fact)
    fact.channels.delete(self)
  end

  def include? obj
    sorted_internal_facts.include?(obj)
  end

  def validate
    assert_present :title
    assert_present :slug_title
    assert_present :created_by
    assert_unique([:slug_title,:created_by_id])
  end

  def topic
    Topic.get_or_create_by_channel self
  end
end
