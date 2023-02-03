var header = ['SerialNo', 'Host Name', 'User Name', 'Realtime Scan', 'Signature Ver.', 'Signature Date', 'OS Version', 'Updated At'];

function doGet(e) {
  Logger.log(e);
  return ContentService.createTextOutput('こんにちは');
}

function doPost(e) {
  var spreadSheet = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = spreadSheet.getSheetByName('summary');
  var range = sheet.getRange(1, 1, 9999, header.length);
  var values = range.getValues();
  var newValue = [
    e.parameter.serialNumber,
    e.parameter.hostname,
    (e.parameter.username || '').replace(/^.*\\/,""),
    e.parameter.realtimeEnabled,
    e.parameter.signatureVersion,
    e.parameter.signatureDate,
    (e.parameter.osVersion || '').replace(/^Microsoft Windows \[Version (.+)\]$/, "$1"),
    new Date()
  ];
  values.shift();
  values.unshift(header);
  var existsFlg = false;
  for (var i=0; i<values.length; ++i) {
    if (values[i][0] === e.parameter.serialNumber) {
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
