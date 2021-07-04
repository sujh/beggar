Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: "beggars#index"
  resources :beggars, except: [:show] do
    post :run, on: :member
    post :stop, on: :member
  end
end
