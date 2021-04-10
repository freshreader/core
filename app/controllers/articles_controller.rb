class ArticlesController < ApplicationController
  skip_before_action :authorized, only: [:save_mobile, :save_bookmarklet]

  def index
    @articles = Article.where(user: current_user).sort_by(&:created_at).reverse

    @new_article = Article.new

    render :list
  end

  def save_bookmarklet
    unless logged_in?
      flash[:warning] = 'You need to log in before saving this URL.'
      return redirect_to login_url(return_to: "#{request.protocol + request.host}/save?url=#{params[:url]}")
    end

    return if check_save_limit

    url = RequestHelper.url_from_param(params[:url])
    title, fetched_url = RequestHelper.extract_title_from_page(url)

    new_article = Article.new(user: current_user, url: fetched_url, title: title)

    if new_article.save
      flash[:success] = 'Saved successfully.'
    else
      flash[:error] = new_article.errors.full_messages.to_sentence
    end
    redirect_to :articles
  rescue
    flash[:error] = 'There was an issue saving this URL.'
    redirect_to :articles
  end

  def save_mobile
    unless user = User.find_by(account_number: params[:account_number].delete(' '))
      return render json: 'This user does not exist.', status: :unauthorized
    end

    if !(user.subscribed? || user.early_adopter?) && user.articles.size >= Article::ARTICLES_LIMIT_ON_FREE_PLAN
      return render json: "You cannot save more than #{Article::ARTICLES_LIMIT_ON_FREE_PLAN} items on the free plan. Upgrade to Pro to save more items.", status: :forbidden
    end

    url = RequestHelper.url_from_param(params[:url])
    title, fetched_url = RequestHelper.extract_title_from_page(url)
    new_article = Article.new(user: user, url: fetched_url, title: title)

    if new_article.save
      head :ok
    else
      render json: { error: new_article.errors.full_messages.to_sentence }, status: :internal_server_error
    end
  rescue
    render json: { error: 'There was an issue saving this URL.' }, status: :internal_server_error
  end

  def create
    return if check_save_limit

    url = RequestHelper.url_from_param(params.dig(:article, :url))
    title, fetched_url = RequestHelper.extract_title_from_page(url)

    new_article = Article.new(user: current_user, url: fetched_url, title: title)

    if new_article.save
      flash[:success] = 'Saved successfully.'
    else
      flash[:error] = new_article.errors.full_messages.to_sentence
    end
    redirect_to :articles
  rescue => e
    flash[:error] = "There was an issue saving this URL. Please try again."
    redirect_to :articles
  end

  def destroy
    @article = Article.find_by(id: params[:id], user: current_user)
    if @article&.destroy
      flash[:success] = 'Marked as read successfully.'
    else
      flash[:error] = 'There was an issue marking this article as read.'
    end
    redirect_to :articles
  end

  def destroy_all
    articles_to_destroy = current_user.articles
    if articles_to_destroy&.destroy_all
      flash[:success] = 'Your reading list is now empty. 🍃'
    else
      flash[:error] = 'There was an issue clearing your reading list.'
    end
    redirect_to :articles
  end

  private

  def check_save_limit
    return unless current_user

    if !(current_user.subscribed? || current_user.early_adopter?) && current_user.articles.size >= Article::ARTICLES_LIMIT_ON_FREE_PLAN
      flash[:warning] = "You cannot save more than #{Article::ARTICLES_LIMIT_ON_FREE_PLAN} items on the free plan. #{view_context.link_to('Upgrade to Pro', "/account#subscription", { :class => "internal-link" })} to save more items."
      redirect_to :articles
    end
  end
end
