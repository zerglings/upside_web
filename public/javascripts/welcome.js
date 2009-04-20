Event.addBehavior.reassignAfterAjax = true;

var IphoneInputField = Behavior.create({
	initialize: function(options) {
		var element = this.element;
		var grayedOutText = " " + element.readAttribute('grayed_out_text');
		if (element.value == '' || element.value == grayedOutText) {
			element.nonGrayedOutType = element.readAttribute('type');
			element.addClassName('grayed_out');
			element.writeAttribute('type', 'text');
			element.setValue(grayedOutText);
		}
	},
	onfocus: function(e) {
		var element = e.element();
		console.debug(element);
		if (element.hasClassName('grayed_out')) {
			element.setValue('');
      element.writeAttribute('type', element.nonGrayedOutType);
			element.removeClassName('grayed_out');
		}
	},
	onblur: function(e) {
    var element = e.element();
    var grayedOutText = " " + element.readAttribute('grayed_out_text');
    if (element.value == '' || element.value == grayedOutText) {
      element.nonGrayedOutType = element.readAttribute('type');
      element.addClassName('grayed_out');
      element.writeAttribute('type', 'text');
      element.setValue(grayedOutText);
    }
	}
});
Event.addBehavior({'.iphone_field': IphoneInputField});
