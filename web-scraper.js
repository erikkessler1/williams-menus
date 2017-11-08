/*
 * Script that scrapes the Williams menu website to get the menus for the day. Also
 * serves scraped data to clients as JSON.
 *
 * The doGet function serves the JSON data.
 *
 * Runs as a Google Apps Script.
 *
 * (c) 2015. Erik Kessler
 */

var NN_URL = "http://nutrition.williams.edu/NetNutrition/";
var MISSION_UNIT = 1;
var RESKY_UNIT = 10;
var DRIS_UNIT = 33;

var MISH_DAILY_UNIT = 3;
var DRIS_DAILY_UNIT = 34;
var RESKY_DAILY_UNIT = 12;

function startSession()
{
  
  var options =
   {
     "method" : "get",
     "muteHttpExceptions": true
   };
   var response = UrlFetchApp.fetch(NN_URL, options);
  var id = response.getAllHeaders()["Set-Cookie"][0];
  var idIndex = id.indexOf("ASP.NET_SessionId=");
  id  = id.substring(idIndex + "ASP.NET_SessionId=".length, id.indexOf(";", idIndex));
  
  return id;

}

function selectUnitFromSidebar(id, unit) {
  var options =
      {
        "method" : "post",
        "muteHttpExceptions": true,
        "payload" : "unitOid= " + unit,
        "headers" : { "Cookie" : "ASP.NET_SessionId=" + id + ";" }
  };

  UrlFetchApp.fetch(NN_URL + "Unit.aspx/SelectUnitFromSideBar" , options);
}

function selectChildUnitFromSidebar(id, unit) {
  var options =
      {
        "method" : "post",
        "muteHttpExceptions": true,
        "payload" : "unitOid= " + unit,
        "headers" : { "Cookie" : "ASP.NET_SessionId=" + id + ";" }
  };

  var response = UrlFetchApp.fetch(NN_URL + "Unit.aspx/SelectUnitFromChildUnitsList" , options);

  return response;
}

function selectMenu(sId, mId) {
  var options =
      {
        "method" : "post",
        "muteHttpExceptions": true,
        "payload" : "menuOid= " + mId,
        "headers" : { "Cookie" : "ASP.NET_SessionId=" + sId + ";" }
  };

  var response = UrlFetchApp.fetch(NN_URL + "Menu.aspx/SelectMenu" , options);

  return response;
}

function getMenuId(response) {
  response = response.toString();
  
  
  var ids = {};
  
  var meal = "";
  var id;
  var index = response.indexOf("menuListSelectMenu(");
  if (index == -1) {
   return ids; 
  }
  var ctable = response.indexOf("ctable", index);
  if (ctable == -1) {
    ctable = response.indexOf("disclaimerPanel");
  }
  
  while ((ctable > index) && (index != -1)) {
    id = response.substring(index + "menuListSelectMenu(".length, response.indexOf(")", index));
    index = response.indexOf("u003e", index);
    meal = response.substring(index + "u003e".length, response.indexOf("\\u003", index));
    meal = meal.replace("    ", "");
    meal = meal.replace("\\u0027", "'");
    ids[meal] = id;
    index = response.indexOf("menuListSelectMenu(", index);
  }
  
  return ids;
}

function getMenuItems(response) {
  response = response.toString();
  
  var items = {};
  
  var gIndex = response.indexOf("itemGroupRow\\u0027\\u003e");
  var iIndex = response.indexOf("mobileItemName\\u0027\\u003e");
  var group, item;
  while (gIndex != -1) {
    var gName = response.substring(gIndex + "itemGroupRow\\u0027\\u003e".length, response.indexOf("\\u003c", gIndex));
    gName = gName.replace("Misc                ", "Misc");
    gIndex = response.indexOf("itemGroupRow\\u0027\\u003e", gIndex + 1);
    group = [];
    
    while ((gIndex == -1 && iIndex != -1) || iIndex < gIndex) {
      item = response.substring(iIndex + "mobileItemName\\u0027\\u003e".length, response.indexOf("\\u003c", iIndex));
      item = item.split("\\u0026").join("and");
      item = item.replace("\\u0027", "'");
      group.push(item);
      iIndex = response.indexOf("mobileItemName\\u0027\\u003e", iIndex + 1);
      
    }
    
    items[gName] = group;
    
  }
  
  return items;
}

function mishMenu(id) {
  selectUnitFromSidebar(id, MISSION_UNIT);
  var menuIds = getMenuId(selectChildUnitFromSidebar(id, MISH_DAILY_UNIT));
  
  var meals = {};
  for (i in menuIds) {
   meals[i] = getMenuItems(selectMenu(id, menuIds[i])); 
  }
  
  return meals;
}

function drisMenu(id) {
  selectUnitFromSidebar(id, DRIS_UNIT);
  var menuIds = getMenuId(selectChildUnitFromSidebar(id, DRIS_DAILY_UNIT));
  
  var meals = {};
  for (i in menuIds) {
   meals[i] = getMenuItems(selectMenu(id, menuIds[i])); 
  }
  
  return meals;
}

function reskyMenu(id) {
  selectUnitFromSidebar(id, RESKY_UNIT);
  var menuIds = getMenuId(selectChildUnitFromSidebar(id, RESKY_DAILY_UNIT));
  
  var meals = {};
  for (i in menuIds) {
   meals[i] = getMenuItems(selectMenu(id, menuIds[i])); 
  }
  
  return meals;
}

function run() {
  var authInfo = ScriptApp.getAuthorizationInfo(ScriptApp.AuthMode.FULL);
  Logger.log(authInfo.getAuthorizationStatus());
  
  var properties = PropertiesService.getScriptProperties();
  properties.setProperty("start", new Date())
  var id = startSession();
  
  var menus = {};
  menus["Mission"] = mishMenu(id);
  menus["Driscoll"] = drisMenu(id);
  menus["Paresky"] = reskyMenu(id);
  
  Logger.log(menus);
  
  
  properties.setProperty("menus", JSON.stringify(menus));
  properties.setProperty("date", new Date());
}

// Funtion that is triggered around midnight each day to scrape the data.
// Have to indirectly run the script via UrlFetchApp.fetch to workaround
// a security restriction in Google Apps Script.
function triggered() {
  var options =
   {
     "method" : "get",
     "muteHttpExceptions": true
   };
   var response = UrlFetchApp.fetch("https://script.google.com/macros/s/AKfycbySXmsz4YrnduBCLfrvjr8wlSXriVmnrorVMwPw3ncGrt8CjuGZ/exec?run=1", options);
}

// Runs the scraper if the run query parameter is set. Also serves current menu data to clients.
function doGet(e) {
  if (e.parameters.run) {
   run() 
  }
  var properties = PropertiesService.getScriptProperties();
  return ContentService.createTextOutput(properties.getProperty("menus"))
    .setMimeType(ContentService.MimeType.JSON);
}
