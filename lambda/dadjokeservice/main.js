'use strict'

exports.handler = function (event, context, callback) {
  var response = {
    statusCode: 200,
    body: '{ "dadjoke": "insert joke here" }'
  }
  callback(null, response)
}
