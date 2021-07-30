require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  subject { action && response }

  describe "GET /index" do
    let(:action) { get katalyst_healthcheck.tasks_path }

    context "when a task has FAIL status" do
      before do
        Katalyst::Healthcheck::Task.reset!

        travel_to 1.day.ago do
          Katalyst::Healthcheck.complete_task!(:failed_task, next_time: 1.hour.from_now)
        end
      end

      it { is_expected.to have_http_status(:internal_server_error) }
    end

    context "when all tasks have OK status" do
      before do
        Katalyst::Healthcheck::Task.reset!

        Katalyst::Healthcheck.complete_task!(:ok_task, next_time: 1.hour.from_now)
      end

      it { is_expected.to have_http_status(:ok) }
    end
  end
end
