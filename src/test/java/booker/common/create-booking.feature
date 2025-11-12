Feature: Create booking helper

  Background:
    # Inherit configuration from parent feature (expects baseUrl, headers, token already configured)
    * url baseUrl
    * configure headers = headers
    * def utils = read('classpath:booker/common/utils.js')()

  @ignore
  Scenario: Create booking
    # Accept optional parameters
    * def opts = typeof opts != 'undefined' ? opts : {}
    * def payload = utils.buildBooking(opts)
    Given path 'booking'
    And request payload
    When method post
    Then status 200
    * def bookingId = response.bookingid