Rails.application.routes.draw do
  mount Identity::Freshdesk::Engine => "/identity-freshdesk"
end
