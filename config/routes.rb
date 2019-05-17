Identity::Freshdesk::Engine.routes.draw do
  post 'webhook', action: :webhook, controller: 'freshdesk'
end
