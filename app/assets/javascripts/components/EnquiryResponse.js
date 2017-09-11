/* globals CKEDITOR */
var ukti = window.ukti || {};

ukti.EnquiryResponse = (function($) {
    'use strict';

    var baseEl,
        focusOutlineClassname = 'focus-outline';

    var config = {
        errorMessages : {
            'comment': 'Please enter some comments.',
            'signature': 'Please enter contact details.'
        }
    };

    var setup = function () {
        var initialResponseType = returnResponseType();
        setState(initialResponseType);
    };

    var returnResponseType = function () {
        return ukti.Utilities.getValueFromRadioButton('enquiry_response[response_type]');
    };

    var setState = function (mode) {
        mode = parseInt(mode, 10);
        switch (mode) {
            case 2:
                document.getElementById('custom-response').classList.add('hidden');
                document.getElementById('signature').classList.add('hidden');
                document.getElementById('attachments').classList.add('hidden');
                document.getElementById('submit').classList.add('hidden');
                updateSubmitButton('Preview');
                break;
            case 3:
                document.getElementById('custom-response').classList.remove('hidden');
                document.getElementById('signature').classList.add('hidden');
                document.getElementById('attachments').classList.add('hidden');
                document.getElementById('submit').classList.remove('hidden');
                updateSubmitButton('Preview');
                break;
            case 4:
                document.getElementById('custom-response').classList.add('hidden');
                document.getElementById('signature').classList.add('hidden');
                document.getElementById('attachments').classList.add('hidden');
                document.getElementById('submit').classList.remove('hidden');
                updateSubmitButton('Send');
                break;
            case 5:
                document.getElementById('custom-response').classList.add('hidden');
                document.getElementById('signature').classList.add('hidden');
                document.getElementById('attachments').classList.add('hidden');
                document.getElementById('submit').classList.remove('hidden');
                updateSubmitButton('Send');
                break;
            default:
                document.getElementById('custom-response').classList.remove('hidden');
                document.getElementById('signature').classList.remove('hidden');
                document.getElementById('attachments').classList.remove('hidden');
                document.getElementById('submit').classList.remove('hidden');
                updateSubmitButton('Preview');
        }
    };

    var tabsCallback = function (index) {
        setState(index+1);
        ukti.Forms.clearErrorsFromFields();
    };

    var updateSubmitButton = function (text) {
        var button = baseEl.querySelector('input[type=submit]');
        button.value = text;
    };

    var initTabs = function () {
        var el = document.querySelector('.js-tabs');
        ukti.Tabs.init(el, tabsCallback);
    };

    var initTextEditor = function () {
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
                var raiseEvent = new Event('change');
                event.editor.element.$.dispatchEvent(raiseEvent);
            });
        });
        CKEDITOR.replace( 'enquiry_response_email_body' );
        CKEDITOR.replace( 'enquiry_response_signature' );
    };

    var initToggleFieldEdit = function () {
        var els = document.querySelectorAll('.js-toggle-field-edit'), i;
        for (i = 0; i < els.length; ++i) {
            ukti.ToggleFieldEdit.init(els[i]);
        }
    };

    var initUploadWidget = function () {
        var els = document.querySelectorAll('.uploadWidget'), i;
        for (i = 0; i < els.length; ++i) {
            ukti.UploadWidget.init(els[i]);
        }
    };

    var loadTextEditorScript = function () {
        if (ukti.config.ckeditorPath) {
            ukti.asyncLoad.init(ukti.config.ckeditorPath, initTextEditor);
        }
    };

    var formSubmitHandler = function (event) {
        var errors = [];
        if ( isSignatureRequired() && isSignatureInvalid() ) {
            ukti.Forms.addErrorToField(baseEl.querySelector('#enquiry_response_signature'), config.errorMessages.signature);
            errors.push(config.errorMessages.signature);
        }

        if ( isCommentRequired() && isCommentInvalid() ) {
            ukti.Forms.addErrorToField(baseEl.querySelector('#enquiry_response_email_body'), config.errorMessages.comment);
            errors.push(config.errorMessages.comment);
        }

        if (errors.length) {
            event.preventDefault();
            // add summary
            return false;
        }
        else {
            return true;
        }
    };

    var isSignatureRequired = function () {
        var response_type = returnResponseType();
        return (response_type === "1" || response_type === "2");
    };

    var isSignatureInvalid = function () {
        var value = baseEl.querySelector('#enquiry_response_signature').value;
        return ukti.Utilities.isValueEmpty(value);
    };

    var isCommentRequired = function () {
        var response_type = returnResponseType();
        return (response_type === "1" || response_type === "2" || response_type === "3");
    };

    var isCommentInvalid = function () {
        var value = baseEl.querySelector('#enquiry_response_email_body').value;
        return ukti.Utilities.isValueEmpty(value);
    };

    var initValidation = function () {
        baseEl.addEventListener('submit', formSubmitHandler);
    };

    var init = function (form) {
        baseEl = form;
        setup();
        initTabs();
        loadTextEditorScript();
        initToggleFieldEdit();
        initUploadWidget();
        initValidation();
    };

    return {
        init: init
    };

})();
