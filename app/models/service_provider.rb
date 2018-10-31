class ServiceProvider < ApplicationRecord
  has_many :editors
  belongs_to :country

  def sign_off_line
    if partner
      "Express your interest to the #{partner} in #{country.name}.
       The #{partner} is our chosen partner to deliver trade services in #{country.name}."
    else
      if name == 'DFID'
        'For more information and to make a bid you will need to go to the third party website.'
      elsif name == 'DIT HQ' # source will always be post
        'Express your interest to the Department for International Trade.'
      elsif ['DIT Education', 'DSO HQ', 'DSO RD West 2 / NATO',
          'Occupied Palestinian Territories Jerusalem', 'UKEF', 'UKREP',
          'United Kingdom LONDON', 'USA AFB', 'USA OBN OCO', 'USA OBN Sannam S4'].include?(name)
        'Express your interest to the Department for International Trade.'
      elsif name.include?('OBNI') && country.region.name.include?('Africa')
        'Express your interest to the Department for International Trade team in Africa.'
      elsif name.include?('United States') && country.region.name.include?('America')
        'Express your interest to the Department for International Trade team in USA.'
      elsif name.include?('Canada') && country.region.name.include?('America')
        'Express your interest to the Department for International Trade team in Canada.'
      end
    end
  end
end
