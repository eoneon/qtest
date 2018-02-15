Rails.application.routes.draw do
  resources :items
  resources :item_types
  resources :edition_types
  resources :sign_types
  resources :cert_types
  resources :categories
  resources :item_fields
  resources :field_values

  resources :categories do
    collection do
      post :import
    end
  end

  resources :item_fields do
    collection do
      post :import
    end
  end

  resources :field_values do
    collection do
      post :import
    end
  end
end
