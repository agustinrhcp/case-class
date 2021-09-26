require './case_class'

class Result
  include CaseClass
end

class Ok
  include CaseClass::Variant

  variant_of Result, variables: :value

  attr_reader :value

  def initialize(value)
    @value = value
  end
end

class Err
  include CaseClass::Variant

  variant_of Result, variables: :error

  attr_reader :error

  def initialize(error)
    @error = error
  end
end

module List
  def self.get(list, index)
    if index < 0
      Err.new IndexCannotBeNegative
    elsif index > list.length
      Err.new IndexOutOfBound
    else
      Ok.new list[index]
    end
  end

  class GetError
    include CaseClass
  end

  class IndexCannotBeNegative
    include CaseClass::Variant

    variant_of GetError
  end

  class IndexOutOfBound
    include CaseClass::Variant

    variant_of GetError
  end
end

puts Result
  .case(List.get [1, 2, 3], 0)
  .when(Ok) { |value| puts "Ok #{value}" }
  .when(Err) { puts "Some error" }


puts Result
  .case(List.get [1, 2, 3], 3)
  .when(Ok) { |value| puts "Ok #{value}" }
  .when(Err, List::IndexOutOfBound) { puts "Err Out of bound" }
  .when(Err, List::IndexCannotBeNegative) { puts "IndexCannotBeNegative" }
