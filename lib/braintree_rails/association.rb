module BraintreeRails
  module Association
    module ClassMethods
      def self.extended(receiver)
        receiver.singleton_class.send(:attr_accessor, :associations)
        receiver.associations = []
      end

      def inherited(subclass)
        subclass.associations = self.associations
      end

      def has_many(name, options)
        associations << name
        define_association_reader(name, options.merge(:foreign_key => :presence))
      end

      def belongs_to(name, options)
        associations << name
        define_association_reader(name, options)
        define_association_writer(name, options)
      end

      def has_one(name, options)
        belongs_to(name, options)
      end

      def define_association_reader(name, options)
        define_method(name) do
          if value = instance_variable_get("@#{name}")
            return value
          elsif options[:foreign_key] && value = send(options[:foreign_key])
            instance_variable_set("@#{name}", options[:class_name].constantize.new(value))
          end
        end
      end

      def define_association_writer(name, options)
        define_method("#{name}=") do |value|
          value &&= options[:class_name].constantize.new(value)
          instance_variable_set("@#{name}", value)
        end
      end
    end

    def self.included(receiver)
      receiver.extend ClassMethods
    end
  end
end
