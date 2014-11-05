Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  namespace :activa do
    get :init
    post :done
    get :fail
  end
end
