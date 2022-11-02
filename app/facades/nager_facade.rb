class NagerFacade
  def self.holidays
    parsed = NagerService.get_holidays
    parsed[0..2].map do |data|
      Holiday.new(data)
    end
  end
end