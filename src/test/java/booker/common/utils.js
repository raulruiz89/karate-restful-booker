function fn() {
  var utils = {};

  utils.todayPlus = function(days) {
    var d = new Date();
    d.setDate(d.getDate() + days);
    return d.toISOString().substring(0, 10);
  };

  utils.buildBooking = function(opts) {
    opts = opts || {};
    var base = {
      firstname: opts.firstname || 'Raul',
      lastname: opts.lastname || 'Ruiz',
      totalprice: opts.totalprice != null ? opts.totalprice : 521,
      depositpaid: opts.depositpaid != null ? opts.depositpaid : true,
      bookingdates: {
        checkin: opts.checkin || utils.todayPlus(1),
        checkout: opts.checkout || utils.todayPlus(3)
      },
      additionalneeds: opts.additionalneeds || 'Breakfast'
    };
    return base;
  };

  utils.mean = function(nums) {
    return nums.reduce((a,b)=>a+b,0) / (nums.length || 1);
  };

  utils.nonEmptyIdList = function(list) {
    if (!Array.isArray(list)) karate.fail('Expected list to be an array');
    if (list.length === 0) karate.fail('Expected at least 1 booking id, but got 0');
    list.forEach(function(item, index){
      if (typeof item.bookingid !== 'number') {
        karate.fail('Expected bookingid to be number at index ' + index + ' but got: ' + JSON.stringify(item));
      }
    });
  };

  return utils;
}