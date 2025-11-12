Feature: Create booking helper

  Background:
    * url baseUrl
    * configure headers = headers
    * def utils = read('classpath:booker/common/utils.js')()

  @ignore
  Scenario: Create booking
    * def opts = typeof opts != 'undefined' ? opts : {}
    * def payload = utils.buildBooking(opts)
    Given path 'booking'
    And request payload
    When method post
    Then status 200
    * def bookingId = response.bookingid