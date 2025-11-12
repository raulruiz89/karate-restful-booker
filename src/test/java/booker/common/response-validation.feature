Feature: Get booking by id and print details

  Background: Common test configuration and setup
    # Global configuration
    * url baseUrl
    * configure headers = headers

  @ignore
  Scenario: Get booking by id and print details
    Given path 'booking', id
    When method get
    Then status 200
    And match response == { firstname: '#string', lastname: '#string', totalprice: '#number', depositpaid: '#boolean', bookingdates: { checkin: '#regex ^\\d{4}-\\d{2}-\\d{2}$', checkout: '#regex ^\\d{4}-\\d{2}-\\d{2}$' }, additionalneeds: '#string' }

    And match response.firstname == firstname
    And match response.lastname == lastname
    * print 'Validated Booking:', id, '->', firstname, lastname