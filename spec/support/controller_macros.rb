# https://github.com/plataformatec/devise/wiki/How-To:-Test-controllers-with-Rails-3-and-4-(and-RSpec)#controller-specs
module ControllerMacros
  def login_editor(role: :user)
    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:editor]
      editor = FactoryGirl.create(role)
      editor.confirm
      sign_in editor
    end
  end
end
