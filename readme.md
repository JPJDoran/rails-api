This project is a minimal setup for a **Ruby on Rails API** running in **Docker** on Windows.
It includes **PostgreSQL** and uses **Docker Compose** to manage both the Rails app and database.
The project is designed to allow experimentation with the basics of Ruby on Rails in a containerized environment.

---

1. **Create the project folder**  
   - Example location: `C:\Users\<YourName>\rails-api`
   - This folder will contain all Rails app files, Docker setup, and dependencies.

2. **Create the Dockerfile**  
   - Sets up a Docker image with Ruby 3.2, Bundler, and system dependencies.
   - Installs build tools and PostgreSQL headers for gems that require compilation.
   - Prepares the environment so the Rails app can run inside the container.

3. **Create the Gemfile**  
   - Specifies the Ruby version and Rails gems.
   - Minimal gems for an API-only Rails app without frontend dependencies.

4. **Create an empty Gemfile.lock**  
   - Ensures Docker can run `bundle install` on first build.

5. **Create docker-compose.yml**  
   - Defines two services: `web` for Rails and `db` for PostgreSQL.
   - Maps port 3000 from the Rails container to Windows so the API can be accessed via localhost.
   - Sets environment variables for database credentials and host so Rails can connect to Postgres.
   - Uses a Docker volume for Postgres data to persist your database across container restarts.

6. **Update Rails database configuration**  
   - Modify `config/database.yml` to use environment variables provided by Docker Compose: host, username, password, and database name.
   - This allows Rails to connect to the PostgreSQL container automatically.

7. **Build and start the containers**  
   - From the project folder, run Docker Compose to build images and start both containers.
   - Rails will automatically wait for Postgres to be ready before connecting.

8. **Set up the database**  
   - Run Rails database commands inside the container to create and migrate the database. This ensures the PostgreSQL database is initialized and ready for your app.
   - `rails db:create`
   - `rails db:migrate`

9. **Start the Rails API server**  
   - Rails will be accessible on `http://localhost:3000` from Windows.
   - Logs appear in the terminal, and the API is ready for development and testing.

10. **Stopping the containers**  
    - Stop and remove containers using Docker Compose without losing database data thanks to the persistent volume.

---

This README captures the **full Docker Compose workflow**: building the Rails image, running the Rails and Postgres containers together, and connecting them seamlessly for development.