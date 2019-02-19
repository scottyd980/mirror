import Service from '@ember/service';
import ENV from 'mirror/config/environment';
import { Socket, LongPoll } from 'ember-phoenix';
import { inject as service } from '@ember/service';

export default Service.extend({
  session: service(),
  socket: null,
  channels: null,

  init() {
    this._super(...arguments);
    this.set('channels', {});
    this.socket = new Socket(`${ENV.DS.wshost}/socket`, {
      //transport: LongPoll
    });
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

        chan.join().receive("ok", (/* resp */) => {
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
  },

  leaveChannel(channel) {
    let channel_to_leave = channel.replace(":", "_");
    var _this = this;

    return new Promise(function(resolve, reject) {

      if(_this.channels[channel_to_leave]) {

        let chan = _this.channels[channel_to_leave];

        chan.leave().receive("ok", (/* resp */) => {
          // User has left channel successfully
          resolve(chan);
        }).receive("ignore", () => {
          // User is not authorized to leave channel
          reject("authorization error");
        }).receive("timeout", () => {
          // Leaving the channel timed out
          reject("Connection interruption");
        });
      } else {
        // Already not in this channel
        resolve({});
      }

    });
  }
});
