Feature: Auth helpers

Background:
  * url baseUrl

@ignore @getToken @name=getToken
Scenario: Obtain auth token (valid credentials)
  * def u = typeof username != 'undefined' ? username : karate.get('username')
  * def p = typeof password != 'undefined' ? password : karate.get('password')

  Given path 'auth'
  And request { username: #(u), password: #(p) }
  When method post
  Then status 200
  And match response == { token: '#string' }
  * def token = response.token