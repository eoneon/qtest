Rails.application.routes.draw do
  resources :item_types
  resources :categories
  resources :artkinds, controller: "categories", type: "Artkind"
  resources :embellishes, controller: "categories", type: "Embellish"
  resources :exclusives, controller: "categories", type: "Exclusive"
  resources :leafings, controller: "categories", type: "Leafing"
  resources :media, controller: "categories", type: "Medium"
  resources :remarques, controller: "categories", type: "Remarque"
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
