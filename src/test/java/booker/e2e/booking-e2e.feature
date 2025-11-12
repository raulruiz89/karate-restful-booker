  @e2e @regression
  Feature: /booking - End-to-end flow create-read-patch-read-delete-verify

  Background: Common test configuration and setup
    # Global configuration
    * url baseUrl
    * configure headers = headers

    # Load utility functions
    * def utils = read('classpath:booker/common/utils.js')()

  Scenario: Complete E2E flow for /booking
    # Create booking using reusable helper
    * def create = call read('classpath:booker/common/create-booking.feature') { opts: {} }
    * def id = create.bookingId
    
    # Validate creation response schema
    * match create.response == read('classpath:schemas/booking/booking-create-response.schema.json')

    # Contract validation of GET /booking/{id}
    Given path 'booking', id
    When method get
    Then status 200
    And match response == read('classpath:schemas/booking/booking.schema.json')

    # Partial update (PATCH) booking
    # Get auth token for patch operation
    * def auth = call read('classpath:booker/common/auth.feature@getToken')
    * def authCookie = 'token=' + auth.token
    * configure headers = { Accept: 'application/json', 'Content-Type': 'application/json', Cookie: '#(authCookie)' }

    # Patch and validate response
    * def patchBody = read('classpath:testdata/booking/booking-patch.json')
    Given path 'booking', id
    And request patchBody
    When method patch
    Then status 200
    And match response.firstname == patchBody.firstname
    And match response.additionalneeds == patchBody.additionalneeds

    # Get and validate patched values (no auth needed for GET)
    * configure headers = { Accept: 'application/json', 'Content-Type': 'application/json' }
    Given path 'booking', id
    When method get
    Then status 200
    And match response.firstname == patchBody.firstname
    And match response.additionalneeds == patchBody.additionalneeds

    # Delete booking
    * configure headers = { Accept: 'application/json', 'Content-Type': 'application/json', Cookie: '#(authCookie)' }
    Given path 'booking', id
    When method delete
    Then status 201

    # Verify 404
    Given path 'booking', id
    When method get
    Then status 404