var AWS = require('aws-sdk');
const client = new AWS.DynamoDB({ region: "eu-west-1" });
var resultCallback;

exports.handler = function(event, context, callback) {
  resultCallback = callback;
  scan(getParams());
}

function scan(params) {
  const randomUuid = uuidv4();
  params.ExclusiveStartKey = {
    "dadjoke_id": {
      "S": randomUuid
    }
  };
  client.scan(params, scanCallback);
}

function scanCallback(err, data) {
  if (err) {
    console.error("Unable to scan the table. Error JSON:", JSON.stringify(err, null, 2));
    resultCallback(null, null);
  } else {
    resultCallback(null, constructResponse(data));
  }
}

function getParams() {
  const dbTable = process.env.DATABASE_NAME;
  return {
    AttributesToGet: [ "dadjoke" ],
    TableName: DATABASE_NAME,
    Limit: 1,
  };
}

function constructResponse(data) {
  var dadjoke =  ((data['Items'].length == 0) ? "I'm all out." : data['Items'][0].dadjoke.S);
  dadjoke = dadjoke.replace(/"/g, '\\\"');
  return {
    statusCode: 200,
    headers: {
      "Content-type": "application/json"
    },
    body: `{"dadjoke": "${dadjoke}" }`
  }
}

function uuidv4() {
  const randomFactor = (new Date().getTime() % 10) / 10;
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    var r = Math.random() * randomFactor * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}
