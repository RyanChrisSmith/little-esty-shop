require 'rails_helper'

RSpec.describe GithubDetails do
  it 'can fetch repo name from Github' do
    expect(GithubDetails.fetch).to include(repo_name: "my repo!!")
  end
end
