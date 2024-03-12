# frozen_string_literal: true

module Solid::Model
  # Implementation based on ActiveModel::Access
  # https://github.com/rails/rails/blob/7-1-stable/activemodel/lib/active_model/access.rb
  module Access
    # Returns a hash of the given methods with their names as keys and returned
    # values as values.
    #
    #   person = Person.new(id: 1, name: "bob")
    #   person.slice(:id, :name)
    #   => { "id" => 1, "name" => "bob" }
    def slice(*methods)
      methods.flatten.index_with { |method| public_send(method) }.with_indifferent_access
    end

    # Returns an array of the values returned by the given methods.
    #
    #   person = Person.new(id: 1, name: "bob")
    #   person.values_at(:id, :name)
    #   => [1, "bob"]
    def values_at(*methods)
      methods.flatten.map! { |method| public_send(method) }
    end
  end
end
