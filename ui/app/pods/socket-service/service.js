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
    var _this = this;

    return new Promise(function(resolve, reject) {

      if(!_this.channels[channel_to_join]) {
        _this.channels[channel_to_join] = _this.socket.channel(channel, {
          token: _this.get('session').get('session.content.authenticated.access_token')
        });

        let chan = _this.channels[channel_to_join];

        chan.join().receive("ok", (resp) => {
          // User has joined channel successfully
          resolve(chan);
        }).receive("ignore", () => {
          // User is not authorized to join channel
          reject("authorization error");
        }).receive("timeout", () => {
          // Joining the channel timed out
          reject("Connection interruption");
        });
      } else {
        // Already joined this channel
        resolve(_this.channels[channel_to_join]);
      }

    });
  }

});
