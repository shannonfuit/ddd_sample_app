# frozen_string_literal: true

module Customer
  def self.configure(event_store)
    event_store.subscribe(JobEventHandlers::OnJobPublished.new, to: [JobDrafting::JobPublished])
    event_store.subscribe(JobEventHandlers::OnJobUnpublished.new, to: [JobDrafting::JobUnpublished])
    event_store.subscribe(JobEventHandlers::OnSpotsChangedOnJob.new, to: [JobDrafting::SpotsChangedOnJob])
    event_store.subscribe(CandidateEventHandlers::OnCandidateRegistered.new, to: [Iam::CandidateRegistered])
    event_store.subscribe(CompanyEventHandlers::OnCompanyRegistered.new, to: [Iam::CompanyRegistered])
  end
end
