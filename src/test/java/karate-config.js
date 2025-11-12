
function fn() {
  var env = karate.env;
  if (!env) { env = 'qa'; }
  
  karate.log('karate.env system property was:', env);

  var config = {
    env: env,
    baseUrl: 'https://restful-booker.herokuapp.com',
    headers: { Accept: 'application/json', 'Content-Type': 'application/json' },
    username: karate.properties['rb.user'] || 'admin',
    password: karate.properties['rb.pass'] || 'password123',
    timeout: 5000
  };

  karate.configure('connectTimeout', config.timeout);
  karate.configure('readTimeout', config.timeout);
  karate.configure('headers', config.headers);
  karate.configure('ssl', true);

  return config;
}