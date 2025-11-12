    @contract @regression
Feature: /Contract tests for /booking endpoint

  Background:
    # Global configuration
    * url baseUrl
    * configure headers = headers
  Scenario: Schema de GET /booking/{id}
    # Get a booking ID first
    Given path 'booking'
    When method get
    Then status 200
    # Obtain a booking id deterministically: create one (always), then prefer existing list if available
    * def created = call read('classpath:booker/common/create-booking.feature') { opts: {} }
    * def id = response.length > 0 ? response[0].bookingid : created.bookingId
    # response content-type should be JSON
    * match responseHeaders['Content-Type'][0] contains 'application/json'

    # Now get booking by ID and validate schema
    Given path 'booking', id
    When method get
    Then status 200
    * match responseHeaders['Content-Type'][0] contains 'application/json'
    And match response == read('classpath:schemas/booking/booking.schema.json')

  Scenario: Schema de POST /booking
    * def payload = read('classpath:testdata/booking/booking-create.json')
    Given path 'booking'
    And request payload
    When method post
    Then status 200
    # response content-type should be JSON
    * match responseHeaders['Content-Type'][0] contains 'application/json'
    And match response == read('classpath:schemas/booking/booking-create-response.schema.json')