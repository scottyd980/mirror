import Ember from 'ember';

export default Ember.Component.extend({
    dragOver(event) {
        event.preventDefault();
    },
    classNames: ["drop-zone"],
    drop(event) {
        var id = event.dataTransfer.getData('text/data');
        this.sendAction('onDrop', id, this.get('data'));
    }
});