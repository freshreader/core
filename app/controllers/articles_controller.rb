class ArticlesController < ApplicationController
  def index
    @articles = Article.where(user: current_user).sort_by(&:created_at).reverse

    @new_article = Article.new

    render :list
  end

  def create
    url = params.dig(:article, :url)&.strip
    title = RequestHelper.extract_title_from_page(url)

    new_article = Article.new(user: current_user, url: url, title: title)

    if new_article.save
      flash[:success] = 'URL saved'
    else
      flash[:error] = new_article.errors.full_messages.to_sentence
    end
    redirect_to :articles
  rescue
    flash[:error] = 'There was an issue saving this URL.'
    redirect_to :articles
  end

  def destroy
    @article = Article.find(params[:id])
    if @article.destroy
      flash[:success] = 'Article marked as read'
    else
      flash[:error] = 'There was an issue marking this article as read.'
    end
    redirect_to :articles
  end
end
