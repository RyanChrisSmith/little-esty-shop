class ApplicationController < ActionController::Base
  before_action :fetch_github_details

  private

  def fetch_github_details
    @github_details = GithubDetails.fetch
  end
end
