require "administrate/field/base"

class MultipleSelectFieldField < Administrate::Field::Select
  def to_s
    Array.wrap(data).map(&:presence).compact.join ", "
  end

  def self.permitted_attribute(attribute, _options = nil)
    {attribute.to_sym => []}
  end

  def permitted_attribute
    self.class.permitted_attribute(attribute)
  end
end
