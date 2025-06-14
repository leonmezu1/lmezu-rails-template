# Rails 8 Application Template

A modern Rails 8 application template that provides a solid foundation for building web applications with best practices and popular tools.

## Features

- **Ruby 3.4.4** - Latest stable Ruby version
- **PostgreSQL** - Robust database system
- **Bun** - Fast JavaScript runtime and bundler
- **Tailwind CSS** - Utility-first CSS framework
- **RSpec** - Testing framework with:
  - Factory Bot for test data
  - Faker for generating fake data
  - Shoulda Matchers for common Rails testing
  - Database Cleaner for test isolation
- **Development Tools**:
  - Ruby LSP for IDE support
  - Letter Opener for email previews
  - Bullet for N+1 query detection
  - Better Errors for enhanced error pages
  - Annotate for model documentation
  - Query tracing for debugging
- **API Ready**:
  - Rack-CORS for cross-origin requests
  - API-friendly configuration
- **Deployment**:
  - Kamal for zero-downtime deployments
- **Modern Development**:
  - Improved `bin/dev` script with proper foreman detection
  - Debug configuration included
  - Beautiful welcome page with Tailwind CSS

## Prerequisites

- Ruby 3.4.4
- PostgreSQL
- Bun
- Node.js (for Bun)

## Usage

Create a new Rails application using this template:

```bash
rails new your_app_name \
  -d postgresql \
  --skip-kamal \
  --javascript=bun \
  -m https://raw.githubusercontent.com/leonmezu1/lmezu-rails-template/master/lmezu-template.rb
```

## Getting Started

After creating your application:

1. Start the development server:
   ```bash
   bin/dev
   ```

2. Visit `http://localhost:3000` to see your application

3. Run the test suite:
   ```bash
   bundle exec rspec
   ```

## Development

The template includes several development tools to enhance your workflow:

- **Email Preview**: View emails in development using Letter Opener
- **N+1 Detection**: Bullet will warn you about N+1 queries
- **Query Tracing**: Debug database queries with ActiveRecord Query Trace
- **Model Documentation**: Keep your models documented with Annotate

## Testing

The application is configured with RSpec and includes:

- Factory Bot for test data generation
- Faker for generating realistic test data
- Shoulda Matchers for common Rails testing
- Database Cleaner for test isolation

## Deployment

The template includes Kamal for deployment. To deploy your application:

1. Configure your deployment settings in `config/deploy.yml`
2. Run `kamal setup` to initialize your deployment
3. Deploy with `kamal deploy`

## Contributing

Feel free to submit issues and enhancement requests!

## License

This template is available as open source under the terms of the MIT License. 
