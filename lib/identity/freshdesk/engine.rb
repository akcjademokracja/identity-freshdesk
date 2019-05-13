module Identity
  module Freshdesk
    class Engine < ::Rails::Engine
      isolate_namespace Identity::Freshdesk
    end
  end
end
