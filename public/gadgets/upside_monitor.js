/**
 * Copyright 2009 Zergling.Net, All Rights Reserved.
 * Author: Victor Costan
 */

// Wrap the module in an anoymous function, don't pollute the global namespace
(function() {

var spMonitor = dojo.provide("stockplay.monitor");

dojo.require("dijit.layout.ContentPane");
dojo.require("dijit.TitlePane");
dojo.require("dojo.date.locale");
dojo.require("dojo.io.script");
dojo.require("dojo.parser");
dojo.require("dojo.string");
dojo.require("dojox.timing");
dojo.require("dojox.widget.Toaster");

// The user preferences object in the Google Gadgets framework.
var prefs = function() {
  if (gadgets && gadgets.Prefs) {
    return new gadgets.Prefs();
  }
  if (_IG_Prefs) {
    return new _IG_Prefs(); 
  }
  return null;
}

// The host URL to the server (typically http://istockplay.com) in user prefs.
var serverUrlHost = function() {
  return prefs().getString("server");
}

var serverRefreshInterval = function() {
	return prefs().getInt("refresh") * 1000;
}

var refreshDisplay = function() {
  // Use the JSONP output of StockPlay's server.
  dojo.io.script.get({
    url: serverUrlHost() + "/monitoring/gadget",
    callbackParamName: "callback",
    load: processStats,
    error: spStatsError
  });
}

// Announces an error in fetching monitoring stats from the StockPlay server.
var spStatsError = function() {
  console.debug("crap");
  dojo.publish("net.zergling/updateStatus",
	             { message: "Server cannot be reached?!",
							   type: "fatal", duration: 0 });
}

// Processes a JSONP response from the StockPlay server. 
var processStats = function(stats) {		
	var tpl = '<div class="stat_div" id="${key}"><span class="stat_name">${title}</span><span class="stat_value">${value}</span></div>';
	var stat_schema = [['Devices', 'devices'], ['Users', 'users'],
	                   ['Orders', 'orders'], ['Trades', 'trades']];
  var html = "";	
	dojo.forEach(stat_schema, function(stat_set) {
		html += dojo.string.substitute(tpl, {title: stat_set[0], key: stat_set[1], value: stats[stat_set[1]]});
	});
	
  var container = dijit.byId('stats_container');
	container.setContent(html);
	
  adjustWindowHeight();
}

var createNode = function(node_id, parent_node) {
  var node = document.createElement("div");
  dojo.attr(node, {id: node_id});
  dojo.place(node, parent_node, "last");
}

// Lays out the display.
var setupDisplay = function() {
  var ui_main = dojo.byId("ui_main");
  ui_main.innerHTML = "";

  createNode("stats_container", ui_main);
  var container = new dijit.layout.ContentPane({"class": "tundra"},
	                                             "stats_container");

  createNode("ui_toaster", ui_main);
  var toaster = new dojox.widget.Toaster({
      "class": "tundra",
      duration: "0",
      positionDirection: "tr-left",
      messageTopic: "ui_toaster"
  }, "ui_toaster");
  
  adjustWindowHeight();
}

// Executed after Dojo loads all the javascripts and parses the page.
dojo.addOnLoad(function() {
  setupDisplay();
  refreshDisplay();

  var timer = new dojox.timing.Timer(serverRefreshInterval());
  timer.onTick = refreshDisplay;
  timer.start();
});

})(); // end of module wrapped in anonymous function 

// Works with the Google Gadget framework to adjust this gadget's height.
var adjustWindowHeight = function() {
  if (gadgets && gadgets.window && gadgets.window.adjustHeight) {
    gadgets.window.adjustHeight();
  }
  else {
    _IG_AdjustIFrameHeight();
  }
}
