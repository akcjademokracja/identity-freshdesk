module Identity
  module Freshdesk
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
