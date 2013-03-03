module Mirage
  module Searchable
    class << self
      def included clazz
        class_name = clazz.to_s[/(\w+)$/,1]
        Mirage.define_singleton_method class_name.to_sym do |id|
          clazz.get("/#{id}")
        end
      end
    end
  end
end