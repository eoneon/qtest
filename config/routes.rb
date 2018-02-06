Rails.application.routes.draw do
  resources :item_types
  resources :categories
  resources :media, controller: "categories", type: "Medium"
  resources :substrates, controller: "categories", type: "Substrate"

  resources :item_types do
    collection do
      post :import
    end
  end

  resources :categories do
    collection do
      post :import
    end
  end
end
