Rails.application.routes.draw do

  get 'photos/filter', to: 'photos#filter', as: 'photos_filter'
  get 'photos/autocomplete', to: 'photos#autocomplete', as: 'photos_autocomplete'
  resources :photos
  get 'photos/post-gallery-ajax/:post', to: 'photos#post_gallery_ajax', as: 'photos_post_gallery_ajax'
  get 'photos/forpost/:post', to: 'photos#forpost', as: 'photos_for_post'
  get 'photos/popup/:photo', to: 'photos#popup', as: 'photo_popup'
  get 'photos/exif/:photo', to: 'photos#exif', as: 'photo_exif'
  post 'photos/sort/:post', to: 'photos#sort', as: 'photos_sort'


  get 'tags/for-:essence', to: 'tags#autocomplete', as: 'tags_autocomplete'
  get 'tags/filter', to: 'tags#filter', as: 'tags_filter'
  resources :tags

  get 'posts/filter', to: 'posts#filter', as: 'posts_filter'
  get 'posts/autocomplete', to: 'posts#autocomplete', as: 'posts_autocomplete'
  resources :posts

  get 'log_out' => 'sessions#destroy', :as => 'log_out'
  get 'log_in' => 'sessions#new', :as => 'log_in'
  get 'sign_up' => 'users#new', :as => 'sign_up'
  root :to => 'posts#index'

  get 'categories/delete/:id', to: 'categories#delete', as: 'category_delete'
  resources :categories

  resources :users
  resources :sessions

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
