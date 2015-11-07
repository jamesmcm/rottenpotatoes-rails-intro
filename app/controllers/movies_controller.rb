class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    sortby=params[:sortby]
    @all_ratings = Movie.select(:rating).distinct.order(:rating).pluck(:rating)
    ratingsfilter=params[:ratings]
    if not ratingsfilter.nil?
      @ratingscheck = ratingsfilter.keys
    end
    
    #TODO filter on keys, remember checked buttons, make all buttons checked at start 
    if sortby=='title'
      @movies = Movie.order(:title)
    elsif sortby=='date'
      @movies = Movie.order(:release_date)
    else
      if ratingsfilter.nil?
        @movies = Movie.all #TODO make this use session settings
      else
        @movies=Movie.where(:rating => ratingsfilter.keys)
      end
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
