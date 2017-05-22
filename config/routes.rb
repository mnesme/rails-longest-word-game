Rails.application.routes.draw do
  get 'game', to: 'play#game'

  get 'score', to: 'play#score'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
