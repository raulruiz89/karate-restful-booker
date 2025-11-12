@security
Feature: /Basic security tests for /booking endpoint

  Background:    
    * url baseUrl
    * configure headers = headers
    * def utils = read('classpath:booker/common/utils.js')()
    
  Scenario: auth token with invalid credentials
    Given path 'auth'
    And request { username: username, password: 'badpass' }
    When method post
    Then status 200
    And match response == { token: '#notpresent', reason: '#string' }

  Scenario: defend against basic injection in booking creation
    * def payload = { firstname: "' OR '1'='1", lastname: '<script>alert(1)</script>', totalprice: 11, depositpaid: true, bookingdates: { checkin: '2025-11-09', checkout: '2025-11-11' }, additionalneeds: 'x' }
    Given path 'booking'
    And request payload
    When method post
    Then status 200
    * def id = response.bookingid
    Given path 'booking', id
    When method get
    Then status 200
    And match response.firstname == payload.firstname
    And match response.lastname == payload.lastname
    # For substring checks, convert JSON to string representation
    * def resText = karate.pretty(response)
    And match resText !contains 'Exception'
    And match resText !contains 'Stack trace'

  Scenario: trying to update booking without token
    # create booking via reusable helper
    * def create = call read('classpath:booker/common/create-booking.feature') { opts: {} }
    * def id = create.bookingId
    # ensure no token is sent for this negative security scenario
    * configure headers = { Accept: 'application/json', 'Content-Type': 'application/json' }
    Given path 'booking', id
    And request { firstname: 'Hack' }
    When method patch
    Then status 403