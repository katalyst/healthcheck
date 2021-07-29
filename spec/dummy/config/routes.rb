Rails.application.routes.draw do
  mount Katalyst::Healthcheck::Engine => "/katalyst-healthcheck"
end
