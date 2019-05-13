Identity::Freshdesk::Engine.routes.draw do
  post 'webhook', to: 'freshdesk#webhook'
end
