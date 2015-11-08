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
    puts params
    puts session
    if (params.nil? or not (params.has_key?("sortby") or params.has_key?("ratings")) ) 
      #No parameters passed, use session, redirect
      sortby=session[:sortby]
      ratingsfilter=session[:ratings]
      #redirect with new parameters
      unless (sortby.nil? and ratingsfilter.nil?)
        flash.keep
        redirect_to controller: 'movies', sortby: sortby, ratings: ratingsfilter
      end
    elsif params.has_key?("sortby") and (not (params.has_key?("ratings")))
      sortby=params[:sortby]
      ratingsfilter=session[:ratings]

      session[:sortby]=params[:sortby]
      #redirect with new parameters
      if not ratingsfilter.nil?
        flash.keep
        redirect_to controller: 'movies', sortby: sortby, ratings: ratingsfilter
      end
    elsif (not (params.has_key?("sortby"))) and params.has_key?("ratings")
      sortby=session[:sortby]
      ratingsfilter=params[:ratings]

      session[:ratings]=params[:ratings]
      #redirect with new parameters
      if not sortby.nil?
        flash.keep
        redirect_to controller: 'movies', sortby: sortby, ratings: ratingsfilter
      end
    else
      sortby=params[:sortby]
      ratings=params[:ratings]
      session[:ratings]=params[:ratings]
      session[:sortby]=params[:sortby]
      #no need to redirect, we have both
    end
         
    @all_ratings = Movie.select(:rating).distinct.order(:rating).pluck(:rating)
    ratingsfilter=params[:ratings]
    if not ratingsfilter.nil?
      @ratingscheck = ratingsfilter.keys
    end
    @sortbyval=sortby
    #TODO filter on keys, remember checked buttons, make all buttons checked at start
    curchain = Movie.all
    if ratingsfilter.nil?
      curchain = curchain.all #should never happen
    else
      curchain=curchain.where(:rating => ratingsfilter.keys)
    end
    puts sortby
    if sortby=='title'
      curchain = curchain.order(:title)
    elsif sortby=='date'
      curchain = curchain.order(:release_date)
    end
    @movies = curchain
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
