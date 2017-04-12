/* globals $, moment, datePickerController */

var ukti = window.ukti || {};

ukti.DateFilterPicker = (function($, moment, datePickerController) {
    'use strict';

    var now = moment();
    var nowMinusOneDay = now.subtract(2, 'days');
    var nowMinusOneDayFormatted = nowMinusOneDay.format('YYYYMMDD');

    var triggerChange = function (argsObj) {
      $('#'+ argsObj.id).change();
    };

    var init = function ($form) {
      datePickerController.setGlobalOptions({
        'nodrag': 1
      });

      datePickerController.createDatePicker({                    
        formElements:{'created_at_from_day': '%j', 'created_at_from_month': '%n', 'created_at_from_year': '%Y'},
        cursorDate: nowMinusOneDayFormatted,
        noFadeEffect: true,
        callbackFunctions: {
          'datereturned':[triggerChange]
        }
      });

      datePickerController.createDatePicker({                    
        formElements:{'created_at_to_day': '%j', 'created_at_to_month': '%n', 'created_at_to_year': '%Y'},
        cursorDate: nowMinusOneDayFormatted,
        noFadeEffect:true,
        callbackFunctions: {
          'datereturned':[triggerChange]
        }
      });
    };

    return {
        init: init
    };

})($, moment, datePickerController);