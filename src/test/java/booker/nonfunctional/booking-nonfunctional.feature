@nonfunctional
Feature: /booking - non-functional tests (performance, resilience)

  Background: Common test configuration and setup
    # Global configuration
    * url baseUrl
    * configure headers = headers

    # Load utility functions
    * def utils = read('classpath:booker/common/utils.js')()

  Scenario: id get time response under 800ms
    Given path 'booking'
    When method get
    Then status 200
    * def id = response.length ? response[0].bookingid : 1
    Given path 'booking', id
    When method get
    Then status 200
    And assert responseTime < 800

  Scenario: average GET /booking/{id} time under 1200ms over 10 samples
    * def times = []
    # this loop calls the getOnce scenario 10 times and collects response times
    * def loop = function(){ for (var i = 0; i < 10; i++) { var res = karate.call('classpath:booker/nonfunctional/booking-nonfunctional.feature@getOnce'); times.push(res.t); } }
    * eval loop()
    * def avg = utils.mean(times)
    * print 'promedio (ms)=', avg, 'muestras=', times
    And assert avg < 1200

  @ignore @name=getOnce
  Scenario: GET /booking/{id} once (helper)
    Given path 'booking'
    When method get
    Then status 200
    * def id = response.length ? response[0].bookingid : 1
    Given path 'booking', id
    When method get
    Then status 200
    * def t = responseTime

  Scenario: resilience test - create and delete booking, confirm 404
    * def create = call read('classpath:booker/common/create-booking.feature') { opts: {} }
    * def id = create.bookingId

    # Get auth token for delete operation
    * def auth = call read('classpath:booker/common/auth.feature@getToken')
    * def authCookie = 'token=' + auth.token
    * configure headers = { Accept: 'application/json', 'Content-Type': 'application/json', Cookie: '#(authCookie)' }

    # Delete the booking
    Given path 'booking', id
    When method delete
    Then status 201

    # Confirm deletion
    Given path 'booking', id
    When method get
    Then status 404