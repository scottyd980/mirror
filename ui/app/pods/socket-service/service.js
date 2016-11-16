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

// let socket = new Socket('/socket', {
//   logger: ((kind, msg, data) => {
//     console.log(`${kind}: ${msg}`, data);
//   })
// });

export default Ember.Service.extend({
  session: Ember.inject.service(),
  socket: null,

  init() {
    this.socket = new Socket(`${config.DS.wshost}/socket`);
    this.socket.connect();
  },

  connect() {
    let chan = this.socket.channel("retrospectives:123", {
      token: this.get('session').get('session.content.authenticated.access_token')
    });
    chan.join().receive("ok", () => {
      console.log("joined retro channel");
    });

    chan.push('ping');

    chan.on('ping', () => {
      console.log('pong');
    });
  }

});
