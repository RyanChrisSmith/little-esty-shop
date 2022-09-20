class GithubDetails
  REPO_NAME = 'little-esty-shop'
  GITHUB_USER = 'RyanChrisSmith'

  def self.fetch
    contributors_response = HTTParty.get "https://api.github.com/repos/#{GITHUB_USER}/#{REPO_NAME}/contributors"
    {
      repo_name: REPO_NAME,
      repo_url: "https://github.com/#{GITHUB_USER}/#{REPO_NAME}",
      contributors: contributors_response.parsed_response.map { |user| user['login'] },
    }
  end
end
