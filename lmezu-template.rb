# Rails 8.0+ Application Template
# ---------------------------------
#
# This template configures a new Rails application with:
# - Ruby 3.4.4 (.ruby-version file)
# - PostgreSQL as the database
# - Bun for JavaScript bundling
# - Tailwind CSS (via tailwindcss-rails gem)
# - RSpec for testing, with Factory Bot, Faker, and Shoulda Matchers
# - A curated set of development gems for debugging and performance.
# - Rack-CORS for API readiness.
# - Kamal for deployment.
# - A default Welcome controller and view.
# - Improved bin/dev script with proper foreman detection and debug config
#
# Usage for Rails 8.0.2:
# rails new your_app_name -d postgresql --javascript=bun --skip-kamal -m /path/to/this/template.rb
#
# ---------------------------------

def source_paths
    [__dir__]
  end
  
  def add_gems
    # Specify Ruby version
    file '.ruby-version', '3.4.4'
  
    # For API Cross-Origin Resource Sharing
    gem 'rack-cors'
  
    # For deployment
    gem 'kamal'
  
    # For Tailwind CSS
    gem 'tailwindcss-rails'
  
    gem_group :development, :test do
      gem 'rspec-rails'
      gem 'factory_bot_rails'
      gem 'faker'
      gem 'shoulda-matchers'
      gem 'database_cleaner-active_record'
    end
  
    gem_group :development do
      gem 'ruby-lsp', require: false
      gem 'letter_opener'
      gem 'bullet'
      gem 'better_errors'
      gem 'binding_of_caller'
      gem 'annotate'
      gem 'active_record_query_trace'
    end
  end
  
  def setup_api
    say "Setting up for API...", :cyan
    # Add rack-cors configuration for API access
    file 'config/initializers/cors.rb', <<~RUBY
      # Be sure to restart your server when you modify this file.
  
      # Avoid CORS issues when API is called from the frontend app.
      # Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.
  
      # Read more: https://github.com/cyu/rack-cors
  
      Rails.application.config.middleware.insert_before 0, Rack::Cors do
        allow do
          origins '*' # WARNING: For development only. Change this for production.
  
          resource '*',
            headers: :any,
            methods: [:get, :post, :put, :patch, :delete, :options, :head]
        end
      end
    RUBY
  end
  
  def setup_rspec
    # Install RSpec
    generate 'rspec:install'
  
    # Remove the default test directory
    run 'rm -rf test'
  
    # Configure Shoulda Matchers
    append_to_file 'spec/rails_helper.rb', <<~RUBY
  
      # Shoulda Matchers configuration
      Shoulda::Matchers.configure do |config|
        config.integrate do |with|
          with.test_framework :rspec
          with.library :rails
        end
      end
    RUBY
  
    # Configure Database Cleaner
    inject_into_file 'spec/rails_helper.rb', after: "RSpec.configure do |config|\n" do
      <<~RUBY
        config.before(:suite) do
          DatabaseCleaner.strategy = :transaction
          DatabaseCleaner.clean_with(:truncation)
        end
  
        config.around(:each) do |example|
          DatabaseCleaner.cleaning do
            example.run
          end
        end
  
      RUBY
    end
  end
  
  def setup_development_environment
    # Configure Letter Opener for development email previews
    environment 'config.action_mailer.delivery_method = :letter_opener', env: 'development'
    environment 'config.action_mailer.perform_deliveries = true', env: 'development'
  
    # Configure Bullet for N+1 query detection
    initializer 'bullet.rb', <<~RUBY
      # config/initializers/bullet.rb
      if defined?(Bullet)
        Bullet.enable = true
        Bullet.alert = true
        Bullet.bullet_logger = true
        Bullet.console = true
        # Bullet.growl = true
        Bullet.rails_logger = true
        Bullet.add_footer = true
      end
    RUBY
  
    # Install annotate's binstub
    run 'bundle exec rails g annotate:install'
  end

  def setup_bin_dev
    say "Setting up improved bin/dev script...", :cyan
    # Create an improved bin/dev script with proper foreman detection and debug config
    file 'bin/dev', <<~BASH
      #!/usr/bin/env sh

      # Exit if any command fails
      set -e

      # Add debug configuration for development
      export RUBY_DEBUG_OPEN="true"
      export RUBY_DEBUG_LAZY="true"

      # Check if foreman is available
      if ! gem list foreman -i --silent; then
        echo "Installing foreman..."
        gem install foreman
      fi

      # Start the development server
      exec foreman start -f Procfile.dev "$@"
    BASH

    # Make it executable
    run 'chmod +x bin/dev'
  end
  
  def setup_tailwind
    say "Setting up Tailwind CSS with tailwindcss-rails gem...", :cyan
  
    # Install Tailwind CSS using the Rails gem
    rails_command 'tailwindcss:install'
  
    # The tailwindcss:install command creates the necessary files, but we need to ensure
    # the layout references the correct stylesheet
    
    # Update Procfile.dev with proper Rails command
    append_to_file 'Procfile.dev', "css: bin/rails tailwindcss:watch\n"
  end
  
  def setup_kamal
    say "Setting up Kamal for deployment...", :cyan
    rails_command "kamal:install"
  end
  
  def setup_root_route_and_view
    say "Creating Welcome controller and view...", :cyan
    generate :controller, "Welcome", "index"
    route "root 'welcome#index'"
  
    # Overwrite the generated view with a nice landing page
    remove_file 'app/views/welcome/index.html.erb'
    file 'app/views/welcome/index.html.erb', <<~HTML
      <div class="min-h-screen bg-gray-100 dark:bg-gray-900 flex flex-col justify-center items-center p-4 w-full">
        <div class="max-w-3xl w-full text-center">
          <div class="mb-8">
            <h1 class="text-4xl sm:text-6xl font-extrabold text-gray-800 dark:text-white">
              Welcome to Your Rails 8 App!
            </h1>
            <p class="mt-4 text-lg text-gray-600 dark:text-gray-300">
              This application is ready to go, configured with Tailwind CSS, RSpec, and Bun.
            </p>
          </div>
  
          <div class="bg-white dark:bg-gray-800 p-6 sm:p-8 rounded-xl shadow-lg border border-gray-200 dark:border-gray-700">
            <h2 class="text-2xl font-bold text-gray-700 dark:text-white mb-6">
              Next Steps
            </h2>
            <ul class="text-left space-y-4">
              <li class="flex items-start">
                <span class="text-green-500 dark:text-green-400 mr-3 mt-1 flex-shrink-0">
                  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path></svg>
                </span>
                <div>
                  <h3 class="font-semibold text-gray-800 dark:text-gray-100">Start your server</h3>
                  <p class="text-gray-600 dark:text-gray-400">Run <code class="bg-gray-200 dark:bg-gray-700 text-sm font-mono p-1 rounded">bin/dev</code> to start the development server.</p>
                </div>
              </li>
              <li class="flex items-start">
                <span class="text-green-500 dark:text-green-400 mr-3 mt-1 flex-shrink-0">
                  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 14v6m-3-3h6M3 10h11M3 6h11M3 14h5M3 18h5"></path></svg>
                </span>
                <div>
                  <h3 class="font-semibold text-gray-800 dark:text-gray-100">Generate a Scaffold</h3>
                  <p class="text-gray-600 dark:text-gray-400">Try <code class="bg-gray-200 dark:bg-gray-700 text-sm font-mono p-1 rounded">rails g scaffold Post title:string body:text</code></p>
                </div>
              </li>
               <li class="flex items-start">
                <span class="text-green-500 dark:text-green-400 mr-3 mt-1 flex-shrink-0">
                  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4"></path></svg>
                </span>
                <div>
                  <h3 class="font-semibold text-gray-800 dark:text-gray-100">Run Your Tests</h3>
                  <p class="text-gray-600 dark:text-gray-400">Execute <code class="bg-gray-200 dark:bg-gray-700 text-sm font-mono p-1 rounded">bundle exec rspec</code> to run the test suite.</p>
                </div>
              </li>
            </ul>
          </div>
        </div>
      </div>
    HTML

    # lets modify the application.html.erb to use the new layout
    remove_file 'app/views/layouts/application.html.erb'
    file 'app/views/layouts/application.html.erb', <<~HTML
      <!DOCTYPE html>
        <html>
          <head>
            <title><%= content_for(:title) || "Testing" %></title>
            <meta name="viewport" content="width=device-width,initial-scale=1">
            <meta name="apple-mobile-web-app-capable" content="yes">
            <meta name="mobile-web-app-capable" content="yes">
            <%= csrf_meta_tags %>
            <%= csp_meta_tag %>

            <%= yield :head %>

            <%# Enable PWA manifest for installable apps (make sure to enable in config/routes.rb too!) %>
            <%#= tag.link rel: "manifest", href: pwa_manifest_path(format: :json) %>

            <link rel="icon" href="/icon.png" type="image/png">
            <link rel="icon" href="/icon.svg" type="image/svg+xml">
            <link rel="apple-touch-icon" href="/icon.png">

            <%# Includes all stylesheet files in app/assets/stylesheets %>
            <%= stylesheet_link_tag :app, "data-turbo-track": "reload" %>
            <%= javascript_include_tag "application", "data-turbo-track": "reload", type: "module" %>
          </head>

          <body>
            <div class="mx-auto flex w-full">
              <%= yield %>
            </div>
          </body>
        </html>
    HTML
  end
  
  def setup_database
    say "Creating and migrating database...", :cyan
    rails_command 'db:create'
    rails_command 'db:migrate'
  end
  
  def initial_commit
    say "Initializing Git repository and making initial commit...", :cyan
    git :init
    git add: "."
    git commit: "-m 'Initial commit: Rails app configured with custom template'"
  end
  
  # Main setup execution
  # --------------------
  
  say "Starting Rails 8 application template...", :cyan
  
  add_gems
  
  # This runs `bundle install`
  after_bundle do
    setup_api
    setup_rspec
    setup_development_environment
    setup_bin_dev
    setup_tailwind
    setup_kamal
    setup_root_route_and_view
    setup_database
  
    # Perform final cleanup and versioning
    initial_commit
  
    say "✅ Template application setup is complete!", :green
    say "To start your server, run `bin/dev`"
  end
  
