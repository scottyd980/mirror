import Ember from 'ember';

export default Ember.Service.extend({
  socket: Ember.inject.service('socket-service'),
  routing: Ember.inject.service("-routing"),
  store: Ember.inject.service('store'),
  session: Ember.inject.service(),

  team_channel: null,
  retrospective_channel: null,
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
    this.get('team_channel').push('check_retrospective_in_progress', {});
  },
  reset_pre_retrospective() {
    this.set('pre_retrospective', {
      in_progress: false,
      retrospective_id: null
    });
    this.set('team_channel', null);
  },
  sendMessage(channel_type, topic, data) {
    this.get(`${channel_type}_channel`).push(topic, data);
  },

  // Team
  join_team_channel(team_id) {
    this.reset_pre_retrospective();

    var team_retrospective_channel = this.get('socket').joinChannel(`team:${team_id}`);
    team_retrospective_channel.then((chan) => {
      this.listen_for_team_events(chan);
      this.set('team_channel', chan);
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
      this.set('retrospective_channel', chan);
    });
  },

  listen_for_retrospective_events(channel) {
    this._listen_for_joined_retrospective(channel);
    this._listen_for_retrospective_updates(channel);
    this._listen_for_retrospective_scores(channel);
    this._listen_for_retrospective_feedback_change(channel);
  },

  _listen_for_joined_retrospective(channel) {
    channel.on('joined_retrospective', (resp) => {
      this.get('store').pushPayload(JSON.parse(JSON.stringify(resp)));
    });
  },

  _listen_for_retrospective_updates(channel) {
    channel.on('retrospective_updates', (resp) => {
      this.get('store').pushPayload(JSON.parse(JSON.stringify(resp)));
    });
  },

  _listen_for_retrospective_scores(channel) {
    channel.on('sprint_score_added', (resp) => {

      // Only push to store if it's not the current logged in user.
      if(parseInt(resp.data.relationships.user.data.id) !== parseInt(this.get('session').get('currentUser.id'))) {
        this.get('store').pushPayload(JSON.parse(JSON.stringify(resp)));
      }
      
    });
  },

  _listen_for_retrospective_feedback_change(channel) {
    channel.on('feedback_state_change', (resp) => {
      if(parseInt(resp.data.relationships.user.data.id) !== parseInt(this.get('session').get('currentUser.id'))) {
        this.get('store').pushPayload(JSON.parse(JSON.stringify(resp)));
      }
    });
  }
});
