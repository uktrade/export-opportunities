class Admin::EditorsController < Admin::BaseController
  rescue_from Pundit::NotAuthorizedError, with: :not_found
  include SortableHelper
  include FilterHelper
  EDITORS_PER_PAGE = 20

  def index
    @filters = EditorFilters.new(editor_filters)
    session[:editor_filters] = editor_filters

    query = EditorQuery.new(
      scope: Editor.all.includes(:service_provider),
      sort: @filters.sort,
      page: @filters.page,
      per_page: EDITORS_PER_PAGE,
      hide_deactivated: @filters.hide_deactivated,
      service_provider: @filters.service_provider
    )

    @editors = query.editors.includes(:service_provider)
    @service_providers = ServiceProvider.order(name: :asc)

    authorize @editors
    render layout: 'admin_transformed', locals: {
      content: get_content('admin/editors.yml'),
    }
  end

  def show
    @editor = Editor.find(id)
    authorize @editor
    render layout: 'admin_transformed', locals: {
      content: get_content('admin/editors.yml'),
    }
  end

  def edit
    @editor = Editor.find(id)
    @service_providers = ServiceProvider.select(:id, :name).order(name: :asc)
    @roles = editor_roles
    authorize @editor
    render layout: 'admin_transformed', locals: {
      content: get_content('admin/editors.yml'),
    }
  end

  def update
    @editor = Editor.find(id)
    authorize @editor
    if @editor.update(editor_params)
      redirect_to admin_editor_path(@editor), notice: 'Editor updated'
    else
      render :edit
    end
  end

  class EditorFilters
    attr_reader :name, :sort, :page, :email, :role, :confirmed_at, :last_sign_in_at, :service_provider, :hide_deactivated

    def initialize(params)
      @name = params[:name]
      @email = params[:email]
      @role = params[:role]
      @last_sign_in_at = params[:last_sign_in_at]
      @service_provider = params[:service_provider].to_i if params[:service_provider].present?
      @hide_deactivated = !params[:show_deactivated]

      @sort_params = params.fetch(:sort, {})

      @sort = EditorSort.new(default_column: 'name', default_order: 'asc')
        .update(column: @sort_params[:column], order: @sort_params[:order])

      @page = params[:paged]
    end
  end

  private

    def id
      params.require(:id)
    end

    def editor_params
      params.require(:editor).permit(:role, :service_provider_id)
    end

    def editor_filters
      params.permit({ sort: %i[column order] }, :name, :email, :role, :last_sign_in_at, :service_provider, :paged, :show_deactivated)
    end

    def editor_roles
      roles = []
      Editor.roles.each do |key, value|
        roles.push Role.new(key, value)
      end
      roles
    end

    class Role
      attr_reader :name, :value, :id

      def initialize(name, value)
        @name = name.capitalize
        @id = name.downcase
        @value = value
      end
    end
end
