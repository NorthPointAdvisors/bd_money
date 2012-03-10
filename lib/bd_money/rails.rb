require File.expand_path(File.dirname(__FILE__) + '/../../lib/bd_money')

class Money

  # Terrible hack to allow to quote money correctly
  def quoted_id
    amount
  end

  # This will help to save money objects correctly
  def to_d
    amount
  end

end

module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module Money #:nodoc:
      def self.included(base) #:nodoc:
        base.extend ClassMethods
      end

      module ClassMethods
        def money(name, options = { })
          define_method "#{name}=" do |value|
            if value.present?
              self[name] = ::Money.new(value, options[:precision], options[:round_mode]).amount
            else
              self[name] = nil
            end
          end
          define_method "#{name}" do
            return nil unless self[name].present?
            ::Money.new self[name], options[:precision], options[:round_mode]
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, ActiveRecord::Acts::Money
