class PushController < ApplicationController

  skip_before_action :verify_authenticity_token

  rescue_from WebPushService::SubscriptionNotFound, with: :render_subscription_problem
  rescue_from WebPushService::InvalidSubscription,  with: :render_subscription_problem

  def create
    WebPushOptin.where(:endpoint => webpush_params[:endpoint])
      .first_or_create(webpush_params.except(:endpoint))
  end

  def destroy
    WebPushOptin.where(:endpoint => webpush_params[:endpoint]).destroy_all
  end

  def send_message
    output = WebPushService.new(web_push_optin: WebPushOptin.last, web_push_message: web_push_message).send!
    render :json => output
  end

  private

  def render_subscription_problem(exception)
    render :plain => exception.message
  end

  def webpush_params
    {
      :endpoint => params[:endpoint],
      :p256dh => params[:keys][:p256dh],
      :auth => params[:keys][:auth]
    }
  end

  def web_push_message
    WebPushMessage.new({
      :title => "Hello",
      :body  => "The time is #{Time.current}",
      :icon  => view_context.asset_path('push-icon.jpg')
    })
  end

end
