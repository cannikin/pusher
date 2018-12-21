Rails.application.routes.draw do

  get 'sample' => 'pages#sample'

  get    'send'        => 'push#send_message'
  post   'subscribe'   => 'push#create'
  delete 'unsubscribe' => 'push#destroy'

  root :to => 'pages#index'

end
