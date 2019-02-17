import Service from '@ember/service';
import { inject as service } from '@ember/service';

export default Service.extend({
  socket: service(),
  store: service(),
  session: service(),
  uuid: service(),

  team_channel: null,
  retrospective_channel: null,
  pre_retrospective: null,
  active_retrospective: null,

  init() {
    this._super(...arguments);
    this.set('channel', null);
    this.set('active_retrospective');
    this.set('pre_retrospective', {
      in_progress: false,
      retrospective_id: null
    });
  },
  start(retrospective) {
    return retrospective.save();
  },
  lookup_in_progress() {
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
    }).catch((e) => {
      this.get('notifications').error({
        title: ENV.ERROR_MESSAGES.time_out,
        message: "Your connection to our server has timed out. This usually occurs after you are away from Mirror for a while. Please refresh the page to solve the issue."
      });
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
  join_retrospective_channel(retrospective) {
    var retrospective_channel = this.get('socket').joinChannel(`retrospective:${retrospective.get('id')}`);
    retrospective_channel.then((chan) => {
      this.listen_for_retrospective_events(chan);
      this.set('retrospective_channel', chan);
      this.set('active_retrospective', retrospective);
    }).catch((e) => {
      this.get('notifications').error({
        title: ENV.ERROR_MESSAGES.time_out,
        message: "Your connection to our server has timed out. This usually occurs after you are away from Mirror for a while. Please refresh the page to solve the issue."
      });
    });
  },

  leave_retrospective_channel(retrospective_id) {
    var retrospective_channel = this.get('socket').leaveChannel(`retrospective:${retrospective_id}`);
    retrospective_channel.then((/* chan */) => {
      this.set('retrospective_channel', null);
      this.set('active_retrospective', null);
    }).catch((e) => {
      this.get('notifications').error({
        title: ENV.ERROR_MESSAGES.time_out,
        message: "Your connection to our server has timed out. This usually occurs after you are away from Mirror for a while. Please refresh the page to solve the issue."
      });
    });
  },

  listen_for_retrospective_events(channel) {
    this._listen_for_joined_retrospective(channel);
    this._listen_for_retrospective_updates(channel);
    this._listen_for_retrospective_scores(channel);
    this._listen_for_retrospective_score_submissions(channel);
    this._listen_for_retrospective_feedback(channel);
    this._listen_for_retrospective_feedback_submissions(channel);
    this._listen_for_retrospective_feedback_change(channel);
    this._listen_for_retrospective_action_item(channel);
    this._listen_for_retrospective_action_item_deleted(channel);
  },

  _listen_for_joined_retrospective(channel) {
    channel.on('joined_retrospective', (resp) => {
      this.get('store').pushPayload(JSON.parse(JSON.stringify(resp)));
    });
  },

  _listen_for_retrospective_updates(channel) {
    channel.on('retrospective_update', (resp) => {
      this.get('store').pushPayload(JSON.parse(JSON.stringify(resp)));
    });
  },

  _listen_for_retrospective_scores(channel) {
    channel.on('sprint_score_added', (resp) => {

      // Only push to store if it's not the current logged in user.
      if (resp.data.attributes.uuid !== this.get('uuid').get('hash')) {
        this.get('store').pushPayload(JSON.parse(JSON.stringify(resp)));
      }

    });
  },

  _listen_for_retrospective_score_submissions(channel) {
    channel.on('sprint_score_submitted', (resp) => {
      this.get('store').pushPayload(JSON.parse(JSON.stringify(resp)));
    });
  },

  _listen_for_retrospective_feedback(channel) {
    channel.on('feedback_added', (resp) => {

      // Only push to store if it's not the current logged in user.
      if (resp.data.attributes.uuid !== this.get('uuid').get('hash')) {
        this.get('store').pushPayload(JSON.parse(JSON.stringify(resp)));
      }

    });
  },

  _listen_for_retrospective_feedback_submissions(channel) {
    channel.on('feedback_submitted', (resp) => {
      this.get('store').pushPayload(JSON.parse(JSON.stringify(resp)));
    });
  },

  _listen_for_retrospective_feedback_change(channel) {
    channel.on('feedback_state_change', (resp) => {
      // We want this to push to store to everyone, even if it's the user that submitted it, because they may not be the one
      // moderating.
      this.get('store').pushPayload(JSON.parse(JSON.stringify(resp)));
    });
  },

  _listen_for_retrospective_action_item(channel) {
    channel.on('feedback_action_change', (resp) => {
      // We don't want to push these changes to the moderator
      if(parseInt(resp.data.relationships.user.data.id) !== parseInt(this.get('session').get('currentUser.id'))) {
        this.get('store').pushPayload(JSON.parse(JSON.stringify(resp)));
      }
    });
  },

  _listen_for_retrospective_action_item_deleted(channel) {
    channel.on('feedback_action_deleted', (resp) => {
      // We don't want to push these changes to the moderator
      this.get('store').findRecord('feedback', resp.data.relationships.feedback.data.id).then((feedback) => {
        feedback.set('action', null);
      });
    });
  }
});
