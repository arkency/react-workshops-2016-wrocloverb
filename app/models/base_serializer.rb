class BaseSerializer
  def serialize_relationship(name, collection)
    collection.map do |rel|
      { id: rel.id, type: name }
    end
  end
end