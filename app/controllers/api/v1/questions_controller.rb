class Api::V1::QuestionsController < ApplicationController

  before_action :authenticate_key, except: [:index, :show]
  
  def index
    @vars = request.query_parameters
    @questions = Question.where(nil)

    #implement valid header query filters
    filtering_params(params).each do |key, value|
      @questions = @questions.public_send(key, value) if value.present?
    end    
    
    render json: @questions  
  end

  def show
    render json: Question.find(params[:id])
  end

  def edit
  end

  def create
    @question = Question.create(question_params)
    render json: @question 
  end

  def destroy
    @users_key = params[:api_key]
    @question = Question.find(params[:id])
    render json: @question.update(question_params)
  end

  def delete 
    @question = Question.find(params[:id])
    @question.destroy 
  end 

  private

    def question_params
      params.permit(:title, :answer, :rating, :category, :keyword, :id)
    end 

    def authenticate_key
      if params[:api_key]
        api_key = params[:api_key] 
      else
        api_key = request.headers['X-Api-Key']
      end 
      head status: 403 unless User.exists?(:api_key => api_key)
    end 

    def filtering_params(params)
      params.slice(:category, :keyword, :rating, :min_rating, :title_includes)
    end

end
