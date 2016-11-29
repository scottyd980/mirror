// import PhoenixSocket from 'phoenix/services/phoenix-socket';
import config from '../../config/environment';
//
// export default PhoenixSocket.extend({
//   session: Ember.inject.service(),
//
//   init() {
//     this.on('open', () => {
//       console.log('Socket was opened!');
//     })
//   },
//
//   connect(/*url, options*/) {
//     // connect the socket
//     this._super(`${config.DS.wshost}/socket`, {});
//
//     // join a channel
//     const channel = this.joinChannel("retrospectives:123", {
//       nickname: "Mike",
//       token: this.get('session').get('session.content.authenticated.access_token')
//     });
//
//     console.log(channel.push('ping', {}));
//
//     // add message handlers
//     channel.on("notification", () => _onNotification(...arguments));
//   },
//
//   _onNotification(message) {
//     alert(`Notification: ${message}`);
//   }
// });

import { Socket } from 'phoenix';

export default Ember.Service.extend({
  session: Ember.inject.service(),
  socket: null,
  channels: {},

  init() {
    this.socket = new Socket(`${config.DS.wshost}/socket`);
    this.socket.connect();
  },

  joinChannel(channel) {
    let channel_to_join = channel.replace(":", "_");

    if(!this.channels[channel_to_join]) {
      this.channels[channel_to_join] = this.socket.channel(channel, {
        token: this.get('session').get('session.content.authenticated.access_token')
      });

      let chan = this.channels[channel_to_join];

      chan.join().receive("ok", (resp) => {
        console.log("joined channel: " + channel);
        console.log(resp);
      });
    } else {
      console.log("already joined channel: " + channel);
    }

    return this.channels[channel_to_join];
  }

});
