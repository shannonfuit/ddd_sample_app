# frozen_string_literal: true
# # frozen_string_literal: true

# require_relative 'test_helper'

# module JobFulfillment
#   class ChangeSpotsTest < DomainTest
#     def setup
#       super
#       @change_request_uuid = SecureRandom.uuid
#       @motivation = 'I want to work here'

#       arange_open_job_with_applications
#     end

#     test 'the number of spots can be changed to the requested amount' do
#       published = act(@stream, change_spots_command)
#       expected_events = [spots_changed_as_requested_event]

#       assert_events(published, expected_events)
#     end

#     test 'the number of spots is changed to the minimum required amount' do
#       arrange_another_candidate_applied

#       published = act(@stream, change_spots_command)
#       expected_events = [spots_changed_to_minimum_required_event]

#       assert_events(published, expected_events)
#     end

#     test 'it validates the input of the command' do
#       assert_raises(Infra::Command::Invalid) do
#         invalid_change_spots_command
#       end
#     end

#     private

#     # commands
#     def change_spots_command
#       ChangeSpots.new(
#         job_uuid: @uuid,
#         change_request_uuid: @change_request_uuid,
#         spots: 1
#       )
#     end

#     def invalid_change_spots_command
#       ChangeSpots.new(
#         job_uuid: @uuid
#       )
#     end

#     # build aggregate
#     def arange_open_job_with_applications
#       arrange_job_opened
#       arrange(@stream, [candidate_applied, application_accepted_event])
#     end

#     def arrange_another_candidate_applied
#       arrange(@stream, [another_candidate_applied, another_application_accepted_event])
#     end

#     # events
#     def candidate_applied
#       CandidateApplied.new(
#         data:
#         {
#           job_uuid: @uuid,
#           application_uuid: @application_uuid,
#           candidate_uuid: @candidate_uuid,
#           motivation: @motivation
#         }
#       )
#     end

#     def another_candidate_applied
#       CandidateApplied.new(
#         data:
#         {
#           job_uuid: @uuid,
#           application_uuid: @another_application_uuid,
#           candidate_uuid: @another_candidate_uuid,
#           motivation: @motivation
#         }
#       )
#     end

#     def application_accepted_event
#       ApplicationAccepted.new(
#         data: {
#           job_uuid: @uuid,
#           application_uuid: @application_uuid,
#           contact_uuid: @contact_uuid
#         }
#       )
#     end

#     def another_application_accepted_event
#       ApplicationAccepted.new(
#         data: {
#           job_uuid: @uuid,
#           application_uuid: @another_application_uuid,
#           contact_uuid: @contact_uuid
#         }
#       )
#     end

#     def spots_changed_as_requested_event
#       SpotsChangedAsRequested.new(
#         data: {
#           job_uuid: @uuid,
#           change_request_uuid: @change_request_uuid,
#           spots: 1,
#           available_spots: 0
#         }
#       )
#     end

#     def spots_changed_to_minimum_required_event
#       SpotsChangedToMinimumRequired.new(
#         data: {
#           job_uuid: @uuid,
#           change_request_uuid: @change_request_uuid,
#           spots: 2,
#           available_spots: 0
#         }
#       )
#     end
#   end
# end
