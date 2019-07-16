require 'open-uri'
require 'csv'

# file structure
# "countryname","source","ocid","title","description","predicted_proclass","pc_level1","pc_level2","pc_level3","mapped_cpv_code","mapped_cpv_heading"
class VolumeOppsFileRetriever
  include ApplicationHelper

  def call(filename)
    opportunities = CSV.new(open(filename))
    opportunities.each_with_index do |opp, index|
      next if index == 0
      ocid = opp[2]
      cpv_id = opp[9].split('-')[0]
      cpv_desc = opp[10]
      proclass = opp[5]
      pc1 = opp[6]
      pc2 = opp[7]
      pc3 = opp[8]

      opp = Opportunity.where(ocid: ocid).first
      # if we have fetched this opportunity already, update the CPV/proclass mappings
      if opp && opp.response_due_on > Time.zone.now
        opportunity_cpv = OpportunityCpv.new(
            industry_id: cpv_id.to_s + ':' + cpv_desc + ':OO_PREDICTED',
            industry_scheme: 'cpv_predicted',
            opportunity_id: opp.id,
        )
        proclass_code = OpportunityCpv.new(
            industry_id: "#{proclass}:#{pc1}:#{pc2}:#{pc3}:PC_OO_PREDICTED",
            industry_scheme: 'proclass_predicted',
            opportunity_id: opp.id,
        )
        opportunity_cpv.save!
        proclass_code.save!

        # output the URL where we can find this opp
        puts "#{Figaro.env.DOMAIN}/export-opportunities/opportunities/#{opp.slug}"
      end
    end
  end
end