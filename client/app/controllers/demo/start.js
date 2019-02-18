import { later } from '@ember/runloop';
import ENV from 'mirror/config/environment';
import RetrospectiveController from 'mirror/controllers/demo/extends/retrospective';

export default RetrospectiveController.extend({
  showModal: false,

  begin_joining: function() {
    later(this, function() {
      this.get('model.retrospective.participants').pushObject(ENV.DEMO.team_members[3]);
      later(this, function() {
        this.get('model.retrospective.participants').pushObject(ENV.DEMO.team_members[2]);
      }, 1100);
    }, 1500);
  },

  actions: {
    close: function() {
      this.set('showModal', false);
    },
    start: function() {
      this.start_tour(ENV.TOUR.start);
      this.begin_joining();
      this.send('close');
    }
  }
});
