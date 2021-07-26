class ApplicationController < ActionController::Base
  def hello
    render html: 'Bonjour monde'
  end
end
