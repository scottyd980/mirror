import Ember from 'ember';

export default Ember.Service.extend({
  retrospectives: null,
  init() {
    this._super(...arguments);
    this.set('retrospectives', []);
  },
  start(retrospective) {
    console.log(retrospective);
  },
  lookup(team) {
    console.log(team);
  }
});
