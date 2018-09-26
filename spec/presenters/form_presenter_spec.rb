# coding: utf-8
require 'rails_helper'

RSpec.describe FormPresenter do
  describe '#initialize' do
    skip 'TODO...'
    it 'does something' do
    end
  end

  describe '#hidden_fields' do
    skip 'TODO...'
    it 'does something' do
    end
  end

  describe '#input_checkbox' do
    skip 'TODO...'
    it 'does something' do
    end
  end

  describe '#input_checkbox_group' do
    skip 'TODO...'
    it 'does someting' do
    end
  end

  describe '#input_date_selector' do
    skip 'TODO...'
    it 'does something' do
    end
  end

  describe '#input_multi_currency_amount' do
    skip 'TODO...'
    it 'does something' do
    end
  end

  describe '#input_radio' do
    skip 'TODO...'
    it 'does something' do
    end
  end

  describe '#input_select' do
    skip 'TODO...'
    it 'does something' do
    end
  end

  describe '#input_text' do
    skip 'TODO...'
    it 'does something' do
    end
  end

  describe '#input_textarea' do
    skip 'TODO...'
    it 'does something' do
    end
  end

  describe '#input_label' do
    skip 'TODO...'
    it 'does something' do
    end
  end

  describe '#field_exists?' do
    skip 'TODO...'
    it 'does something' do
    end
  end

  # Testing private methods

  describe '::field_id' do
    it 'Returns lowercase string with alphanumeric+hyphen characters only' do
      presenter_1 = FormPresenter.new({}, {})
      presenter_2 = FormPresenter.new({}, {view: 'viewname'})

      expect(presenter_1.send(:field_id, 'This -  [is]    a_string')).to eql('this-is-a-string')
      expect(presenter_2.send(:field_id, 'This -  [is]    a_string')).to eql('viewname-this-is-a-string')
    end

    it 'Should not return an id starting with hyphen' do
      presenter_1 = FormPresenter.new({}, {})
      presenter_2 = FormPresenter.new({}, {view: '-viewname'})

      expect(presenter_1.send(:field_id, '-foo')).to eql('foo')
      expect(presenter_2.send(:field_id, '-foo')).to eql('viewname-foo')
    end
  end

  describe '::clean_str' do
    it 'Returns lowercase string with alphanumeric+underscore characters only.' do
      presenter = FormPresenter.new({}, {})

      expect(presenter.send(:clean_str, 'This -  [is]    a_string')).to eql('this_is_a_string')
    end
  end

  describe '::label' do
    skip 'TODO...'
    it 'does something' do
    end
  end

  describe '::option_item' do
    skip 'TODO...'
    it 'does something' do
    end
  end

  describe '::prop' do
    skip 'TODO...'
    it 'does something' do
    end
  end

  describe '::field_content' do
    skip 'TODO...'
    it 'does something' do
    end
  end
end
