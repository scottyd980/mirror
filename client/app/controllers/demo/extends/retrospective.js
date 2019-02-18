import Controller from '@ember/controller';
import { inject as service } from '@ember/service';
import { get, set } from '@ember/object';

export default Controller.extend({
  tour: service(),
  cancel_tour: function() {
    if(this.get('tour.tourObject')) {
      this.get('tour').cancel();
    }
  },
  actions: {
    continue: function(route, extraAction) {
      this.cancel_tour();
      if(extraAction) {
        extraAction();
      }
      this.transitionToRoute(route);
    },
    back: function(route) {
      this.cancel_tour();
      this.transitionToRoute(route);
    },
    cancel: function() {
      this.cancel_tour();
      this.transitionToRoute('index');
    },
    openActionModal(feedback) {
      let actionMessage = '';

      const action = get(feedback, 'action');
      if (action) {
        actionMessage = get(action, 'message');
      }

      this.set('activeFeedback', feedback);
      this.set('actionMessage', actionMessage);
      this.set('isActionModalShowing', true);
    },
    closeActionModal() {
      this.set('isActionModalShowing', false);
      this.set('activeFeedback', null);
      this.set('actionMessage', '');
    },
    submitActionItem() {
      const feedback = this.get('activeFeedback');
      const message = this.get('actionMessage');
      
      const action = get(feedback, 'action');
      
      if (message.trim() !== "" && action) {
        set(action, 'message', message);
      } else if (message.trim() !== "") {
        set(feedback, 'action', {
          message: message
        });
      } else if (message.trim() === "" && action) {
        set(feedback, 'action', null);
      }

      this.send('closeActionModal');
    },
  }
});