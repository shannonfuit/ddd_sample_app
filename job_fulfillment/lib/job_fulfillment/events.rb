module JobFulfillment
  class JobCreated < Infra::Event
  end

  class CandidateApplied < Infra::Event
  end

  class ApplicationWithdrawn < Infra::Event
  end

  class ApplicationRejected < Infra::Event
  end

  class ApplicationAccepted < Infra::Event
  end

  class ApplicationConfirmed < Infra::Event
  end

  class ApplicationCancelled < Infra::Event
  end
end
