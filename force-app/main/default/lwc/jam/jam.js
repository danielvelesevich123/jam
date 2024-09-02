import {api, LightningElement} from "lwc";
import runApex from '@salesforce/apex/jam.runAction';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class Jam extends LightningElement {
    @api meta
    bindings = {}

    connectedCallback() {
        this.meta = this.getProxy(this.meta || {});
        this.addEventListener('changedto', this.handleDtoChange.bind(this));
    }

    handleDtoChange(event) {
        this.set(event.detail.path, event.detail.value);
    }

    isEmpty(target) {
        return target == null || false || target === '' || (Array.isArray(target) && target.length === 0) || (!Array.isArray(target) && typeof target === 'object' && Object.keys(target).length === 0);
    }

    getProxy = (obj) => {
        const handler = {
            get: (target, key, receiver) => {

                if (key === Symbol.iterator) {
                    return function* () {
                        for (let prop in target) {
                            yield target[prop];
                        }
                    }
                }

                if (key === 'constructor') {
                    return target && target.constructor ? target.constructor : Object;
                }

                if (key === Symbol.toPrimitive) {
                    return function (hint) {
                        if (hint === 'string') {
                            return '';
                        }
                        if (hint === 'number') {
                            return 0;
                        }
                        return true; // Fallback, should never reach here
                    };
                }

                if (key === Symbol.toStringTag) {
                    return 'Proxy';
                }

                if (key === 'notEmpty') {
                    return !this.isEmpty(target);
                }

                if (key === 'empty' || key === 'isEmpty') {
                    return this.isEmpty(target);
                }

                if (key === 'toString' || key === 'toJSON') {
                    return function () {
                        try {
                            return target;
                        } catch (error) {
                            console.error('Error stringifying target:', error);
                            return '{}'; // Return an empty JSON string if an error occurs
                        }
                    };
                }

                // if (key === 'length') {
                //     return Array.isArray(target) ? target.length : 0;
                // }

                let value = Reflect.get(target, key, receiver);

                if (typeof value === 'object' && value !== null && value.isProxy === true) {
                    return value;
                } else if (typeof value === 'object' && value !== null && !value.isProxy) {
                    value = createProxy(value);
                } else if (Array.isArray(value) && value !== null && !value.isProxy) {
                    value = createProxy(value);
                } else if (typeof value === 'undefined') {
                    value = createProxy({});
                }


                return value;
            },
            set: (target, key, value, receiver) => {
                return Reflect.set(target, key, value, receiver);
                // target[key] = value;
                // return true;
            }
        };

        const createProxy = (target) => {
            return new Proxy(target, handler);
        };

        return createProxy(obj); // Create the initial proxy
    };


    disconnectedCallback() {
        for (let path in this.bindings) {
            this.bindings[path].forEach(bindElement => {
                bindElement.removeEventListener('change');
            });
        }
    }

    renderedCallback() {
        this.template.querySelectorAll('[data-bind]:not([data-bind-custom-handler="true"])').forEach((bindElement) => {
            let pathParent = (bindElement.parentElement ? bindElement.parentElement.getAttribute('data-bind-parent') : '') || '';
            let path = (pathParent ? pathParent + '.' : '') + bindElement.getAttribute('data-bind');
            let index = pathParent ? bindElement.parentElement.getAttribute('data-index') : bindElement.getAttribute('data-index');
            path = path.replaceAll('[]', '[' + index + ']')
            let handler = bindElement.getAttribute('data-bind-custom-handler');

            if (handler) {
                return // prevent infinite loop
            } else {
                bindElement.setAttribute('data-bind-custom-handler', 'true');
            }

            this.setElementValue(bindElement, this.getMapValue(this.meta, path));

            let binds = this.bindings[path] || [];
            binds.push(bindElement);
            this.bindings[path] = binds;

            bindElement.addEventListener('change', event => {
                event.preventDefault();
                event.stopPropagation();

                let updatedMeta = this.setMapValue(JSON.parse(JSON.stringify(this.meta)), path, this.getElementValue(event));
                this.updateMeta(updatedMeta);

                let binds = this.bindings[path] || [];
                binds = binds.filter(otherBindElement => otherBindElement.isConnected);
                binds.forEach(otherBindElement => {
                    if (otherBindElement !== event.target) {
                        this.setElementValue(otherBindElement, this.getElementValue(event));
                    }
                });
            })
        })
    }

    updateMeta(updatedMeta) {
        let oldMeta = this.meta;
        this.meta = this.getProxy(updatedMeta);
        oldMeta = null;
    }

    getElementValue(event) {
        let isCheckbox = event.target.type === 'toggle' || event.target.type === 'checkbox';
        if (isCheckbox) {
            return event.target.checked;
        }

        return event.target.value;
    }

    setElementValue(input, value) {
        let isCheckbox = input.type === 'toggle' || input.type === 'checkbox';
        if (isCheckbox) {
            if (input.checked !== value) {
                input.checked = value;
            }
            return;
        }

        if (input.value !== value) {
            input.value = value;
        }
    }

    setMapValue(map, path, value) {
        if (!path) {
            return map; // Return the original map if no path is provided
        }

        if (typeof path === 'string') {
            path = path.split('.'); // Split the path into an array of keys
        }

        let key = path.shift(); // Get the first key in the path

        let arrayIndex = null;

        // Check if the key contains a dot followed by square brackets
        if (key.startsWith('[') && key.endsWith(']')) {
            // Split the key into the property name and the array index
            [key, arrayIndex] = key.split('[');
            arrayIndex = parseInt(arrayIndex.slice(0, -1));
        }

        const updatedMap = map;

        if (path.length === 0) {
            if (arrayIndex !== null) {
                // If an array index was found, use it to update the element in the array
                updatedMap[key][arrayIndex] = value;
            } else {
                updatedMap[key] = value;
            }
        } else {
            // If an array index was found, use it to access the element in the array
            if (arrayIndex !== null) {
                updatedMap[arrayIndex] = this.setMapValue(updatedMap[arrayIndex], path, value);
            } else {
                if (!updatedMap[key] || typeof updatedMap[key] !== 'object') {
                    updatedMap[key] = {}; // Initialize the nested object if needed
                }
                updatedMap[key] = this.setMapValue(updatedMap[key], path, value); // Continue with the rest of the path
            }
        }

        return updatedMap; // Return the entire updated map
    }

    getMapValue(map, path) {
        if (!path || path.length === 0) {
            return map;
        }
        if (!Array.isArray(path)) {
            path = path.split('.');
        }

        map = map || {};

        let key = path[0];
        if (key.startsWith('[') && key.endsWith(']')) {
            key = parseInt(key.substring(0, key.length - 1).substring(1));
        }

        path.splice(0, 1);

        return this.getMapValue(map[key], path);
    }

    get(path, defaultValue) {
        return this.has(path) ? this.getMapValue(this.meta, path) : defaultValue;
    }

    set(path, value) {
        if (arguments.length === 1) {

            let updatedMeta = this.getProxy(path);  // path is actually the new meta
            this.updateMeta(updatedMeta);

            for (let path in this.bindings) {
                this.bindings[path].forEach(bindElement => {
                    this.setElementValue(bindElement, this.getMapValue(this.meta, path));
                });
            }
        } else {

            let updatedMeta = this.getProxy(this.setMapValue(JSON.parse(JSON.stringify(this.meta)), path, value));
            this.updateMeta(updatedMeta);

            let binds = this.bindings[path] || [];
            binds = binds.filter(otherBindElement => otherBindElement.isConnected);
            binds.forEach(otherBindElement => {
                this.setElementValue(otherBindElement, value);
            });

            //assume meta is dto.obj.key1 and user calls set('dto.obj', {key1: 'value1'}) it needs to update the bindings for all the dto.obj.* bindings
            for (let bindingPath in this.bindings) {
                if (bindingPath.startsWith(path + '.')) {
                    let binds = this.bindings[bindingPath];
                    binds = binds.filter(bindElement => bindElement.isConnected);
                    binds.forEach(bindElement => {
                        this.setElementValue(bindElement, this.getMapValue(this.meta, bindingPath));
                    });
                }
            }
        }
        return this;
    }

    has(path) {
        let value = this.getMapValue(this.meta, path);
        return value !== undefined &&
            value !== null &&
            (
                Array.isArray(value) ||
                (typeof value === 'object' && Object.keys(value).length > 0) ||
                JSON.stringify(value) !== '{}'
            );
    }

}

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
        console.log(action, 'REQUEST', JSON.stringify(request));

        let responseJSON = await runApex({
            action: action,
            requestJSON: JSON.stringify(request)
        });

        const response = JSON.parse(responseJSON);
        console.log(action, 'RESPONSE', JSON.stringify(response, null, 2));

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
    let validationResult = {
        errorsByInputs: [],
        allValid: true,
        getErrorMessages: function () {
            let errors = [];
            this.errorsByInputs.forEach(function (errorsByInput) {
                errors.push(errorsByInput.errors.join(','));
            })

            return errors;
        }
    };

    components.forEach(function (inputCmp) {

        let validationErrors = [
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

        let defaultErrorMessages = {
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

            if (inputCmp.validity === undefined) {
                if (inputCmp.validate !== undefined && !inputCmp.validate()) {
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

            } else if (inputCmp.validity && inputCmp.validity.valid === false) {

                let errors = [];
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

                if (inputCmp.reportValidity !== undefined) {
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

    let componentTypes = [
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
        'c-jam-lookup',
        'c-jam-select'
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
    return [array.slice(0, n)].concat(chunk(array.slice(n), n));
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

const copyToClipboard = (content) => {
    // Create an input field with the minimum size and place in a not visible part of the screen
    let tempTextAreaField = document.createElement('textarea');
    tempTextAreaField.style = 'position:fixed;top:-5rem;height:1px;width:10px;';

    // Assign the content we want to copy to the clipboard to the temporary text area field
    tempTextAreaField.value = content;

    // Append it to the body of the page
    document.body.appendChild(tempTextAreaField);

    // Select the content of the temporary markup field
    tempTextAreaField.select();

    // Run the copy function to put the content to the clipboard
    document.execCommand('copy');

    // Remove the temporary element from the DOM as it is no longer needed
    tempTextAreaField.remove();
}

export class Cache {

    static _cache = {};

    static get(key) {
        return this._cache[key]
    }

    static set(key, value) {
        this._cache[key] = value;
        return this;
    }
}

export {
    showToast,
    runAction,
    validate,
    flatten,
    chunk,
    getURlParams,
    copyToClipboard
}