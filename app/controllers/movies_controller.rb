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
      #learned about sessions from: https://www.theodinproject.com/courses/ruby-on-rails/lessons/sessions-cookies-and-authentication
    #@movies = Movie.order(params[:sort_by])
    #@sort = params[:sort_by]
    @all_ratings = Movie.all_ratings
    #@ratings = params[:ratings]
    
    redirect = false
    
    if params[:sort_by]
      @sort = params[:sort_by]
      session[:sort] = @sort
    elsif session[:sort]
      @sort = session[:sort]
      redirect = true
    else
      @sort = nil
    end

    if params[:ratings]
      @ratings = params[:ratings]
      session[:ratings] = @ratings
    elsif session[:ratings]
      @ratings = session[:ratings]
      redirect = true
    else
      @ratings = nil
    end

    if redirect == true
      flash.keep
      redirect_to movies_path :sort_by => @sort, :ratings => @ratings
      #redirect = false
    end
    
    if @sort and @ratings
      @movies = Movie.where(:rating => @ratings.keys).order(@sort)
    elsif @ratings
      @movies = Movie.where(:rating => @ratings.keys)
    elsif @sort
      @movies = Movie.all.order(@sort)
    else
      @movies = Movie.all
    end
    
    if !@ratings and params[:commit] != "Refresh"
        @ratings = Hash.new
        @all_ratings.each do |rating|
            @ratings[rating] = 1
        end
        #session[:ratings] = @ratings
    elsif !@ratings
        @ratings = Hash.new
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
