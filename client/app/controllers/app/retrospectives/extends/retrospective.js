import Controller from '@ember/controller';
import ENV from 'mirror/config/environment';
import { computed } from '@ember/object';
import { inject as service } from '@ember/service';

export default Controller.extend({
  session: service(),
  retroSvc: service('retrospective'),
  currentUser: computed('session.currentUser', function() {
    return this.get('session.currentUser');
  }),
  isModerator: computed('model.retrospective.moderator.id', 'session.currentUser', function() {
    return this.get('model.retrospective.moderator.id') === this.get('session.currentUser.id');
  }),
  actions: {
    changeRetrospectiveState(retrospective, currentStateSegment, direction) {
      //TODO: Need to account for games here
      //TODO: Also account for loading here
      const currentState = ENV.retrospective.sticky_notes.states.indexOf(currentStateSegment);
      this.get('store').findRecord('retrospective', retrospective.get('id'), { reload: true }).then((retro) => {
        retro.set('state', (currentState + direction));
        retro.save();
      })
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
            this.get('notifications').success({
              title: "Retrospective Cancelled",
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
