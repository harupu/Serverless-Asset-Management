function doGet(e) {
  return ContentService.createTextOutput(getScript());
}

function doPost(e) {
  return ContentService.createTextOutput('hello?');
}

function getScript() {
  var spreadSheet = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = spreadSheet.getSheetByName('script');
  var values = sheet.getRange(1,1,1,1).getValues();
  return values[0][0];
}