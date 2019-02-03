import Controller from '@ember/controller';
import ENV from 'mirror/config/environment';

export default Controller.extend({
  isAdmin: false,
  actions: {
    deleteAction(retrospective) {
      retrospective.set('cancelled', true);
      retrospective.save().then(() => {
        this.get('notifications').success({
          title: ENV.SUCCESS_MESSAGES.generic,
          message: "The retrospective was successfully removed from your team's history."
        });
        this.set('model.retrospectives', this.store.query('retrospective', {
          filter: {
            team: this.get('model.team').get('id')
          }
        }));
      }).catch(() => {
        this.get('notifications').error({
          title: ENV.ERROR_MESSAGES.generic,
          message: "We experienced an unexpected error. Please try again."
        });
      });
    }
  }
});
