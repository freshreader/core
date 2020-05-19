class Api::V1::ArticlesController < Api::V1::BaseController
  def index
    articles = Article.where(user: current_user).sort_by(&:created_at).reverse
    render json: articles
  end

  def create
    ActiveRecord::Base.transaction do
      url = RequestHelper.url_from_param(params[:url])
      title, fetched_url = RequestHelper.extract_title_from_page(url)

      new_article = Article.new(user: current_user, url: fetched_url, title: title)

      if new_article.save
        render json: new_article, status: :created
      else
        render json: new_article.errors, status: :unprocessable_entity
      end
    end
  rescue
    render json: "There was an issue saving this URL.", status: :unprocessable_entity
  end

  def destroy
    article = Article.find_by(id: params[:id], user: current_user)

    unless article
      return render json: { error: 'article not found' }, status: :not_found
    end

    if article.destroy
      head :no_content
    else
      render json: article.errors, status: :internal_server_error
    end
  end
end

