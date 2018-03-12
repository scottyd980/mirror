import Ember from 'ember';

export default Ember.Component.extend({
    attributeBindings: ['isModerator:draggable'],
    classNames: ['note'],
    classNameBindings: ['type'],
    isModerator: null,
    isAnonymous: null,
    type: '',
    dragStart: function(event) {
        event.dataTransfer.setData("text/data", this.get('data.id'));
        $('.drop-zone').addClass('dz-border');
    },
    dragEnd: function(event) {
        $('.drop-zone').removeClass('dz-border');
    }
});
