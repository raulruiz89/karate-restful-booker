    @negative @regression
Feature: Negative and Robustness test cases for /booking endpoint

  Background: Common test configuration and setup
    # Global configuration
    * url baseUrl
    * configure headers = headers

    # Load utility functions
    * def utils = read('classpath:booker/common/utils.js')()

    @known-bug
  Scenario: Post booking with missing required fields -> server returns 500
    * def payload = read('classpath:testdata/booking/booking-invalid-missing-fields.json')
    Given path 'booking'
    And request payload
    When method post
    Then status 500
    * print 'Known issue: server should return 400 but returns 500 on missing Content-Type'

    @known-bug @contract-negative
  Scenario: Post booking with invalid fields should violate contract (contract must fail, regardless of 200)
    * def payload = read('classpath:testdata/booking/booking-invalid-types.json')
    * def bookingSchema = read('classpath:schemas/booking/booking.schema.json')

    Given path 'booking'
    And request payload
    When method post
    Then status 200

    * def result = karate.match(response.booking, bookingSchema)
    * print 'contract validation status =>', result.pass, '\nMISMATCHES =>', result.message
    * assert !result.pass
        

    @known-api-behavior
  Scenario: Post booking with invalid date formats (API does not enforce date validation)
    """
    This API does not validate the date format in the payload.

    Even if invalid dates are sent (e.g., "12-11-2025"), the service 
    returns a 200 status code and silently normalizes some values ​​in the response.

    This scenario verifies a schema contract violation, not the status code.
    """
    * def payload = read('classpath:testdata/booking/booking-invalid-dates.json')
    * def bookingSchema = read('classpath:schemas/booking/booking.schema.json')

    Given path 'booking'
    And request payload
    When method post
    #The API returns 200 even with invalid dates (observed behavior)
    Then status 200
    
     # Contract validation should fail due to date format issues
    * def result = karate.match(response.booking, bookingSchema)
    * print 'contract pass? =>', result.pass
    * assert !result.pass

  Scenario: Put without token should fail
    # create booking first
    * call read('classpath:booker/common/create-booking.feature') { opts: {} }

    # retrieve bookingId
    * def bookingId = response.bookingid

    # prepare updated payload
    * def updated = utils.buildBooking({ firstname: 'NoAuth' })

    # attempt to update without auth token
    Given path 'booking', bookingId
    And request updated
    When method put
    Then status 403

  Scenario: Delete without token should fail
    # create booking first
    * call read('classpath:booker/common/create-booking.feature') { opts: {} }

    # retrieve bookingId
    * def bookingId = response.bookingid

    # attempt to delete without auth token
    Given path 'booking', bookingId
    When method delete
    Then status 403
    
  Scenario: get with non-existent id
    Given path 'booking', 99999999
    When method get
    Then status 404

  Scenario: get non-numeric id
    Given path 'booking', 'abc'
    When method get
    Then status 404

    @bug-restful-booker-415 @media-type
  Scenario: content-type text/plain with valid JSON body is accepted (BUG: should be 415)
    * def payload = read('classpath:testdata/booking/booking-create.json')
    Given path 'booking'
    And header Content-Type = 'text/plain'
    And request payload
    When method post
    Then status 200
    * print 'BUG: server accepts text/plain + JSON and returns 200 instead of 415'

    @bug-restful-booker-415 @media-type
  Scenario: content-type text/plain with NON JSON body should fail (but returns 200)
    Given path 'booking'
    And header Content-Type = 'text/plain'
    And request 'NOT_JSON_PAYLOAD'
    When method post
    # Observed actual status = 400 (parse failure) -> adjust expectation
    Then status 400
    * print 'Confirmed: server rejects non-JSON with 400 (expected 415 for unsupported media type)'

    @bug-restful-booker-415 @media-type
  Scenario: content-type application/xml with XML body should fail (but returns 200)
    Given path 'booking'
    And header Content-Type = 'application/xml'
    And request '<booking><firstname>Raul</firstname><lastname>Ruiz</lastname></booking>'
    When method post
    # Observed actual status = 400 (cannot parse XML as JSON) -> adjust expectation
    Then status 400
    * print 'Confirmed: server returns 400 for XML (expected 415 for unsupported media type)'

    @bug-restful-booker-415 @media-type
  Scenario: missing Content-Type header defaults to success (implicit JSON parse) (behavior doc)
    * def payload = read('classpath:testdata/booking/booking-create.json')
    Given path 'booking'
    And request payload
    When method post
    Then status 200
    * print 'Behavior: server succeeds without Content-Type header (no strict validation)'