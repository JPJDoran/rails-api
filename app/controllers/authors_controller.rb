class AuthorsController < ApplicationController
  def index
    authors = Author.all
    render json: authors.as_json(only: [:id, :name])
  end

  def show
    author = Author.find(params[:id])
    render json: author.as_json(only: [:id, :name])
  end
end
