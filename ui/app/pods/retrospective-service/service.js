import Ember from 'ember';

export default Ember.Service.extend({
  retrospectives: null,
  init() {
    this._super(...arguments);
    this.set('retrospectives', []);
  },
  start(retrospective) {
    console.log(retrospective);
    return retrospective.save();
  },
  lookup(team) {
    console.log(team);
  }
});
