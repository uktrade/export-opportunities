namespace :enquiries do
  desc 'Send an email to a sample of users who made enquiries in the given period'
  task :request_feedback, %i[start_date end_date sample_size] => [:environment] do |_, args|
    puts "Preparing to email a random sample of up to #{args[:sample_size]} users who made enquiries between #{args[:start_date]} and midnight on #{args[:end_date]}."
    puts 'Enquiries that have already received feedback requests will be excluded, as will users who have opted out of giving feedback.'
    puts

    puts 'Press Ctrl-C to abort or ⏎ to continue:'
    $stdin.gets

    puts 'Proceeding...'
    puts

    enquiries = EnquiryFeedbackSurveySender.new.call
    if enquiries.count.zero?
      puts 'No eligible enquiries were found: no emails sent.'
    else
      puts "Emailed #{ActionController::Base.helpers.pluralize(enquiries.count, 'user')}."
    end

    puts
  end
end
