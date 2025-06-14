# Rails 8.0+ Application Template
# ---------------------------------
#
# This template configures a new Rails application with:
# - Ruby 3.4.4 (.ruby-version file)
# - PostgreSQL as the database
# - Bun for JavaScript bundling
# - Tailwind CSS (via postcss-cli, no gem)
# - RSpec for testing, with Factory Bot, Faker, and Shoulda Matchers
# - A curated set of development gems for debugging and performance.
# - Rack-CORS for API readiness.
# - Kamal for deployment.
# - A default Welcome controller and view.
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

  gem_group :development, :test do
    gem 'rspec-rails', '~> 6.1'
    gem 'factory_bot_rails', '~> 6.4'
    gem 'faker', '~> 3.3'
    gem 'shoulda-matchers', '~> 5.3'
    gem 'database_cleaner-active_record', '~> 2.1'
  end

  gem_group :development do
    gem 'ruby-lsp', require: false
    gem 'letter_opener', '~> 1.8'
    gem 'bullet', '~> 7.1'
    gem 'better_errors', '~> 2.10'
    gem 'binding_of_caller', '~> 1.0'
    gem 'annotate', '~> 3.2'
    gem 'active_record_query_trace', '~> 2.2'
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

def setup_tailwind
  say "Setting up Tailwind CSS manually...", :cyan

  # Install JS dependencies
  run "bun add tailwindcss postcss autoprefixer"

  # Create tailwind.config.js
  file 'tailwind.config.js', <<~JS
    module.exports = {
      content: [
        './app/views/**/*.html.erb',
        './app/helpers/**/*.rb',
        './app/assets/stylesheets/**/*.css',
        './app/javascript/**/*.js'
      ]
    }
  JS

  # Create postcss.config.js
  file 'postcss.config.js', <<~JS
    module.exports = {
      plugins: {
        tailwindcss: {},
        autoprefixer: {},
      }
    }
  JS

  # Create the main Tailwind input file
  file 'app/assets/stylesheets/application.tailwind.css', <<~CSS
    @tailwind base;
    @tailwind components;
    @tailwind utilities;
  CSS

  # Add CSS build command to Procfile.dev
  append_to_file 'Procfile.dev', "css: bun tailwindcss -i ./app/assets/stylesheets/application.tailwind.css -o ./app/assets/builds/application.css --watch\n"
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
    <main class="min-h-screen bg-gray-100 dark:bg-gray-900 flex flex-col justify-center items-center p-4">
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
    </main>
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
  setup_tailwind
  setup_kamal
  setup_root_route_and_view
  setup_database

  # Perform final cleanup and versioning
  initial_commit

  say "✅ Template application setup is complete!", :green
  say "To start your server, run `bin/dev`"
end
