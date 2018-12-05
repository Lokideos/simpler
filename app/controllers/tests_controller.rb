class TestsController < Simpler::Controller

  def index
    status 201
    set_custom_headers ({ 'Custom-Header' => 'custom-value',
                          'Custom-Header-2' => 'custom-value-2' })
    render plain: "That's plain \n"
  end

  def show
    render plain: "I'm show action\nThe id of this request is #{find_test_id}\n"
  end

  def create

  end

  private

  def find_test_id
    params["test_id"].to_i
  end

end
