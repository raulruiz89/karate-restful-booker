    @functional @regression
Feature: /booking - CRUD test cases and filtering

  Background: Common test configuration and setup
    # Global configuration
    * url baseUrl
    * configure headers = headers

    # Load utility functions
    * def utils = read('classpath:booker/common/utils.js')()
    
    @smoke
  Scenario: Health check
    Given path 'ping'
    When method get
    Then status 201

    @smoke
  Scenario: List booking IDs
    Given path 'booking'
    When method get
    Then status 200
    And match response == '#[]'
    * eval utils.nonEmptyIdList(response)

  Scenario Outline:Filter by first name/lastname element and validate sample
    * def name = '<firstname>'
    * def lname = '<lastname>'
    Given path 'booking'
    And param firstname = name
    And param lastname = lname
    When method get
    Then status 200

    #Validate non-empty response
    * def ids = response
    * eval utils.nonEmptyIdList(ids)

    # Get the first booking ID from the response
    * def firstBooking = response[0]
    * def id = firstBooking.bookingid

    # Prepare arguments for validation feature
    * def args = { id: #(id), firstname: #(name), lastname: #(lname) }

    #call validation feature
    * call read('classpath:booker/common/response-validation.feature') args

    Examples:
      | firstname | lastname |
      | Josh      | Allen    |
      | John      | Smith    |
      | Jane      | Doe      |
      | Jake      | Smith    |

    @smoke
  Scenario: Post booking and validate (Happy Path)
    * def payload = utils.buildBooking({ additionalneeds: 'Dinner' })
    Given path 'booking'
    And request payload
    When method post
    Then status 200
    * def bookingId = response.bookingid
    * def first = response.booking.firstname
    * def last = response.booking.lastname

    # Prepare arguments for validation feature
    * def args = { id: #(bookingId), firstname: #(first), lastname: #(last) }

    #call validation feature
    * call read('classpath:booker/common/response-validation.feature') args
    
  
  Scenario: Update booking and validate (PUT)
    # Create booking first
    * def create = call read('classpath:booker/common/create-booking.feature') { opts: {} }
    * def bookingId = create.bookingId
    * def updated = utils.buildBooking({ firstname: 'Nancy', lastname: 'Toledo', additionalneeds: 'Late checkout' })

    # Update booking and validate
    Given path 'booking', bookingId
    And request updated
    When method put
    Then status 200
    And match response == updated

 
  Scenario: Partial update (PATCH)
    #create booking first
    * def create = call read('classpath:booker/common/create-booking.feature') { opts: {} }
    * def bookingId = create.bookingId
    * def patchBody = { firstname: 'Leonardo', additionalneeds: 'Dinner' }

    #validate partial update
    Given path 'booking', bookingId
    And request patchBody
    When method patch
    Then status 200
    And match response.firstname == patchBody.firstname
    And match response.additionalneeds == patchBody.additionalneeds

 
  Scenario: Delete booking and validate (Happy Path)
     #create booking first
    * def create = call read('classpath:booker/common/create-booking.feature') { opts: {} }
    * def bookingId = create.bookingId

    #delete booking
    Given path 'booking', bookingId
    When method delete
    Then status 201

    #validate booking is deleted
    Given path 'booking', bookingId
    When method get
    Then status 404