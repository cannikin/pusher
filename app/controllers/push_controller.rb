class PushController < ApplicationController

  skip_before_action :verify_authenticity_token

  rescue_from WebPushService::SubscriptionNotFound, with: :render_subscription_problem
  rescue_from WebPushService::InvalidSubscription,  with: :render_subscription_problem

  def create
    if WebPushOptin.find_by(:endpoint => webpush_params[:endpoint])
      head :ok
    else
      WebPushOptin.create!(webpush_params)
      head :created
    end
  end

  def destroy
    WebPushOptin.where(:endpoint => webpush_params[:endpoint]).destroy_all
    head :no_content
  end

  def send_message
    output = WebPushService.new(web_push_optin: WebPushOptin.last, web_push_message: web_push_message).send!
    render :json => output
  rescue WebPushService::InvalidSubscription => e
    # delete invalid subscription
    head :gone
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
      :icon  => view_context.asset_path('push-icon.jpg'),
      :url   => sample_url
    })
  end

end
