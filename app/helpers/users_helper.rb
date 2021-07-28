module UsersHelper
  # Returns the gravatar for a given user
  def gravatar_for(user, size: 80)
    gravatar_url = "https://secure.gravatar.com/avatar/#{Digest::MD5.hexdigest(user.email)}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: 'gravatar')
  end
end
