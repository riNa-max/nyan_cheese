  Rails.application.routes.draw do
    resources :photos, only: [:index, :show, :destroy]
    root to: 'homes#top'
    get '/about', to: 'homes#about', as: 'about'
    post "/webhooks/line", to: "webhooks#line"
    devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
    resource :line_link, only: [:show, :create], controller: "line_links"
    resource :line_friend, only: [:show], controller: "line_friends"
    resource :settings, only: [:show, :update]
    resources :share_links, only: [:index, :create, :destroy]
    get "/shares/:token", to: "shares#show", as: :"share"
    resources :albums, only: [:index, :show]
  end
  