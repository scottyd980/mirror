import Ember from 'ember';

export default Ember.Component.extend({
    attributeBindings: ['isModerator:draggable'],
    classNames: ['note'],
    classNameBindings: ['type'],
    isModerator: null,
    type: ''
});
