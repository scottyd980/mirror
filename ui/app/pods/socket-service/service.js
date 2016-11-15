import PhoenixSocket from 'phoenix/services/phoenix-socket';
import config from '../../config/environment';

export default PhoenixSocket.extend({

  init() {
    this.on('open', () => {
      console.log('Socket was opened!');
    })
  },

  connect(/*url, options*/) {
    const myjwt = "abacnwih12eh12...";
    // connect the socket
    this._super(`${config.DS.wshost}/socket`, {
      params: {token: myjwt}
    });

    // join a channel
    const channel = this.joinChannel("retrospectives:123", {
      nickname: "Mike"
    });

    // add message handlers
    channel.on("notification", () => _onNotification(...arguments));
  },

  _onNotification(message) {
    alert(`Notification: ${message}`);
  }
});
