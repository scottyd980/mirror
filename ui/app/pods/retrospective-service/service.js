import Ember from 'ember';

export default Ember.Service.extend({
  socket: Ember.inject.service('socket-service'),
  routing: Ember.inject.service("-routing"),
  channel: null,
  pre_retrospective: {
    in_progress: false,
    retrospective_id: null
  },
  init() {
    this._super(...arguments);
    this.set('channel', null);
  },
  start(retrospective) {
    return retrospective.save();
  },
  lookup_in_progress(team_id) {
    this.get('channel').push('check_retrospective_in_progress', {});
  },
  reset_pre_retrospective() {
    this.set('pre_retrospective', {
      in_progress: false,
      retrospective_id: null
    });
    this.set('channel', null);
  },
  sendMessage(topic, data) {
    this.get('channel').push(topic, data);
  },

  // Team
  join_team_channel(team_id) {
    this.reset_pre_retrospective();

    var team_retrospective_channel = this.get('socket').joinChannel(`team:${team_id}`);
    team_retrospective_channel.then((chan) => {
      this.listen_for_team_events(chan);
      this.set('channel', chan);
      this.lookup_in_progress(team_id);
    });

    return this.get('pre_retrospective');
  },

  listen_for_team_events(channel) {
    this._listen_for_retrospective_in_progress(channel);
  },

  _listen_for_retrospective_in_progress(channel) {
    channel.on('retrospective_in_progress', (resp) => {
      this.set('pre_retrospective.in_progress', resp.retrospective_in_progress);
      this.set('pre_retrospective.retrospective_id', resp.retrospective_id);
    });
  },

  // Retrospective
  join_retrospective_channel(retrospective_id) {
    var retrospective_channel = this.get('socket').joinChannel(`retrospective:${retrospective_id}`);
    retrospective_channel.then((chan) => {
      this.listen_for_retrospective_events(chan);
      this.set('channel', chan);
      this.lookup_in_progress(retrospective_id);
    });
  },

  listen_for_retrospective_events(channel) {
    this._listen_for_joined_retrospective(channel);
  },

  _listen_for_joined_retrospective(channel) {
    channel.on('joined_retrospective', (resp) => {
      this.get('routing').transitionTo('app.retrospectives.retrospective.start', [resp.retrospective_id]);
    });
  }
});
