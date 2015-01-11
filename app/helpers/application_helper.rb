module ApplicationHelper

  def active_page(controller_name, action_name = false)
    controller_name == params[:controller] && (action_name === false || action_name == params[:action])
  end

  class Post
    def self.post_public_title(post, delimiter=',')
      post_title = post.title.to_s
      if (post.date_from.to_s.length > 0)
        str_date_from = post.date_from.strftime('%d/%m/%Y')
        post_title += delimiter.to_s + ' ' + str_date_from
        if (post.date_to.to_s.length > 0 && post.date_to.strftime('%d/%m/%Y') != str_date_from )
          post_title += ' - ' + post.date_to.strftime('%d/%m/%Y')
        end
      end
      return post_title
    end

    def self.post_autocomplite_title(post)
      self.post_public_title(post, '(') + '<span class="post-id">'+post.id.to_s+'</span>)'

    end
  end


  class Number

    def self.pixels(number)
      number.to_i/(1000*1000).round
    end

  end
end
