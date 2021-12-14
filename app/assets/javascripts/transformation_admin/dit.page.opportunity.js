// View: admin/opportunity (new/edit)
//
// required dit.js
// required dit.utils.js
//= require components/AsyncLoad
//= require transformation/dit.class.selective_lookup.js
//= require transformation/dit.class.cpv_code_lookup.js
//= require transformation/dit.class.data_provider.js
//= require transformation/dit.class.service.js
//= require transformation/dit.class.filter_multiple_select.js
//= require transformation/dit.class.expander.js

var ukti = window.ukti || {};

ukti.config = {
  'ckeditorPath': '/export-opportunities/assets/ckeditor/ckeditor.js',
};

dit.page.opportunity = (new function () {
  var _cache = {}

  this.init = function() {
    cacheComponents();
    setupTargetUrlField();
    setupFilterMultipleSelectFields();
    setupExpanders();
    setupCpvLookup();
    loadTextEditorScript();

    delete this.init; // Run once
  }
  
  /* Grab and store elements that are manipulated throughout the
   * lifetime of the page or used across several functions.
   **/
  function cacheComponents() {
    _cache.$serviceProvider = $("[data-node=service-provider]");
    _cache.$targetUrlParent = $("[data-node=target-url]").parent();
    _cache.$companyInput = $("[data-node=countries]")
    _cache.$sectorInput = $("[data-node=sectors]")
    _cache.$process = $(".process");
    _cache.$history = $(".history");
  }

  /* Add visual toggle to show/hide Target URL field, 
   * based on Service Provider field changes. 
   **/
  function setupTargetUrlField() {
    var $serviceProviderField = _cache.$serviceProvider;
    var $targetUrlField = _cache.$targetUrlParent;

    // Bind the event handling.
    $serviceProviderField.on("change", function() {
      // 252 == DFID
      if ($serviceProviderField.val() == 252) {
        $targetUrlField.show();
      }
      else {
        $targetUrlField.hide();
      }
    });

    // Trigger the event for initial view adjustment
    $serviceProviderField.trigger("change");
  }

  /* Turn regular <select> fields into enhanced FilterMultipleSelect
   * components.
  /**/
  function setupFilterMultipleSelectFields() {
    if(_cache.$companyInput.length && _cache.$sectorInput.length) {
      new dit.classes.FilterMultipleSelect(_cache.$companyInput, {
        title: _cache.$companyInput.data("display"),
        unselected: _cache.$companyInput.data("unselected")
      });

      new dit.classes.FilterMultipleSelect(_cache.$sectorInput, {
        title: _cache.$sectorInput.data("display"),
        unselected: _cache.$sectorInput.data("unselected")
      });
    }
  }

  /* Add visual toggle to show/hide Target URL field, 
   * based on Service Provider field changes. 
   **/
  function setupExpanders() {
    var areas = [_cache.$process, _cache.$history]
    for(i=0; i<areas.length; ++i) {
      var $control = areas[i].find('h2');
      var $container = areas[i].find('.container');
      var $wrapper = $("<div></div>");
      $wrapper.append($container.children());
      $container.append($control);
      $container.append($wrapper);
      if($wrapper.length && $control.length) {
        new dit.classes.Expander($wrapper, { $control: $control, closed: false, blur: false });
      }
    }
  }

  /* Enhance CPV code entry field providing a lookup service
   * and ability to add multiple entries.
   **/
  function setupCpvLookup() {
    var $cpvFieldset = $(".field-cpv_ids.field-group");
    var $cpvInputElements = $("[data-node=cpv-lookup]");
    var $cpvLookupController = $('<button class="CpvLookupController" type="button">Add another code</button>');
    var service = new dit.classes.Service(dit.constants.CPV_CODE_LOOKUP_URL);

    if($cpvInputElements.length) {
      $cpvInputElements.each(function(i) {
        var cpvLookup = new dit.classes.CpvCodeLookup($(this), service, {
          param: "format=json&description=",
          name: "opportunity[cpv_ids][]",
          placeholder: dit.constants.CPV_FIELD_PLACEHOLDER
        });

        // If it's the last one, add button to allow more fields.
        if(i == $cpvInputElements.length - 1) {
          $cpvFieldset.append($cpvLookupController);
          $cpvLookupController.on("click.CpvLookupController", function() {
            var $lastField = $(".CpvCodeLookup").last().parents(".field");
            var $cloneField, $cloneInput;
            if($lastField.length) {
              $cloneField = $lastField.clone();
              $cloneInput = $cloneField.find(".CpvCodeLookup");
              $cloneInput.attr("id", "");
              $cloneInput.attr("readonly", false);
              $cloneInput.val("");
              $cloneField.find("button").remove();
              $(this).before($cloneField);
              new dit.classes.CpvCodeLookup($cloneInput, service, {
                param: "format=json&description=",
                name: "opportunity[cpv_ids][]",
                placeholder: dit.constants.CPV_FIELD_PLACEHOLDER
              });
            }
          });
        }
      });

      // Add a little check to remove any blank CPV fields to
      // fix issue with empty values being stored.
      $cpvFieldset.parent("form").on("submit", function() {
        $(".CpvCodeLookup").each(function() {
          if(this.value=='') {
            $(this).remove();
          }
        });
      });
    }
  }

  function loadTextEditorScript() {
    if (ukti.config.ckeditorPath) {
      ukti.asyncLoad.init(ukti.config.ckeditorPath, initTextEditor);
    }
  }

  function initTextEditor() {
    CKEDITOR.stylesSet.add('mystyles', [
      // Block-level styles
      { name: 'Heading 1', element: 'h1'},
      { name: 'Heading 2', element: 'h2'},
      { name: 'Heading 3', element: 'h3'},
      { name: 'Introduction', element: 'p', attributes: { 'class': 'introduction'} },
      // Inline styles
      { name: 'Link button', element: 'a', attributes: { 'class': 'button' } },
      { name: 'List', element: 'ul', attributes: { 'class': 'list list-bullet' } },
      // Object styles
      { name: 'Stretch', element: 'img', attributes: { 'class': 'stretch' } },
    ]);
    CKEDITOR.on('instanceReady', function(evt) {
      var editor = evt.editor;
      editor.on('focus', function(event) {
        event.editor.container.$.classList.add(focusOutlineClassname);
      });
      editor.on('blur', function(event) {
        event.editor.container.$.classList.remove(focusOutlineClassname);
      });
      editor.on('change', function(event) {
        event.editor.updateElement();
        var raiseEvent = document.createEvent('Event');
        raiseEvent.initEvent('change', true, true);
        event.editor.element.$.dispatchEvent(raiseEvent);
      });
    });
    CKEDITOR.replace('opportunity_description');
  };
});

$(document).ready(function() {
  dit.page.opportunity.init();
});
