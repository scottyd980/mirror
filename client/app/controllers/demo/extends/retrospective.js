import Controller from '@ember/controller';
import { inject as service } from '@ember/service';

export default Controller.extend({
  tour: service(),
  actions: {
    continue: function(route, extraAction) {
      this.get('tour').cancel();
      if(extraAction) {
        extraAction();
      }
      this.transitionToRoute(route);
    },
    back: function(route) {
      this.get('tour').cancel();
      this.transitionToRoute(route);
    },
    cancel: function() {
      this.get('tour').cancel();
      this.transitionToRoute('index');
    }
  }
});