class TestsController < Simpler::Controller

  def index
    status 201
    render plain: "That's plain \n"
  end

  def create

  end

end
