# frozen_string_literal: true

require File.expand_path('config/environment', __dir__)

# custom_script.rb
puts 'Running custom script within the Rails environment'

def self.register_company(company_uuid, name)
  Rails.configuration.command_bus.call(
    Iam::RegisterCompany.new(
      company_uuid:,
      name:
    )
  )
end

def self.register_as_contact(user_uuid, company_uuid, first_name, last_name, email)
  Rails.configuration.command_bus.call(
    Iam::RegisterAsContact.new(
      user_uuid:,
      company_uuid:,
      name: { first_name:, last_name: },
      email:
    )
  )
end

def self.register_as_candidate(user_uuid, first_name, last_name, email)
  Rails.configuration.command_bus.call(
    Iam::RegisterAsCandidate.new(
      user_uuid:,
      name: { first_name:, last_name: },
      email:
    )
  )
end

def self.publish_job(job_uuid, contact_uuid)
  Rails.configuration.command_bus.call(
    JobDrafting::PublishJob.new(
      job_uuid:,
      contact_uuid:,
      title: 'Software Engineer',
      description: 'We are looking for a software engineer to join our team',
      dress_code_requirements: 'Casual',
      shift_duration: { starts_on: 1.day.from_now, ends_on: 2.days.from_now },
      spots: 3,
      wage_per_hour: 10.85.to_d,
      work_location: {
        street: 'Main Street',
        house_number: '123',
        city: 'New York',
        zip_code: '10001'
      }
    )
  )
end

def self.submit_change_request(job_uuid, change_request_uuid, contact_uuid)
  Rails.configuration.command_bus.call(
    JobDrafting::SubmitSpotsChangeRequest.new(
      change_request_uuid:,
      job_uuid:,
      contact_uuid:,
      requested_spots: 1
    )
  )
end

def self.candidate_applies(job_uuid, candidate_uuid, application_uuid, motivation)
  Rails.configuration.command_bus.call(
    JobFulfillment::Apply.new(
      job_uuid:,
      candidate_uuid:,
      application_uuid:,
      motivation:
    )
  )
end

def self.withdraw_application(job_uuid, candidate_uuid, application_uuid)
  Rails.configuration.command_bus.call(
    JobFulfillment::WithdrawApplication.new(
      job_uuid:,
      candidate_uuid:,
      application_uuid:
    )
  )
end

def self.accept_application(job_uuid, application_uuid, contact_uuid)
  Rails.configuration.command_bus.call(
    JobFulfillment::AcceptApplication.new(
      job_uuid:,
      application_uuid:,
      contact_uuid:
    )
  )
end

def self.reject_application(job_uuid, application_uuid, contact_uuid)
  Rails.configuration.command_bus.call(
    JobFulfillment::RejectApplication.new(
      job_uuid:,
      application_uuid:,
      contact_uuid:
    )
  )
end

company_uuid = SecureRandom.uuid
contact_uuid = SecureRandom.uuid

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

puts '##### Registering candidates'
register_company(company_uuid, 'Example Inc.')
register_as_contact(contact_uuid, company_uuid, 'Peter', 'Peterson', 'pp@example.com')
register_as_candidate(first_candidate_uuid, 'John', 'Doe', 'john.doe@example.com')
register_as_candidate(second_candidate_uuid, 'Jane', 'Doe', 'jane.doe@example.com')
register_as_candidate(third_candidate_uuid, 'Alice', 'Smith', 'alice.smith@example.com')
register_as_candidate(fourth_candidate_uuid, 'Bob', 'Smith', 'bob.smith@example.com')

puts '##### Publishing a job, fulfilling the job and submitting a change request'
publish_job(job_uuid, contact_uuid)

puts '##### A first candidate applies for the job'
candidate_applies(job_uuid, first_candidate_uuid, first_application_uuid, 'I am a great fit for this job')
puts '##### A second candidate applies for the job'
candidate_applies(job_uuid, second_candidate_uuid, second_application_uuid, 'I want to work for this company')
puts '##### A third candidate applies for the job'
candidate_applies(job_uuid, third_candidate_uuid, third_application_uuid, 'My skills are a great match for this job')
puts '##### A fourth candidate applies for the job'
candidate_applies(job_uuid, fourth_candidate_uuid, fourth_application_uuid, 'I like the company culture')
puts ''

puts '##### The first application gets accepted'
accept_application(job_uuid, first_application_uuid, contact_uuid)
puts '##### The the second application is withdrawn'
withdraw_application(job_uuid, second_candidate_uuid, second_application_uuid)
puts '##### The third application gets accepted'
accept_application(job_uuid, third_application_uuid, contact_uuid)
puts '##### The fourth application gets rejected'
reject_application(job_uuid, fourth_application_uuid, contact_uuid)
puts ''

puts '##### A change request is submitted to change the spots from 3 to 1'
submit_change_request(job_uuid, change_request_uuid, contact_uuid)

puts 'script completed'
