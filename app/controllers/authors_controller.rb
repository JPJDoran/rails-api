class AuthorsController < ApiController
  def index
    # Get authors from cache based on last updated author (timestamp converted to integer)
    # set cache if no existing value
    authors_json = Rails.cache.fetch(["authors", Author.maximum(:updated_at).to_i]) do
      Author.all.as_json(only: [:id, :name])
    end

    render json: authors_json
  end

  def show
    # Get author from cache, set cache if no existing value
    author_json = Rails.cache.fetch(["authors", params[:id]], expires_in: 5.minutes) do
      Author.find(params[:id]).as_json(only: [:id, :name])
    end

    render json: author_json
  end
end
