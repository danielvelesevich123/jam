import runApex from '@salesforce/apex/jam.runAction';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

const showToast = (page, title, message, type, messageData, mode) => {
    const toastEvt = new ShowToastEvent({
        title: title,
        message: message,
        messageData: messageData || [],
        variant: type,
        mode: mode
    });
    page.dispatchEvent(toastEvt);
};

const runAction = async (action, request) => {
    try {
        console.log(action, 'REQUEST', JSON.parse(JSON.stringify(request)));

        let responseJSON = await runApex({
            action: action,
            requestJSON: JSON.stringify(request)
        });

        const response = JSON.parse(responseJSON);
        console.log(action, 'RESPONSE', JSON.parse(JSON.stringify(response)));

        if (response.isValid !== true) {
            throw response.errors;
        } else {
            return response;
        }
    } catch (e) {
        throw e;
    }
};

const validateComponents = (components) => {
    var validationResult = {
        errorsByInputs: [],
        allValid: true,
        getErrorMessages: function () {
            var errors = [];
            this.errorsByInputs.forEach(function (errorsByInput) {
                errors.push(errorsByInput.errors.join(','));
            })

            return errors;
        }
    };

    components.forEach(function (inputCmp) {

        var validationErrors = [
            'badInput',
            'customError',
            'patternMismatch',
            'rangeOverflow',
            'rangeUnderflow',
            'stepMismatch',
            'tooLong',
            'tooShort',
            'typeMismatch',
            'valueMissing'
        ];

        var defaultErrorMessages = {
            badInput: 'Enter a valid value.',
            patternMismatch: 'Your entry does not match the allowed pattern.',
            rangeOverflow: 'The number is too high.',
            rangeUnderflow: 'The number is too low.',
            stepMismatch: 'Your entry isn\'t a valid increment.',
            tooLong: 'Your entry is too long.',
            tooShort: 'Your entry is too short.',
            typeMismatch: 'You have entered an invalid format.',
            valueMissing: 'Complete this field.'
        };


        let capitalizeFirstLetter = function (string) {
            return string.charAt(0).toUpperCase() + string.slice(1);
        }

        if (inputCmp) {

            if (inputCmp.validity == undefined) {
                if (inputCmp.validate != undefined && !inputCmp.validate()) {
                    let errorMessages = (inputCmp.errorMessages || [])?.filter(error => error?.message ? error?.message !== 'Complete this field.' : error !== 'Complete this field.');
                    if (!errorMessages || errorMessages.length === 0) {
                        errorMessages = [inputCmp.label + ': Complete this field.'];
                    }
                    validationResult.errorsByInputs.push({
                        inputCmp: inputCmp,
                        errors: errorMessages
                    });
                    validationResult.allValid = false;
                }
                //
                // var hasShowErrorMethod = inputCmp.get('c.showError') != undefined;
                // var hasHideErrorMethod = inputCmp.get('c.hideError') != undefined;
                // if(hasShowErrorMethod == true){
                //
                //     var isRequired = inputCmp.get('v.required');
                //     var isEmptyValue = $A.util.isEmpty(inputCmp.get('v.value'));
                //
                //     if (isRequired && isEmptyValue){
                //
                //         inputCmp.showError('Complete this field.');
                //
                //         validationResult.errorsByInputs.push({
                //             inputCmp: inputCmp,
                //             errors: [
                //                 inputCmp.get('v.label') + ': Complete this field.'
                //             ]
                //         });
                //
                //         validationResult.allValid = false;
                //     } else if (hasHideErrorMethod == true) {
                //         inputCmp.hideError();
                //     }
                // }

            } else if (inputCmp.validity && inputCmp.validity.valid === false) {

                var errors = [];
                validationErrors.forEach(function (validationError) {
                    if (inputCmp.validity[validationError] === true) {
                        let errorMessageField = 'message-when-' + capitalizeFirstLetter(validationError);
                        let errorMessage = inputCmp[errorMessageField];
                        errorMessage = errorMessage || defaultErrorMessages[validationError];
                        if (errorMessage) {
                            errors.push(inputCmp.label + ': ' + errorMessage);
                        } else {
                            errors.push(inputCmp.label + ': ' + (
                                (!inputCmp.value ? inputCmp['message-when-value-missing'] : inputCmp['message-when-bad-input']) || inputCmp.label)
                            );
                        }
                    }
                })

                validationResult.errorsByInputs.push({
                    inputCmp: inputCmp,
                    errors: errors
                });

                validationResult.allValid = false;

                if (inputCmp.reportValidity != undefined) {
                    inputCmp.reportValidity();
                }

            }

        }
    })

    return validationResult;
}

const validate = (containerComponent, options) => {
    options = options || {}
    options.additionalComponentTypes = options.additionalComponentTypes || [];

    var componentTypes = [
        'lightning-input',
        'lightning-input-address',
        'lightning-input-field',
        'lightning-input-location',
        'lightning-input-name',
        'lightning-input-rich-text',
        'lightning-textarea',
        'lightning-select',
        'lightning-combobox',
        'lightning-radio-group',
        'lightning-checkbox-group',
        'c-vertic-multi-select',
        'c-vertic-counter',
        'c-vertic-google-address',
        'c-vertic-lookup',
        'c-vertic-select'
    ];

    componentTypes = componentTypes.concat(options.additionalComponentTypes);

    return validateComponents([...containerComponent.querySelectorAll(componentTypes.join(', '))]);
};

const flatten = (data) => {
    let result = {};

    function recurse(cur, prop) {
        if (Object(cur) !== cur) {
            result[prop] = cur;
        } else if (Array.isArray(cur)) {
            for (let i = 0, l = cur.length; i < l; i++) {
                recurse(cur[i], prop + "[" + i + "]");
                if (l === 0) {
                    result[prop] = [];
                }
            }
        } else {
            let isEmpty = true;
            for (let p in cur) {
                isEmpty = false;
                recurse(cur[p], prop ? prop + "." + p : p);
            }
            if (isEmpty && prop)
                result[prop] = {};
        }
    }

    recurse(data, "");
    return result;
}

const chunk = (array, n) => {
    if (!array.length) {
        return [];
    }
    return [array.slice(0, n)].concat(this.chunk(array.slice(n), n));
}

const getURlParams = () => {
    return decodeURI(location.search)
        .replace('?', '')
        .split('&')
        .map(function (param) {
            return param.split('=');
        })
        .reduce(function (values, item) {
            let key = item[0];
            let value = item[1];
            values[key ? key.toLowerCase() : key] = value;
            return values
        }, {});
}

const formatPhone = (val, isMobile = true) => {
    val = val.replace(/\D/g, '');
    if (isMobile) {
        if (val.startsWith('4')) {
            val = '04' + val.slice(1);
        } else if (val.startsWith('614')) {
            val = '04' + val.slice(3);
        }
        if (val.startsWith('04')) {
            let match = val.match(/^(\d{4})(\d{3})(\d{3})$/);
            if (match) {
                val = match[1] + ' ' + match[2] + ' ' + match[3];
            }
        }
    } else {
        let match = val.match(/^(\d{2})(\d{4})(\d{4})$/);
        if (match) {
            val = match[1] + ' ' + match[2] + ' ' + match[3];
        }
    }
    return val;
}

const formatName = val => {
    if (val) {
        val = val.trim();
        val = val.split(' ').map(v => v.charAt(0).toUpperCase() + v.slice(1)).join(' ');
        val = val.split('-').map(v => v.charAt(0).toUpperCase() + v.slice(1)).join('-');

        // If field has an apostrophe as the second character (eg. O'Donnel) also capitalise the letter after the apostrophe;
        val = val.split('\'').map(v => v.charAt(0).toUpperCase() + v.slice(1)).join('\'');
        val = val.split('`').map(v => v.charAt(0).toUpperCase() + v.slice(1)).join('\'');

        // If field starts with Mc then the letter after Mc should also be capitalised.
        val = val.replace(/(\bMc)([a-z])(\w*)/g, (found, gr1, gr2, gr3) => {
            return gr1 + gr2.toUpperCase() + gr3;
        });
    }
    return val;
}

export {
    showToast,
    runAction,
    validate,
    flatten,
    chunk,
    getURlParams,
    formatPhone,
    formatName
}