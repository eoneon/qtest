Rails.application.routes.draw do
  resources :items
  resources :flags
  resources :artist_types
  resources :mount_types
  resources :item_types
  resources :edition_types
  resources :sign_types
  resources :cert_types
  resources :dim_types
  resources :disclaimer_types
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

  resources :item_types do
    collection do
      post :import
    end
  end

  resources :field_values do
    collection do
      post :import
    end
  end

  resources :suppliers do
    resources :invoices, except: [:index]
  end

  resources :invoices do
    resources :items, except: [:index] do
      member do
        get :create_skus, :export
      end
    end
    resources :notes
  end

  resources :items do
    resources :notes
  end

  root to: 'invoices#index'
end
