Example

```ruby
require './case_class'

class Maybe
  include CaseClass
end

class Just
  include CaseClass::Variant

  variant_of Maybe, variables: :value

  attr_reader :value

  def initialize(value)
    @value = value
  end
end

class Nothing
  include CaseClass::Variant

  variant_of Maybe
end

Maybe
  .case(Just.new(1))
  .when(Just) { |value| puts "Just #{value}" }
  .when(Nothing) { puts "Nothing" }


Maybe
  .case(Nothing.new)
  .when(Just) { |value| "Just #{value}" }
  .else { puts "Nothing" }
```
