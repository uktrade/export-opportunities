require 'rails_helper'

RSpec.describe OppsQualityValidator do
  describe '#validate_each' do
    it 'quality scores an opportunity with a spelling error' do
      opportunity = create(:opportunity, title: "eror", description: "correct")

      OppsQualityValidator.new.validate_each(opportunity)

      opportunity_check = OpportunityCheck.first

      expect(opportunity_check.offensive_term).to eq('eror')
      expect(opportunity_check.suggested_term).to eq("error")
    end

    it 'quality scores an opportunity with no spelling errors' do
      opportunity = create(:opportunity, description: "The Authority is seeking a supplier to provide Display Units for installation on new Bus stop poles. The Display Units shall be provided in 2 sizes, be double sided and be capable of rotating 360 degrees on the Bus Stop Pole. The height of the Display Unit should be adjustable. Typical heights from ground level to the underside of the visible printed area of the Display Unit shall be between 0.9m and 1.5m. The Display Units will be used to display bus travel information on printed waterproof material. The Display Units shall facilitate the multiple interchange of information sheets as required by the Authority over the life of the Display Unit. The Display Units shall be suitable for use in exposed conditions, both inland and in coastal locations. The following sizes of double faced units are required: — Size 1 — To accommodate document size 220 mm width x 907mm (with a visible area of 195mm width x 882mm height); and — Size 2 — To accommodate document size 220mm width x 594mm (with a visible area of 195mm width x 569mm height). The Display Unit design shall be capable of facilitating the replacement of the Display Units without necessity for replacement of the Bus Stop Pole. The scope includes the delivery of the Display Units, and training of the Authority's nominated contractors on how to install, use and maintain the Display Units to achieve the highest performance and design life of the product.")

      OppsQualityValidator.new.validate_each(opportunity)

      opportunity_check = OpportunityCheck.first

      expect(opportunity_check.score).to be >= 99
    end

    it 'accepts british spelling' do
      opportunity = create(:opportunity, title: "monetise realise", description: "theatre fibre")

      OppsQualityValidator.new.validate_each(opportunity)

      opportunity_check = OpportunityCheck.first

      expect(opportunity_check.score).to eq(100)
    end

    it 'also, unfortunately, still accepts US spelling' do
      opportunity = create(:opportunity, title: "monetize realize", description: "theater fiber")

      OppsQualityValidator.new.validate_each(opportunity)

      opportunity_check = OpportunityCheck.first

      expect(opportunity_check.score).to eq(100)
    end

    it 'quality scores an opportunity with a spelling error in description, assigning correct boundaries to the suggested term' do
      opportunity = create(:opportunity, title: 'A sample title', description: 'permeate should not be spelled as permeat. This is a difficult word to spell.')

      OppsQualityValidator.new.validate_each(opportunity)

      opportunity_check = OpportunityCheck.first
      offset = opportunity_check.offset
      length = opportunity_check.length

      expect("#{opportunity.title} #{opportunity.description}"[offset...offset+length]).to eq('permeat')
    end

    it 'quality scores an opportunity with a spelling error in the first word of description' do
      opportunity = create(:opportunity, title: 'A sample title', description: 'permeat is wrong. This is a difficult word to spell.')

      OppsQualityValidator.new.validate_each(opportunity)

      opportunity_check = OpportunityCheck.first
      offset = opportunity_check.offset
      length = opportunity_check.length

      expect("#{opportunity.title} #{opportunity.description}"[offset...offset+length]).to eq('permeat')
    end

    it 'quality scores an opportunity with a spelling error in the title' do
      opportunity = create(:opportunity, title: 'onomatopiia', description: 'onomatopoeia is the toughest spelling bee word ever.')

      OppsQualityValidator.new.validate_each(opportunity)

      opportunity_check = OpportunityCheck.first
      offset = opportunity_check.offset
      length = opportunity_check.length

      expect("#{opportunity.title} #{opportunity.description}"[offset...offset+length]).to eq('onomatopiia')
    end
  end
end


