import Ember from 'ember';

export default Ember.Component.extend({
  tagName: "ul",
  classNames: ["action-list"],
  sortedMembers: Ember.computed.sort('members', 'memberSortDefinition'),
  memberSortDefinition: ['id:asc'],
});
