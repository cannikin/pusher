class WebPushService

  class ServiceError < StandardError; end
  class MessageInvalid < ServiceError; end
  class SubscriptionNotFound < ServiceError; end
  class InvalidSubscription < ServiceError; end

  attr_reader :web_push_optin, :web_push_message, :errors

  def initialize(web_push_optin:, web_push_message:)
    @web_push_optin = web_push_optin
    @web_push_message = web_push_message
    @errors = nil
  end

  def send
    send!
  rescue ServiceError => e
    @errors = e
    false
  end

  def send!
    validate!
    Webpush.payload_send(payload)
    message
  rescue Webpush::InvalidSubscription => e
    raise InvalidSubscription, e.message
  end

  private

  def validate!
    raise MessageInvalid, web_push_message_errors unless web_push_message.valid?
    raise SubscriptionNotFound, 'WebPushOptin not found' unless web_push_optin.present?
  end

  def payload
    subscription_attributes.merge(:message => JSON.dump(message),
      :vapid => vapid_details)
  end

  def subscription_attributes
    web_push_optin.attributes.slice('endpoint', 'p256dh', 'auth').symbolize_keys
  end

  private

  def message
    {
      :title => web_push_message.title,
      :body  => web_push_message.body,
      :icon  => web_push_message.icon,
      :tag   => web_push_optin.id,
      :data  => {
        :url => web_push_message.url
      }
    }
  end

  def web_push_message_errors
    "Message invalid: #{web_push_message.errors.full_messages.join(', ')}"
  end

  def vapid_details
    {
      :subject => ENV['VAPID_SUBJECT'],
      :public_key => ENV['VAPID_PUBLIC_KEY'],
      :private_key => ENV['VAPID_PRIVATE_KEY']
    }
  end

end
