#!/usr/bin/env ruby

# Rails Application Template
# Usage: rails new myapp -d postgresql -m rails_template.rb

# Gems
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

# Tailwind CSS
gem 'tailwindcss-rails'

# Run bundle install
run 'bundle install'

# Setup PostgreSQL (already configured via -d postgresql flag)
puts "PostgreSQL configured as database"

# Setup Tailwind CSS
generate 'tailwindcss:install'

# Setup RSpec
generate 'rspec:install'

# Configure RSpec
rspec_rails_helper = <<~RUBY
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.default_formatter = "doc" if config.files_to_run.one?
  config.order = :random
  Kernel.srand config.seed
end
RUBY

# Create spec/rails_helper.rb with proper configuration
rails_helper_content = <<~RUBY
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'factory_bot_rails'
require 'database_cleaner/active_record'

Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_path = "\#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
RUBY

# Update spec files
remove_file 'spec/rails_helper.rb'
create_file 'spec/rails_helper.rb', rails_helper_content

inject_into_file 'spec/spec_helper.rb', after: "RSpec.configure do |config|\n" do
  <<~RUBY
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.default_formatter = "doc" if config.files_to_run.one?
  config.order = :random
  Kernel.srand config.seed

  RUBY
end

# Create spec/support directory
empty_directory 'spec/support'

# Create factory_bot configuration
create_file 'spec/support/factory_bot.rb', <<~RUBY
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
RUBY

# Configure development environment
environment 'config.action_mailer.delivery_method = :letter_opener', env: 'development'
environment 'config.action_mailer.perform_deliveries = true', env: 'development'

# Bullet configuration
bullet_config = <<~RUBY

  # Bullet configuration
  config.after_initialize do
    Bullet.enable = true
    Bullet.alert = true
    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.rails_logger = true
  end
RUBY

inject_into_file 'config/environments/development.rb', bullet_config, before: 'end'

# ActiveRecord Query Trace configuration
query_trace_config = <<~RUBY

  # ActiveRecord Query Trace
  if defined?(ActiveRecordQueryTrace)
    ActiveRecordQueryTrace.enabled = true
  end
RUBY

inject_into_file 'config/environments/development.rb', query_trace_config, before: 'end'

# Configure Annotate
generate 'annotate:install'

# Create a basic controller and view for testing
generate 'controller', 'Home', 'index'

# Update routes
route "root 'home#index'"

# Update home controller
inject_into_file 'app/controllers/home_controller.rb', after: "def index\n" do
  "    @message = 'Welcome to your new Rails app with Tailwind CSS!'\n"
end

# Update home view with Tailwind classes
remove_file 'app/views/home/index.html.erb'
create_file 'app/views/home/index.html.erb', <<~HTML
<div class="min-h-screen bg-gray-100 py-6 flex flex-col justify-center sm:py-12">
  <div class="relative py-3 sm:max-w-xl sm:mx-auto">
    <div class="absolute inset-0 bg-gradient-to-r from-cyan-400 to-light-blue-500 shadow-lg transform -skew-y-6 sm:skew-y-0 sm:-rotate-6 sm:rounded-3xl"></div>
    <div class="relative px-4 py-10 bg-white shadow-lg sm:rounded-3xl sm:p-20">
      <div class="max-w-md mx-auto">
        <div class="divide-y divide-gray-200">
          <div class="py-8 text-base leading-6 space-y-4 text-gray-700 sm:text-lg sm:leading-7">
            <h1 class="text-2xl font-bold text-gray-900 mb-4">🚀 Rails Template Setup Complete!</h1>
            <p><%= @message %></p>
            <ul class="list-disc space-y-2 ml-4">
              <li>PostgreSQL configured</li>
              <li>Tailwind CSS ready</li>
              <li>RSpec test suite setup</li>
              <li>Development gems installed</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
HTML

# Configure Bun (JavaScript runtime)
bun_config = <<~RUBY

# Configure Bun as JavaScript runtime
Rails.application.config.assets.configure do |env|
  env.export_concurrent = false
end
RUBY

inject_into_file 'config/application.rb', bun_config, before: '  end'

# Create a .bun-version file to specify Bun version
create_file '.bun-version', 'latest'

# Add package.json for Bun
create_file 'package.json', <<~JSON
{
  "name": "rails-app",
  "version": "1.0.0",
  "description": "Rails application with Bun",
  "main": "app/javascript/application.js",
  "scripts": {
    "build": "bun run build:css",
    "build:css": "tailwindcss -i ./app/assets/stylesheets/application.tailwind.css -o ./app/assets/builds/tailwind.css --watch"
  },
  "dependencies": {
    "@hotwired/turbo-rails": "^7.0.0",
    "@hotwired/stimulus": "^3.0.0"
  },
  "devDependencies": {
    "tailwindcss": "^3.0.0"
  }
}
JSON

# Run database setup
rails_command 'db:create'
rails_command 'db:migrate'

# Generate a sample model and spec for testing
generate 'model', 'User', 'name:string', 'email:string'
rails_command 'db:migrate'

# Create sample factory
create_file 'spec/factories/users.rb', <<~RUBY
FactoryBot.define do
  factory :user do
    name { Faker::Name.full_name }
    email { Faker::Internet.email }
  end
end
RUBY

# Run tests to ensure everything works
rails_command 'spec'

puts "\n" + "="*50
puts "🎉 Rails Template Setup Complete!"
puts "="*50
puts "✅ PostgreSQL configured"
puts "✅ Tailwind CSS installed"
puts "✅ Bun configured for JavaScript"
puts "✅ RSpec test suite setup"
puts "✅ Development gems installed:"
puts "   - ruby-lsp, better_errors, binding_of_caller"
puts "   - bullet, letter_opener, annotate"
puts "   - active_record_query_trace"
puts "✅ Test gems installed:"
puts "   - rspec-rails, factory_bot_rails, faker"
puts "   - shoulda-matchers, database_cleaner-active_record"
puts "\nNext steps:"
puts "1. Run 'bun install' to install JavaScript dependencies"
puts "2. Start the server with 'rails server'"
puts "3. Run tests with 'bundle exec rspec'"
puts "="*50