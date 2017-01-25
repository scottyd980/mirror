import Ember from 'ember';

export default Ember.TextArea.reopen({
  attributeBindings: ['data-type']
});