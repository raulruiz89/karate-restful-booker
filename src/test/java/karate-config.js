
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

  // Tags received from command line
  var kopts = karate.properties['karate.options'] || '';
  // Robust parsing of --tags
  var skipAuth = false;
  var tagSpecMatch = /--tags\s+([^\s]+)/.exec(kopts);
  if (tagSpecMatch) {
    var rawTags = tagSpecMatch[1].split(',');
    var trimmed = rawTags.map(t => t.trim());
    var hasIncludeNegative = trimmed.includes('@negative');
    var hasExcludeNegative = trimmed.includes('~@negative');
    skipAuth = hasIncludeNegative && !hasExcludeNegative;
  }
  karate.log('Auth decision: skipAuth =', skipAuth, 'raw options =>', kopts);

  if (!skipAuth) {
    karate.log('Auth: attempting token retrieval (skipAuth=false)');
    try {
      var auth = karate.callSingle('classpath:booker/common/auth.feature@getToken', {
        baseUrl: config.baseUrl,
        username: config.username,
        password: config.password
      });
      config.token = auth.token;
      karate.log('Auth: token obtained =>', config.token);
      if (config.token) {
        config.headers.Cookie = 'token=' + config.token;
      } else {
        karate.log('Auth WARN: token vacío, se usará fallback en feature si es necesario');
      }
    } catch (e) {
      karate.log('Auth ERROR:', e.message);
      config.token = '';
    }
  } else {
    karate.log('Auth: SKIPPED due to inclusion of @negative (without exclusion of ~@negative)');
    config.token = '';
    if (config.headers.Cookie) { delete config.headers.Cookie; }
  }

  karate.configure('connectTimeout', config.timeout);
  karate.configure('readTimeout', config.timeout);
  karate.configure('headers', config.headers);
  karate.configure('ssl', true);

  return config;
}