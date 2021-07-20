# frozen_string_literal: true

module Api
  # CpvLookupController
  class CpvLookupController < ApplicationController
    skip_before_action :verify_authenticity_token, raise: false

    def search
      return not_found unless (term = params[:description])
      # binding.pry
      results = Cn2019.search(query(term)).records

      respond_to do |format|
        format.json { render status: :ok, json: results }
      end
    end

    private

    def not_found
      render status: :not_found, json: { 'detail': 'Not found' }
    end

    def query(term)
      {
        'size': 100,
        'query': {
          'simple_query_string': {
            'query': term,
            'fields': ['description^5', 'english_text', 'parent_description']
          }
        }
      }
    end
  end
end
