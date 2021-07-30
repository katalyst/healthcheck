# frozen_string_literal: true

Rails.application.routes.draw do
  get "/healthcheck", to: Katalyst::Healthcheck::Route.static(200, "OK")
  get "/healthcheck/tasks", to: Katalyst::Healthcheck::Route.from_tasks
  get "/healthcheck/task_details", to: Katalyst::Healthcheck::Route.from_tasks(detail: true)

  root to: "homepages#show"
end
