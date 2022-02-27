module Spy
  # A Mock is an object that has all the same methods as the given class.
  # Each method however will raise a NeverHookedError if it hasn't been stubbed.
  # If you attempt to stub a method on the mock that doesn't exist on the
  # original class it will raise an error.
  module Mock
    include Base
    CLASSES_NOT_TO_OVERRIDE = [Enumerable, Numeric, Comparable, Class, Module, Object]
    METHODS_NOT_TO_OVERRIDE = [:initialize, :method]

    def initialize(&mock_method)
      Agency.instance.recruit(self)
    end

    # the only method that doesn't work correctly of a mock if inherited. We
    # overwite for compatibility.
    # @param other [Class]
    # @return [Boolean]
    def instance_of?(other)
      other == self.class
    end

    # returns the original class method if the current method is a mock_method
    # @param method_name [Symbol, String]
    # @return [Method]
    def method(method_name)
      new_method = super
      parameters = new_method.parameters
      if parameters.size >= 1 && parameters.last.last == :mock_method
        self.class.instance_method(method_name).bind(self)
      else
        new_method
      end
    end

    class << self
      # This will create a new Mock class with all the instance methods of given
      # klass mocked out.
      # @param klass [Class]
      # @return [Class]
      def new(klass)
        mock_klass = Class.new(klass)
        mock_klass.class_exec do
          alias :_mock_class :class
          private :_mock_class

          define_method(:class) do
            klass
          end

          include Mock
        end
        mock_klass
      end

      private

      def included(mod)
        method_classes = classes_to_override_methods(mod)

        mocked_methods = []
        [:public, :protected, :private].each do |visibility|
          get_inherited_methods(method_classes, visibility).each do |method_name|
            mocked_methods << method_name
            args = args_for_method(mod.instance_method(method_name))

            mod.class_eval <<-DEF_METHOD, __FILE__, __LINE__ + 1
              def #{method_name}(#{args})
                raise ::Spy::NeverHookedError, "'#{method_name}' was never hooked on mock spy."
              end
            DEF_METHOD

            mod.send(visibility, method_name)
          end
        end

        mod.define_singleton_method(:mocked_methods) do
          mocked_methods
        end
      end

      def classes_to_override_methods(mod)
        method_classes = mod.ancestors
        method_classes.shift
        method_classes.delete(self)
        CLASSES_NOT_TO_OVERRIDE.each do |klass|
          index = method_classes.index(klass)
          method_classes.slice!(index..-1) if index
        end
        method_classes
      end

      def get_inherited_methods(klass_ancestors, visibility)
        instance_methods = klass_ancestors.map do |klass|
          klass.send("#{visibility}_instance_methods".to_sym, false)
        end
        instance_methods.flatten!
        instance_methods.uniq!
        instance_methods - METHODS_NOT_TO_OVERRIDE
      end

      def args_for_method(method)
        args = method.parameters
        args.map! do |type,name|
          name ||= :args
          case type
          when :req
            name
          when :opt
            "#{name} = nil"
          when :rest
            "*#{name}"
          end
        end
        args.compact!
        args << "&mock_method"
        args.join(",")
      end
    end
  end
end
