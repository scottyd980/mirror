import Ember from 'ember';

export default Ember.Component.extend({
    tagName: "ul",
    classNames: ["table-list"],
    active_billing_types: ["active", "monthly", "yearly"]
});
