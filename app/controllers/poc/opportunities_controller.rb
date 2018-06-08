class Poc::OpportunitiesController < OpportunitiesController
  prepend_view_path 'app/views/poc'

  FIELD_VALUES_WHY = %w[sample sell distribute use].freeze
  POC_OPPORTUNITY_PROPS = %w[what why need industry keywords value specifications respond_by respond_to link].freeze
  def international
    render layout: 'poc/layouts/international'
  end

  def new
    step = 'step_1'
    content = get_content('opportunities/new.yml')
    @content = content[step]
    @process = {
      view: step,
      entries: {},
      errors: {},
    }
    
    render layout: 'poc/layouts/form'
  end

  def create
    @content = get_content('opportunities/new.yml')
    @process = {
      view: params[:view],
      entries: {},
      errors: {},
    }

    # Record any user entries (not in DB at this point).
    process_add_user_entries

    # Reverse order is intentional.
    process_step_three
    process_step_two
    process_step_one

    if @process[:view] == 'complete'
      # TODO: Something to save opportunity in DB
      render layout: 'poc/layouts/international'
    else
      render 'opportunities/new', layout: 'poc/layouts/form'
    end
  end

  def edit
  end

  private def process_add_user_entries
    POC_OPPORTUNITY_PROPS.each do |prop|
      @process[:entries][prop] = params[prop]
    end
  end

  private def process_step_one
    if @process[:view].eql? 'step_1'
      # TODO: Validate step_1 entries
      # If errors view should remain as step_1

      view = 'step_2'
      case @process[:entries]['what']
      when '1'
        content = 'step_2.1'
      when '2'
        content = 'step_2.2'
      when '3'
        content = 'step_2.3'
      when '4'
        content = 'step_2.4'
      else
        view = 'step_1'
        content = 'step_1'
      end

      @content = @content[content]
      @process[:view] = view
    end
  end

  private def process_step_two
    if @process[:view].eql? 'step_2'
      # TODO: Validate step_2 entries
      # If errors view should remain as step_2

      @content = @content['step_3']
      @process[:view] = 'step_3'
    end
  end

  private def process_step_three
    if @process[:view].eql? 'step_3'
      # TODO: Validate step_3 entries
      # If errors view should remain as step_3

      @process[:view] = 'complete' # TODO: Where/what?
    end
  end
end
