class WebPushMessage

  include ActiveModel::Validations

  attr_accessor :title, :body, :icon, :url

  validates_each :title, :body do |record, attr, value|
    record.errors.add attr, 'is required' if value.blank?
  end

  def initialize(attributes={})
    @title = attributes[:title]
    @body = attributes[:body]
    @icon = attributes[:icon]
    @url = attributes[:url]
  end

end
