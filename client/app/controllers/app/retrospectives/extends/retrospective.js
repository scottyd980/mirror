import Controller from '@ember/controller';
import ENV from 'mirror/config/environment';

export default Controller.extend({
  actions: {
    changeRetrospectiveState(retrospective, currentStateSegment, direction) {
      //TODO: Need to account for games here
      const currentState = ENV.retrospective.sticky_notes.states.indexOf(currentStateSegment);

      retrospective.set('state', (currentState + direction));
      retrospective.save();
    },
    moveFeedback(id, state) {
      this.store.findRecord('feedback', id).then((fb) => {
        fb.set('state', state);
        fb.save();
      });
    },
    cancelRetrospective(retrospective) {
      // TODO: next_sprint not reverting fast enough.
      retrospective.set('cancelled', true);
      retrospective.save().then(() => {
        setTimeout(() => {
          this.transitionToRoute('app.teams.team.dashboard.retrospectives', retrospective.get('team.id')).then(() => {
            // this.send('invalidateApplicationModel');
            this.get('notifications').success({
              title: ENV.SUCCESS_MESSAGES.generic,
              message: "The retrospective was successfully cancelled."
            });
          }), 0
        });
      }).catch(() => {
        this.get('notifications').error({
          title: ENV.ERROR_MESSAGES.generic,
          message: "We experienced an unexpected error. Please try again."
        });
      });
    },
    openActionModal(feedback) {
      let actionMessage = '';

      feedback.get('action').then((action) => {
        if (action) {
          actionMessage = action.get('message');
        }

        this.set('activeFeedback', feedback);
        this.set('actionMessage', actionMessage);
        this.set('isActionModalShowing', true);
      });
    },
    closeActionModal() {
      this.set('isActionModalShowing', false);
      this.set('activeFeedback', null);
      this.set('actionMessage', '');
    },
    submitActionItem() {
      const feedback = this.get('activeFeedback');
      const message = this.get('actionMessage');

      feedback.get('action').then((action) => {
        if (message.trim() !== "" && action) {
          action.set('message', message);
          action.save();
        } else if (message.trim() !== "") {
          this.store.createRecord('action', {
            message: message,
            feedback: feedback
          }).save();
        } else if (message.trim() === "" && action) {
          action.destroyRecord();
        }

        this.send('closeActionModal');
      });
    },
    onConfirm(message, action) {
      this.get('notifications').confirmAction(message, action);
    }
  }
});
