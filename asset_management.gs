var header = ['Host Name', 'User Name', 'Latest KB', 'Realtime Scan', 'Signature Ver.', 'Signature Date', 'OS Version', 'Updated At'];

function doGet(e) {
  Logger.log(e);
  return ContentService.createTextOutput('こんにちは');
}

function doPost(e) {
  var spreadSheet = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = spreadSheet.getSheetByName('summary');
  var range = spreadSheet.getDataRange();
  var values = range.getValues();
  var newValue = [
    e.parameter.hostname,
    (e.parameter.username || '').replace(/^.*\\/,""),
    e.parameter.latestKB || 'N/A',
    e.parameter.realtimeEnabled,
    e.parameter.signatureVersion,
    e.parameter.signatureDate,
    e.parameter.osVersion,
    new Date()
  ];
  values.shift();
  values.unshift(header);
  var existsFlg = false;
  for (var i=0; i<values.length; ++i) {
    if (values[i][0] === e.parameter.hostname) {
      values[i] = newValue;
      existsFlg = true;
      break;
    }
  }
  if (!existsFlg) {
    values.push(newValue);
  }
  for (var value of values) {
    while(value.length < header.length) {
      value.push('');
    }
  }
  sheet.getRange(1, 1, values.length, values[0].length).setValues(values);

  return ContentService.createTextOutput('hello?');
}
