class Slack
  def self.members
    hash = Slack.query('https://slack.com/api/users.list', { :token => ENV["SLACK_API_TOKEN"] })
    hash["members"]
  end

  private

  def self.query(url, params = {})
    uri = URI(url)
    uri.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(uri)
    JSON.parse(res.body) rescue {}
  end
end
