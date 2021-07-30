Katalyst::Healthcheck::Engine.routes.draw do

  # Rails health check
  get '/rails', to: Proc.new { |_env| [200, { "Content-Type" => "text/plain" }, ["OK"]] }

  # Background tasks health check
  resources :tasks, only: %i[index show]
end
