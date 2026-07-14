# Ancestors and Descendants Tree

This is a simple Rails application that allows you to create and manage a family tree.

## Features

- Create and manage a family tree
- Display the ancestors and descendants of a person

## Technologies

- Ruby on Rails
- Tailwind CSS
- PostgreSQL

## Setup (local)

1. Clone the repository
2. Run `bundle install`
3. Run `rails db:migrate`
4. Run `bin/rails db:seed` (optional sample data)
5. Run `bin/dev`

## Setup (Docker)

Requires [Docker](https://docs.docker.com/get-docker/) and Docker Compose.

```bash
docker compose up --build
```

Then open [http://localhost:3000](http://localhost:3000).

On first boot the app prepares the database and loads seeds when the people table is empty.

Useful commands:

```bash
# Rebuild and start in the background
docker compose up --build -d

# Force re-seed (clears people and reloads db/seeds.rb)
SEED=1 docker compose up

# Rails console
docker compose exec web bin/rails console

# Run the test suite
docker compose exec web bundle exec rspec

# Stop
docker compose down
```

Production-style image (Kamal / thruster) still builds from `Dockerfile`:

```bash
docker build -t ancestry_tree .
```

## Usage

1. Go to `http://localhost:3000`
2. Click on `New person` to create a new person
3. Click on `Show` to view the ancestors and descendants of a person

## Linting

```bash
bin/rubocop -A
```

## Testing

```bash
bundle exec rspec
```

## Coverage

```bash
bundle exec rspec --format json --out coverage/coverage.json
```

## Links

- [Ruby on Rails](https://rubyonrails.org/)
- [Tailwind CSS](https://tailwindcss.com/)

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
