var header = ['SerialNo', 'Host Name', 'User Name', 'Realtime Scan', 'Signature Ver.', 'Signature Date', 'OS Version', 'Disk Encryption', 'Updated At'];

function doGet(e) {
  Logger.log(e);
  return ContentService.createTextOutput('こんにちは');
}

function doPost(e) {
  var spreadSheet = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = spreadSheet.getSheetByName('summary');
  var range = sheet.getRange(1, 1, 9999, header.length);
  var values = range.getValues();
  var signatureDate = e.parameter.signatureDate;
  if (signatureDate.match(/^\d+\/\d+\/\d{4}/)) {
    signatureDate = signatureDate.replace(/^(\d+\/\d+)\/(\d{4})/, '$2/$1');
  }
  var newValue = [
    e.parameter.serialNumber,
    e.parameter.hostname,
    (e.parameter.username || '').replace(/^.*\\/,""),
    e.parameter.realtimeEnabled,
    e.parameter.signatureVersion,
    signatureDate,
    (e.parameter.osVersion || '')
      .replace(/^Microsoft Windows \[Version (.+)\]$/, "$1")
      .replace(/[ \t]/g, ""),
    e.parameter.diskEncryption,
    new Date()
  ];
  values.shift();
  values.unshift(header);
  values = values.filter(v=>{return !!v[0]});
  var existsFlg = false;
  for (var i=0; i<values.length; ++i) {
    if (values[i][0] === e.parameter.serialNumber) {
      existsFlg = true;
      var oldValue = values[i];
      values[i] = newValue;
      if (!values[i][2]) {values[i][2] = oldValue[2];}
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
