# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://localhost:8081', 'http://localhost:8082', 'exp://192.168.1.38:8081', 'exp://192.168.1.38:8082', 'https://nicolasmahecha.com'
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end