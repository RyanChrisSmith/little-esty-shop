require 'httparty'

class NagerService
  def self.get_uri(uri)
    response = HTTParty.get(uri)
    JSON.parse(response.body, symbolize_names: true)
  end

  def self.get_holidays
    get_uri('https://date.nager.at/api/v3/NextPublicHolidays/US')
  end

end