class TestsController < Simpler::Controller

  def index
    status 201
    set_custom_headers ({ 'Custom-Header' => 'custom-value',
                          'Custom-Header-2' => 'custom-value-2' })
    render plain: "That's plain \n"
  end

  def create

  end

end
