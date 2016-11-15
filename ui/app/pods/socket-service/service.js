import PhoenixSocket from 'phoenix/services/phoenix-socket';
import config from '../../config/environment';

export default PhoenixSocket.extend({
  session: Ember.inject.service(),

  init() {
    this.on('open', () => {
      console.log('Socket was opened!');
    })
  },

  connect(/*url, options*/) {
    // connect the socket
    this._super(`${config.DS.wshost}/socket`, {});

    // join a channel
    const channel = this.joinChannel("retrospectives:123", {
      nickname: "Mike",
      token: this.get('session').get('session.content.authenticated.access_token')
    });

    channel.push('ping', {});

    // add message handlers
    channel.on("notification", () => _onNotification(...arguments));
  },

  _onNotification(message) {
    alert(`Notification: ${message}`);
  }
});
