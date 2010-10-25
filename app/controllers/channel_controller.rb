require 'jeweli_url'
class ChannelController < ApplicationController

  def home
    @channels = Channel.all_public
    render :template => "templates/index"
  end
  
  def index
    
    jeweli_url = JeweliUrl.new params
  
    @channel = jeweli_url.channel
    # We don't have a channel that matches the renders_with param
    # so we assume they intend to have a matching template in the templates directory.
    # In the future we should check to see if the template exists first.
    return render(:template => "templates/#{params[:renders_with]}") unless @channel
    @render_as = @channel.render_as || @channel
    
    if jeweli_url.is_channel_page?
      @categories = @channel.categories
      @articles = (request.format.html?) ? @channel.articles.published.paginate(:page => params[:page]): @channel.articles.published
    elsif jeweli_url.is_category_page?
      @category = jeweli_url.category
      @categories = [@category]
      @articles = (request.format.html?) ? @category.articles.published.paginate(:page => params[:page]) : @category.articles.published
    elsif jeweli_url.is_article_page?
      @article = jeweli_url.article
      return render(:action => :article_by_slug)
    end
    
    respond_to do |wants|
      wants.html
      wants.rss
    end
  end
  
  def category_by_slug
    @channel = Channel.all_public.find_by_slug(params[:channel_slug])
    return redirect_to '/404.html' unless @channel
    @render_as = @channel.render_as || @channel
    @category = @channel.categories.find_by_slug(params[:category_slug])
    @categories = [@category]
    
    respond_to do |wants|
      wants.html { 
        @articles = @category.articles.published.paginate(:page => params[:page]) 
        render(:action => :index)
      }
      wants.rss { 
        @articles = @category.articles.published 
        render(:action => :index)
      }
    end
  end
  
  def article_by_slug
    @channel = Channel.all_public.find_by_slug(params[:renders_with])
    @article = Article.find_by_slug(params[:article_slug])    
    return render(:template => "templates/#{params[:renders_with]}") unless @channel

    # We do have a channel so 
    # follow the normal route of using
    # our built in template (views/channel/article_by_slug.html.erb)
    # to render the article
    @render_as = @channel.render_as || @channel
    
    respond_to do |wants|
      wants.html
    end
    
  end
  
end
