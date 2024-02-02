require 'application_system_test_case'
require 'mocha/minitest'

class Internal::AnimalsSystemTest < ApplicationSystemTestCase
  test 'register and view animal' do
    registration_number = SecureRandom.uuid
    Internal::AnimalsController.any_instance.stubs(:generate_registration_number).returns(registration_number)
    # Step 1: Go to the index page and assert it is empty
    visit internal_animals_path
    assert_selector 'table tbody tr', count: 0

    # Step 2: Click on the "New Animal" link on the index page
    click_on 'Register Animal'
    assert_current_path new_internal_animal_path

    # Submit an empty form and let it fail, it should rerender the form
    click_on 'Register Animal'
    assert_current_path new_internal_animal_path

    # Fill in the required fields and submit the form
    # find(page, text: 'New Animal')
    save_and_open_page
    registered_by = 'John Doe'
    fill_in 'Registered by', with: registered_by
    click_on 'Register Animal'

    # Step 3: Assert that the show page displays the registration number and registered by
    # puts 'second time'
    assert_text "Registration Number: #{registration_number}"
    assert_text "Registered By: #{registered_by}"

    # Step 4: Go back to the index page and assert that the registered animal is listed
    click_on 'Back to Animal List'
    assert_selector 'table tbody tr', count: 1
    assert_selector 'table tbody tr td', text: registration_number
    assert_selector 'table tbody tr td', text: registered_by
  end
end
