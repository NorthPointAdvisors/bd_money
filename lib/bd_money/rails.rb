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

  # For better json decoding
  def as_json(options = nil)
    to_s
  end

end

module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module Money #:nodoc:
      def self.included(base) #:nodoc:
        base.extend ClassMethods
      end

      module ClassMethods
        # Pass list of fields you want to use as Money. You can also pass a hash in the end to indicate your
        # preferences for :precision and :round_mode.
        def money(*names)
          options = names.extract_options!
          names.each do |name|
            if options[:precision]
              this_precision = options[:precision]
            else
              db_column      = columns.select { |x| x.name == name.to_s }.first
              this_precision = (db_column && db_column.respond_to?(:scale)) ? db_column.scale : nil
            end
            define_method "#{name}=" do |value|
              if value.present?
                self[name] = ::Money.new(value, this_precision, options[:round_mode], options[:format]).round.amount
              else
                self[name] = nil
              end
            end
            define_method "#{name}" do
              return nil unless self[name].present?
              ::Money.new self[name], this_precision, options[:round_mode], options[:format]
            end
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, ActiveRecord::Acts::Money
