Rails.application.routes.draw do
  mount Katalyst::Healthcheck::Engine => "/healthcheck"

  root to: "homepages#show"
end
