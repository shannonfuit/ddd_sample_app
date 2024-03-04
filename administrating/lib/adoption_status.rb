# frozen_string_literal: true

module Administrating
  class AdoptionStatus < ValueObject
    attr_reader :vet_approval, :behavior_test_results, :vaccinated, :chipped

    def initialize(vet_approval, behavior_test_results, vaccinated, chipped)
      super
      @vet_approval = vet_approval
      @behavior_test_results = behavior_test_results
      @vaccinated = vaccinated
      @chipped = chipped
    end

    def complete_and_approved_for_placement?
      vet_approval && behavior_test_results_passed? && vaccinated? && chipped?
    end

    private

    def behavior_test_results_passed?
      # Logic to determine if behavior test results pass
      # For example, assuming behavior_test_results is an array of results
      behavior_test_results.size >= 3
    end

    def vaccinated?
      vaccinated == true
    end

    def chipped?
      chipped == true
    end
  end
end
