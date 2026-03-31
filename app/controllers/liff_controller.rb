class LiffController < ApplicationController
  def index
    @tags = Tag.all
    render layout: false
  end
end
