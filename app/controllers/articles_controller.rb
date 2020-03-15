class ArticlesController < ApplicationController
  def index
    @articles = Article.where(user: current_user).sort_by(&:created_at).reverse

    @new_article = Article.new

    render :list
  end

  def create
    new_article = Article.new(user: current_user, url: params.dig(:article, :url))

    if new_article.save
      flash[:success] = 'URL saved'
    else
      flash[:error] = new_article.errors.full_messages.to_sentence
    end
    redirect_to :articles
  end
end
