import Ember from 'ember';

export default Ember.Service.extend({
  socket: Ember.inject.service('socket-service'),
  channel: null,
  retrospective: {
    in_progress: false
  },
  init() {
    this._super(...arguments);
    this.set('channel', null);
  },
  start(retrospective) {
    console.log(retrospective);
    return retrospective.save();
  },
  lookup_in_progress(team_id) {
    this.get('channel').push('check_retrospective_in_progress', {});
  },
  join_channel(team_id) {
    this.reset_retrospective();

    var retrospective_channel = this.get('socket').joinChannel(`team:${team_id}`);
    retrospective_channel.then((chan) => {
      this.listen_for_events(chan);

      this.set('channel', chan);

      this.lookup_in_progress(team_id);
    });

    return this.get('retrospective');
  },
  listen_for_events(channel) {
    channel.on('retrospective_in_progress', (resp) => {
      this.set('retrospective.in_progress', resp.retrospective_in_progress);
    });
  },
  reset_retrospective() {
    this.set('retrospective', {
      in_progress: false
    })
  }
});
