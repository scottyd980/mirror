import Ember from 'ember';
import config from '../../../config/environment';

export default Ember.Component.extend({
    tagName: "ul",
    classNames: ["table-list"],
    active_billing_types: config.ACTIVE_BILLING_TYPES
});