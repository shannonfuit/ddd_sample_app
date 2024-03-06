# frozen_string_literal: true

require File.expand_path('config/environment', __dir__)

# custom_script.rb
puts 'Running custom script within the Rails environment'

job_uuid = SecureRandom.uuid
change_request_uuid = SecureRandom.uuid

first_candidate_uuid = SecureRandom.uuid
first_application_uuid = SecureRandom.uuid

second_candidate_uuid = SecureRandom.uuid
second_application_uuid = SecureRandom.uuid

third_candidate_uuid = SecureRandom.uuid
third_application_uuid = SecureRandom.uuid

fourth_candidate_uuid = SecureRandom.uuid
fourth_application_uuid = SecureRandom.uuid

puts '##### Publishing a job'
Rails.configuration.command_bus.call(
  JobDrafting::PublishJob.new(
    job_uuid:,
    title: 'Software Engineer',
    description: 'We are looking for a software engineer to join our team',
    dress_code_requirements: 'Casual',
    shift_duration: { starts_on: 1.day.from_now, ends_on: 2.days.from_now },
    spots: 3,
    wage_per_hour: 10.85.to_d,
    work_location: {
      street: 'Main Street',
      house_number: 123,
      city: 'New York',
      zip_code: '10001'
    }
  )
)

puts '##### A candidate applies for the job'
Rails.configuration.command_bus.call(
  JobFulfillment::Apply.new(
    job_uuid:,
    candidate_uuid: first_candidate_uuid,
    application_uuid: first_application_uuid,
    motivation: 'I am a great fit for this job'
  )
)
# another candidate applies for the job
puts '##### A second candidate applies for the job'
Rails.configuration.command_bus.call(
  JobFulfillment::Apply.new(
    job_uuid:,
    candidate_uuid: second_candidate_uuid,
    application_uuid: second_application_uuid,
    motivation: 'I want to work for this company'
  )
)

puts '##### A third applies for the job'
Rails.configuration.command_bus.call(
  JobFulfillment::Apply.new(
    job_uuid:,
    candidate_uuid: third_candidate_uuid,
    application_uuid: third_application_uuid,
    motivation: 'My skills are a great match for this job'
  )
)

puts '##### A fourth candidate applies for the job'
Rails.configuration.command_bus.call(
  JobFulfillment::Apply.new(
    job_uuid:,
    candidate_uuid: fourth_candidate_uuid,
    application_uuid: fourth_application_uuid,
    motivation: 'I like the company culture'
  )
)

puts '##### The first application gets accepted'
Rails.configuration.command_bus.call(
  JobFulfillment::AcceptApplication.new(
    job_uuid:,
    application_uuid: first_application_uuid
  )
)

puts '##### The the second application is withdrawn'
Rails.configuration.command_bus.call(
  JobFulfillment::WithdrawApplication.new(
    job_uuid:,
    candidate_uuid: second_candidate_uuid,
    application_uuid: second_application_uuid
  )
)

puts '##### the third application gets accepted'
Rails.configuration.command_bus.call(
  JobFulfillment::AcceptApplication.new(
    job_uuid:,
    application_uuid: third_application_uuid
  )
)

puts '##### the fourth application gets rejected'
Rails.configuration.command_bus.call(
  JobFulfillment::RejectApplication.new(
    job_uuid:,
    application_uuid: fourth_application_uuid
  )
)

puts '##### A change request is submitted to change the spots from 3 to 1'
Rails.configuration.command_bus.call(
  JobDrafting::SubmitSpotsChangeRequest.new(
    spots_change_request_uuid: change_request_uuid,
    job_uuid:,
    current_spots: 3, # TODO: remove this field
    requested_spots: 1
  )
)

puts 'Custom script completed'
