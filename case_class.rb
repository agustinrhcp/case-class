module CaseClass
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def case(variant_instance)
      Case.new(variant_instance, _variants)
    end

    def _variants
      @variants
    end

    def _add_variant(variant)
      if @variants
        @variants << variant
      else
        @variants = [variant]
      end
    end
  end
end

class CaseClass::Case
  def initialize(variant_instance, variants)
    @instance = variant_instance
    @variants = variants
    @variants_blocks = Hash[*variants.collect { |v| [ v.klass, nil ] }.flatten]
    @else_block = nil
  end

  def when(variant_klass, &block)
    variant_helper = @variants.find { |variant| variant.klass == variant_klass }

    fail "#{variant_klass} is not a subclass of " unless variant_helper

    @variants_blocks[variant_klass] = block

    if all_branches_exhausted?
      run
    else
      self
    end
  end

  def else(&block)
    @else_block = block
    run
  end

  def run
    variant_block = @variants_blocks[@instance.class]

    if variant_block
      variant_block.call(*variables_from_instance)
    else
      @else_block.call()
    end
  end

  private

  def all_branches_exhausted?
    @variants_blocks.all? { |_, block| !block.nil? }
  end

  def variables_from_instance
    @variants
      .find { |variant| variant.klass == @instance.class }
      .variables
      .map { |var| @instance.send(var) }
  end
end

module CaseClass
  module Variant
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def variant_of(klass, options = {})
        VariantHelper.new(self, options)
          .then { |variant| klass._add_variant(variant) }
      end
    end
  end

  class VariantHelper
    attr_reader :klass, :variables

    def initialize(klass, options = {})
      @klass = klass
      @variables = Array(options[:variables])
    end
  end
end
